import SwiftUI
import SwiftData

/// Écran de réglages généraux accessible depuis la liste de projets
struct SettingsView: View {
    @AppStorage("appTheme") private var appThemeRaw = 0
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]

    @State private var showingPaywall = false
    @State private var showingExportPicker = false
    @State private var showingDeleteAlert = false

    private let storeManager = StoreManager.shared

    var body: some View {
        Form {
            Section {
                Picker("Apparence", selection: $appThemeRaw) {
                    ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                        Text(theme.label).tag(theme.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Label("Apparence", systemImage: "paintbrush")
            }

            Section {
                if storeManager.isUnlocked {
                    Label("DuoSpend Pro ✓", systemImage: "star.fill")
                        .foregroundStyle(Color.successGreen)
                } else {
                    Button("Passer à DuoSpend Pro") { showingPaywall = true }
                }
                Button("Restaurer mes achats") {
                    Task { await storeManager.restorePurchases() }
                }
            } header: {
                Label("DuoSpend Pro", systemImage: "star.fill")
            }

            Section {
                Button("Exporter un projet en PDF") { showingExportPicker = true }
                Button("Supprimer toutes les données", role: .destructive) {
                    showingDeleteAlert = true
                }
            } header: {
                Label("Données", systemImage: "externaldrive")
            }

            Section {
                LabeledContent("Version") {
                    Text(appVersion).foregroundStyle(.secondary)
                }
                if let privacyURL = URL(string: "https://beabot.fr/duospend/privacy") {
                    Link("Politique de confidentialité", destination: privacyURL)
                }
                if let supportURL = URL(string: "https://beabot.fr/duospend/support") {
                    Link("Support", destination: supportURL)
                }
                #if DEBUG
                NavigationLink(destination: PaywallDebugView()) {
                    Label("Debug Paywall 🐞", systemImage: "ladybug")
                }
                #endif
            } header: {
                Label("À propos", systemImage: "info.circle")
            } footer: {
                Text("Fait avec ❤️ à Lille")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle("Réglages")
        .navigationBarTitleDisplayMode(.large)
        .font(.system(.body, design: .rounded))
        .sheet(isPresented: $showingPaywall) { PaywallView() }
        .sheet(isPresented: $showingExportPicker) {
            ProjectExportPickerView(projects: projects)
        }
        .alert("Êtes-vous sûr ?", isPresented: $showingDeleteAlert) {
            Button("Supprimer", role: .destructive, action: deleteAllData)
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Cette action est irréversible. Tous vos projets et dépenses seront supprimés.")
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(version) (\(build))"
    }

    private func deleteAllData() {
        for project in projects {
            modelContext.delete(project)
        }
    }
}

// MARK: - Sélecteur de projet pour export PDF

private struct ProjectExportPickerView: View {
    let projects: [Project]
    @Environment(\.dismiss) private var dismiss
    /// Toutes les dépenses via @Query — garantit des données fraîches.
    /// project.expenses est lazy-loaded et peut être vide hors contexte propriétaire.
    @Query private var allExpenses: [Expense]

    var body: some View {
        NavigationStack {
            List(projects) { project in
                Button {
                    exportPDF(for: project)
                } label: {
                    Label("\(project.emoji) \(project.name)", systemImage: "doc.fill")
                        .font(.system(.body, design: .rounded))
                }
            }
            .navigationTitle("Choisir un projet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
        }
    }

    private func exportPDF(for project: Project) {
        let expenses = allExpenses.filter {
            $0.project?.persistentModelID == project.persistentModelID
        }
        let balance = BalanceCalculator.calculate(expenses: expenses)
        guard let url = try? PDFExportService.generatePDF(
            project: project,
            expenses: expenses,
            balance: balance
        ) else { return }

        // UIActivityViewController doit être présenté impérativement —
        // l'embarquer dans un .sheet SwiftUI depuis une sheet existante produit un onglet vide.
        let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let root = scene.keyWindow?.rootViewController else { return }
        let presenter = root.presentedViewController ?? root
        presenter.present(avc, animated: true)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(SampleData.container)
}
