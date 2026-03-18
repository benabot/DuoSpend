import Foundation
import MultipeerConnectivity
import os

/// Service de synchronisation peer-to-peer via MultipeerConnectivity.
/// Gère la découverte, la connexion et l'échange de données entre deux appareils.
@MainActor
@Observable
final class PeerSyncService: NSObject {

    // MARK: - Types

    /// État du service de synchronisation.
    enum SyncState: Equatable {
        case idle
        case searching
        case connecting
        case connected(String)
        case sending
        case receiving
        case completed
        case error(String)
    }

    // MARK: - Observable State

    private(set) var state: SyncState = .idle
    private(set) var receivedPayload: SyncPayload?

    // MARK: - Private

    private let serviceType = "duospend-sync"
    private let myPeerID: MCPeerID
    private var session: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private let logger = Logger(subsystem: "fr.benabot.DuoSpend", category: "PeerSync")

    /// Buffer pour assembler les données reçues en plusieurs fragments.
    private var receivedData = Data()

    // MARK: - Init

    override init() {
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
    }

    // MARK: - Public API

    /// Démarre l'advertising : ce peer "héberge" et partage son projet.
    func startHosting() {
        stop()
        logger.info("Démarrage hosting (advertiser)…")

        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        self.session = session

        let advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
        self.advertiser = advertiser

        state = .searching
    }

    /// Démarre le browsing : ce peer cherche un host pour recevoir un projet.
    func startJoining() {
        stop()
        logger.info("Démarrage joining (browser)…")

        let session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        self.session = session

        let browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser.delegate = self
        browser.startBrowsingForPeers()
        self.browser = browser

        state = .searching
    }

    /// Envoie un payload au peer connecté.
    func send(payload: SyncPayload) {
        guard let session,
              let peer = session.connectedPeers.first else {
            logger.error("Envoi impossible : pas de peer connecté.")
            state = .error("Aucun partenaire connecté")
            return
        }

        state = .sending
        logger.info("Envoi du payload à \(peer.displayName)…")

        do {
            let data = try JSONEncoder().encode(payload)
            logger.info("Taille du payload : \(data.count) octets")

            // Si le payload dépasse 90 KB, utiliser sendResource via fichier temporaire
            if data.count > 90_000 {
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("sync_payload.json")
                try data.write(to: tempURL)
                session.sendResource(at: tempURL, withName: "sync_payload.json", toPeer: peer) { [weak self] error in
                    Task { @MainActor [weak self] in
                        guard let self else { return }
                        if let error {
                            self.logger.error("Erreur envoi resource : \(error.localizedDescription)")
                            self.state = .error("Erreur d'envoi : \(error.localizedDescription)")
                        } else {
                            self.logger.info("Payload envoyé via resource.")
                            self.state = .completed
                        }
                    }
                }
            } else {
                try session.send(data, toPeers: [peer], with: .reliable)
                state = .completed
                logger.info("Payload envoyé avec succès.")
            }
        } catch {
            logger.error("Erreur encodage/envoi : \(error.localizedDescription)")
            state = .error("Erreur d'envoi : \(error.localizedDescription)")
        }
    }

    /// Arrête toute activité (advertising, browsing, session).
    func stop() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        browser?.stopBrowsingForPeers()
        browser = nil
        session?.disconnect()
        session = nil
        receivedData = Data()
        logger.info("Service arrêté.")
    }

    /// Remet le service à l'état initial.
    func reset() {
        stop()
        state = .idle
        receivedPayload = nil
    }
}

// MARK: - MCSessionDelegate

extension PeerSyncService: MCSessionDelegate {

