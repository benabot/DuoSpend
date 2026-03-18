import Foundation
import SwiftData
import UIKit
import os

/// ViewModel de coordination pour la synchronisation peer-to-peer.
/// Orchestre PeerSyncService et SyncMergeService, expose l'état à la UI.
@MainActor
@Observable
final class PeerSyncViewModel {

    // MARK: - Observable State

    /// Nombre de dépenses ajoutées après le dernier merge.
    private(set) var mergedExpenseCount: Int = 0

    /// Message d'erreur du merge (distinct de l'erreur réseau).
    private(set) var mergeError: String?

    // MARK: - Dependencies

    let syncService: PeerSyncService
    private let logger = Logger(subsystem: "fr.benabot.DuoSpend", category: "PeerSyncVM")

    // MARK: - Init

    init(syncService: PeerSyncService = PeerSyncService()) {
        self.syncService = syncService
    }

    /// État courant de la connexion, délégué au service.
    var state: PeerSyncService.SyncState {
        syncService.state
    }

    // MARK: - Actions

    /// Démarre le partage (host) du projet donné.
    func startSharing() {
        syncService.startHosting()
    }

    /// Démarre la réception (joiner).
    func startReceiving() {
        syncService.startJoining()
    }

    /// Envoie le projet au peer connecté.
    func sendProject(_ project: Project) {
        let payload = SyncPayload(project: project, expenses: project.expenses)
        syncService.send(payload: payload)
        hapticSuccess()
    }

    /// Fusionne le payload reçu dans le contexte SwiftData local.
    func mergeReceivedPayload(into context: ModelContext) {
        guard let payload = syncService.receivedPayload else {
            logger.warning("Aucun payload à fusionner.")
            return
        }

        do {
            mergedExpenseCount = try SyncMergeService.merge(payload: payload, into: context)
            mergeError = nil
            hapticSuccess()
            logger.info("Merge terminé : \(self.mergedExpenseCount) dépenses ajoutées.")
        } catch {
            mergeError = error.localizedDescription
            hapticError()
            logger.error("Erreur merge : \(error.localizedDescription)")
        }
    }

    /// Arrête tout et remet à zéro.
    func reset() {
        syncService.reset()
        mergedExpenseCount = 0
        mergeError = nil
    }

    /// Arrête la connexion.
    func stop() {
        syncService.stop()
    }

    // MARK: - Haptics

    private func hapticSuccess() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    private func hapticError() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
