import SwiftUI

/// Écran de synchronisation peer-to-peer entre deux iPhones.
/// Présenté en sheet modale depuis ProjectDetailView.
struct PeerSyncView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    /// Projet à partager (fourni par le host).
    let project: Project

    @State private var viewModel = PeerSyncViewModel()

    /// Rôle choisi par l'utilisateur.
    @State private var role: Role?

    enum Role {
        case host   // partage son projet
        case joiner // reçoit un projet
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch role {
                case .none:
                    roleSelectionView
                case .host:
                    hostFlowView
                case .joiner:
                    joinerFlowView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.warmBackground.ignoresSafeArea())
            .navigationTitle("Synchronisation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        viewModel.reset()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationCornerRadius(20)
        .onChange(of: viewModel.syncService.receivedPayload) {
            // Auto-merge quand un payload est reçu côté joiner
            if viewModel.syncService.receivedPayload != nil {
                viewModel.mergeReceivedPayload(into: modelContext)
            }
        }
        .onDisappear {
            viewModel.stop()
        }
    }

    // MARK: - Étape 1 : Choix du rôle

    private var roleSelectionView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "person.2.wave.2")
                .font(.system(size: 56))
                .foregroundStyle(Color.accentPrimary.gradient)
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text("Sync avec partenaire")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                Text("Synchronisez vos dépenses\nen étant côte à côte")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                roleButton(
                    title: "Partager ce projet",
                    subtitle: "Envoyez « \(project.name) » au téléphone de votre partenaire",
                    icon: "square.and.arrow.up.fill",
                    color: .partner1
                ) {
                    role = .host
                    viewModel.startSharing()
                }

                roleButton(
                    title: "Recevoir un projet",
                    subtitle: "Récupérez le projet partagé par votre partenaire",
                    icon: "square.and.arrow.down.fill",
                    color: .partner2
                ) {
                    role = .joiner
                    viewModel.startReceiving()
                }
            }
            .padding(.horizontal)

            Spacer()
        }
    }

    private func roleButton(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: shadowColor, radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Host Flow

    private var hostFlowView: some View {
        VStack(spacing: 24) {
            Spacer()

            switch viewModel.state {
            case .searching:
                searchingView(message: "En attente d'un partenaire…")

            case .connecting:
                searchingView(message: "Connexion en cours…")

            case .connected(let peerName):
                connectedHostView(peerName: peerName)

            case .sending:
                progressView(message: "Envoi en cours…")

            case .completed:
                completedView(
                    message: "\(project.name) envoyé avec succès",
                    detail: "\(project.expenses.count) dépenses transférées"
                )

            case .error(let message):
                errorView(message: message)

            case .idle, .receiving:
                EmptyView()
            }

            Spacer()

            if canCancel {
                cancelButton
            }
        }
        .padding()
    }

    private func connectedHostView(peerName: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color.successGreen)

            VStack(spacing: 6) {
                Text("Connecté à")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                Text(peerName)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
            }

            Button {
                viewModel.sendProject(project)
            } label: {
                Label("Envoyer « \(project.name) »", systemImage: "paperplane.fill")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Joiner Flow

    private var joinerFlowView: some View {
        VStack(spacing: 24) {
            Spacer()

            switch viewModel.state {
            case .searching:
                searchingView(message: "Recherche d'un partenaire…")

            case .connecting:
                searchingView(message: "Connexion en cours…")

            case .connected(let peerName):
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.successGreen)
                    VStack(spacing: 6) {
                        Text("Connecté à")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(peerName)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                    }
                    Text("En attente du projet…")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

            case .receiving:
                progressView(message: "Réception en cours…")

            case .completed:
                if let error = viewModel.mergeError {
                    errorView(message: error)
                } else {
                    completedView(
                        message: "Synchronisation terminée",
                        detail: "\(viewModel.mergedExpenseCount) dépenses ajoutées"
                    )
                }

            case .error(let message):
                errorView(message: message)

            case .idle, .sending:
                EmptyView()
            }

            Spacer()

            if canCancel {
                cancelButton
            }
        }
        .padding()
    }

    // MARK: - Shared Components

    private func searchingView(message: String) -> some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(Color.accentPrimary)

            Text(message)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)

            Text("Assurez-vous que les deux téléphones\nsont proches et ont le Bluetooth activé")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
    }

    private func progressView(message: String) -> some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.accentPrimary)
            Text(message)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.secondary)
        }
    }

    private func completedView(message: String, detail: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.successGreen)

            VStack(spacing: 6) {
                Text(message)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                Text(detail)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Button {
                viewModel.reset()
                dismiss()
            } label: {
                Text("Terminé")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .padding(.horizontal, 32)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            VStack(spacing: 6) {
                Text("Erreur")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                role = nil
                viewModel.reset()
            } label: {
                Text("Réessayer")
                    .font(.system(.headline, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .padding(.horizontal, 32)
        }
    }

    private var cancelButton: some View {
        Button {
            role = nil
            viewModel.reset()
        } label: {
            Text("Annuler")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 8)
    }

    /// Indique si le bouton Annuler doit être affiché.
    private var canCancel: Bool {
        switch viewModel.state {
        case .searching, .connecting, .connected:
            return true
        default:
            return false
        }
    }

    // MARK: - Helpers

    private var cardBackground: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color(.secondarySystemGroupedBackground))
            : AnyShapeStyle(Color.cardBackground)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.25) : .black.opacity(0.06)
    }
}

#Preview {
    PeerSyncView(project: SampleData.sampleProject)
        .modelContainer(SampleData.container)
}
