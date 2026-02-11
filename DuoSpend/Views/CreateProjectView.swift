import SwiftUI

/// Formulaire de création d'un nouveau projet
struct CreateProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var onCreate: ((Project) -> Void)?

    @State private var name = ""
    @State private var partner1Name = ""
    @State private var partner2Name = ""
    @State private var budgetText = ""

    private var hasIdenticalNames: Bool {
        let p1 = partner1Name.trimmingCharacters(in: .whitespaces).lowercased()
        let p2 = partner2Name.trimmingCharacters(in: .whitespaces).lowercased()
        return !p1.isEmpty && !p2.isEmpty && p1 == p2
    }

    private var budgetValue: Decimal? {
        let cleaned = budgetText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned), value > 0 else { return nil }
        return value
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !partner1Name.trimmingCharacters(in: .whitespaces).isEmpty
            && !partner2Name.trimmingCharacters(in: .whitespaces).isEmpty
            && !hasIdenticalNames
            && budgetValue != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Projet") {
                    TextField("Voyage à Rome, Mariage, Bébé…", text: $name)
                }

                Section("Partenaires") {
                    TextField("Prénom (ex : Marie)", text: $partner1Name)
                    TextField("Prénom (ex : Thomas)", text: $partner2Name)
                    if hasIdenticalNames {
                        Text("Les noms des partenaires doivent être différents.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Budget du projet") {
                    TextField("Ex : 5 000", text: $budgetText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nouveau projet")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") { createProject() }
                        .disabled(!isFormValid)
                }
            }
        }
    }

    private func createProject() {
        guard let budget = budgetValue else { return }

        let project = Project(
            name: name.trimmingCharacters(in: .whitespaces),
            emoji: "💰",
            budget: budget,
            partner1Name: partner1Name.trimmingCharacters(in: .whitespaces),
            partner2Name: partner2Name.trimmingCharacters(in: .whitespaces)
        )

        modelContext.insert(project)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onCreate?(project)
        dismiss()
    }
}

#Preview {
    CreateProjectView()
        .modelContainer(SampleData.container)
}