    nonisolated func session(_ session: MCSession, peer peerID: MCPeerID, didChange newState: MCSessionState) {
        let peerName = peerID.displayName
        Task { @MainActor [weak self] in
            guard let self else { return }
            switch newState {
            case .notConnected:
                self.logger.info("Peer déconnecté : \(peerName)")
                if case .connected = self.state {
                    self.state = .error("Connexion perdue avec \(peerName)")
                }
            case .connecting:
                self.logger.info("Connexion en cours avec \(peerName)…")
                self.state = .connecting
            case .connected:
                self.logger.info("Connecté à \(peerName)")
                self.state = .connected(peerName)
                // Arrêter la recherche une fois connecté
                self.advertiser?.stopAdvertisingPeer()
                self.browser?.stopBrowsingForPeers()
            @unknown default:
                self.logger.warning("État inconnu pour \(peerName)")
            }
        }
    }

    nonisolated func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let peerName = peerID.displayName
        let dataSize = data.count
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.state = .receiving
            self.logger.info("Données reçues de \(peerName) : \(dataSize) octets")

            do {
                let payload = try JSONDecoder().decode(SyncPayload.self, from: data)
                self.receivedPayload = payload
                self.state = .completed
                self.logger.info("Payload décodé : \(payload.projectName) — \(payload.expenses.count) dépenses")
            } catch {
                self.logger.error("Erreur décodage payload : \(error.localizedDescription)")
                self.state = .error("Données reçues invalides")
            }
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {
        // Non utilisé
    }

    nonisolated func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {
        let peerName = peerID.displayName
        Task { @MainActor [weak self] in
            self?.state = .receiving
            self?.logger.info("Réception resource '\(resourceName)' de \(peerName)…")
        }
    }

    nonisolated func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {
        // Lire les données synchronement avant de passer au MainActor
        let fileData: Data?
        if let localURL {
            fileData = try? Data(contentsOf: localURL)
        } else {
            fileData = nil
        }
        let errorDesc = error?.localizedDescription

        Task { @MainActor [weak self] in
            guard let self else { return }

            if let errorDesc {
                self.logger.error("Erreur réception resource : \(errorDesc)")
                self.state = .error("Erreur de réception")
                return
            }

            guard let data = fileData else {
                self.state = .error("Fichier reçu introuvable")
                return
            }

            do {
                let payload = try JSONDecoder().decode(SyncPayload.self, from: data)
                self.receivedPayload = payload
                self.state = .completed
                self.logger.info("Payload (resource) décodé : \(payload.projectName)")
            } catch {
                self.logger.error("Erreur décodage resource : \(error.localizedDescription)")
                self.state = .error("Données reçues invalides")
            }
        }
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension PeerSyncService: MCNearbyServiceAdvertiserDelegate {

    nonisolated func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        let peerName = peerID.displayName
        // Capturer le handler comme nonisolated(unsafe) pour traverser la frontière de concurrence
        nonisolated(unsafe) let handler = invitationHandler
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.logger.info("Invitation reçue de \(peerName). Acceptation automatique.")
            handler(true, self.session)
        }
    }

    nonisolated func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        let errorDesc = error.localizedDescription
        Task { @MainActor [weak self] in
            self?.logger.error("Échec advertising : \(errorDesc)")
            self?.state = .error("Impossible de démarrer le partage")
        }
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension PeerSyncService: MCNearbyServiceBrowserDelegate {

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        let peerName = peerID.displayName
        // Capturer peerID et browser comme nonisolated(unsafe) pour l'invitation
        nonisolated(unsafe) let unsafePeerID = peerID
        nonisolated(unsafe) let unsafeBrowser = browser
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.logger.info("Peer trouvé : \(peerName). Envoi invitation…")
            guard let session = self.session else { return }
            unsafeBrowser.invitePeer(unsafePeerID, to: session, withContext: nil, timeout: 30)
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        let peerName = peerID.displayName
        Task { @MainActor [weak self] in
            self?.logger.info("Peer perdu : \(peerName)")
        }
    }

    nonisolated func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        let errorDesc = error.localizedDescription
        Task { @MainActor [weak self] in
            self?.logger.error("Échec browsing : \(errorDesc)")
            self?.state = .error("Impossible de chercher un partenaire")
        }
    }
}
