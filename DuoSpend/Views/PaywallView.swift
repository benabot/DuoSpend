import SwiftUI
import StoreKit

/// Paywall — achat unique pour débloquer les projets illimités
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var storeManager = StoreManager.shared

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {

                    DuoLogoView(size: 60, withBackground: true)
                        .padding(.top, 24)

                    // ── Titre ─────────────────────────────────────
                    VStack(spacing: 8) {
                        Text("Passez à DuoSpend Pro")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        Text("Créez autant de projets que vous voulez")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 16)

                    // ── Bullets ───────────────────────────────────
                    VStack(alignment: .leading, spacing: 14) {
                        bulletPoint("Projets illimités")
                        bulletPoint("Widgets pour l'écran d'accueil")
                        bulletPoint("Achat unique, pas d'abonnement")
                        bulletPoint("Soutenez un développeur indépendant")
                    }
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // ── Bouton achat ──────────────────────────────
                    VStack(spacing: 12) {
                        if storeManager.isLoading {
                            ProgressView()
                                .padding(.vertical, 8)
                        } else {
                            Button {
                                Task { await storeManager.purchase() }
                            } label: {
                                if let product = storeManager.product {
                                    Text("Débloquer pour \(product.displayPrice)")
                                        .font(.system(.body, design: .rounded))
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Text("Chargement…")
                                        .font(.system(.body, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .tint(Color.accentPrimary)
                            .disabled(storeManager.product == nil || storeManager.isLoading)
                        }

                        if let error = storeManager.purchaseError {
                            Text(error)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.red)
                                .multilineTextAlignment(.center)
                        }

                        Button {
                            Task { await storeManager.restorePurchases() }
                        } label: {
                            Text("Restaurer mes achats")
                                .font(.system(.caption, design: .rounded))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 24)

                    // ── Légal ─────────────────────────────────────
                    Text("Paiement unique via votre compte Apple. Aucun abonnement.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.warmBackground.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
            .onChange(of: storeManager.isUnlocked) { _, newValue in
                if newValue { dismiss() }
            }
        }
    }

    // MARK: - Helpers

    private func bulletPoint(_ label: LocalizedStringKey) -> some View {
        Label(label, systemImage: "checkmark.circle.fill")
            .font(.system(.body, design: .rounded))
            .foregroundStyle(Color.successGreen)
    }
}

#Preview {
    PaywallView()
}
