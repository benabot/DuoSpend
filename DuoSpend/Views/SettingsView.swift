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
                Text("Fait avec ❤️ à Montpellier")
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
    @State private var pdfURL: URL?
    @State private var showingShare = false

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
        .sheet(isPresented: $showingShare) {
            if let url = pdfURL {
                ActivityView(activityItems: [url])
            }
        }
    }

    private func exportPDF(for project: Project) {
        let balance = BalanceCalculator.calculate(expenses: project.expenses)
        guard let url = try? PDFExportService.generatePDF(
            project: project,
            expenses: project.expenses,
            balance: balance
        ) else { return }
        pdfURL = url
        showingShare = true
    }
}

// MARK: - Wrapper UIActivityViewController

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .modelContainer(SampleData.container)
}
