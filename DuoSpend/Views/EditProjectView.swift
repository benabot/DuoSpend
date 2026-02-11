import SwiftUI

/// Sheet d'edition d'un projet existant
struct EditProjectView: View {
    @Bindable var project: Project
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var partner1Name: String
    @State private var partner2Name: String
    @State private var budgetText: String

    private var hasIdenticalNames: Bool {
        let p1 = partner1Name.trimmingCharacters(in: .whitespaces).lowercased()
        let p2 = partner2Name.trimmingCharacters(in: .whitespaces).lowercased()
        return !p1.isEmpty && !p2.isEmpty && p1 == p2
    }

    private var parsedBudget: Decimal? {
        let cleaned = budgetText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        guard !cleaned.isEmpty, let value = Decimal(string: cleaned), value > 0 else { return nil }
        return value
    }

    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !partner1Name.trimmingCharacters(in: .whitespaces).isEmpty
            && !partner2Name.trimmingCharacters(in: .whitespaces).isEmpty
            && !hasIdenticalNames
            && parsedBudget != nil
    }

    init(project: Project) {
        self.project = project
        _name = State(initialValue: project.name)
        _partner1Name = State(initialValue: project.partner1Name)
        _partner2Name = State(initialValue: project.partner2Name)
        _budgetText = State(initialValue: "\(project.budget)")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Voyage \u{00E0} Rome, Mariage, B\u{00E9}b\u{00E9}\u{2026}", text: $name)
                } header: {
                    Text("Projet").foregroundStyle(Color.accentPrimary)
                }

                Section {
                    TextField("Pr\u{00E9}nom (ex : Marie)", text: $partner1Name)
                    TextField("Pr\u{00E9}nom (ex : Thomas)", text: $partner2Name)
                    if hasIdenticalNames {
                        Text("Les noms des partenaires doivent \u{00EA}tre diff\u{00E9}rents.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Partenaires").foregroundStyle(Color.accentPrimary)
                }

                Section {
                    TextField("Ex : 5 000", text: $budgetText)
                        .keyboardType(.decimalPad)
                } header: {
                    Text("Budget du projet").foregroundStyle(Color.accentPrimary)
                }
            }
            .navigationTitle("Modifier le projet")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { saveProject() }
                        .disabled(!isFormValid)
                        .tint(Color.accentPrimary)
                }
            }
        }
    }

    private func saveProject() {
        guard let budget = parsedBudget else { return }
        project.name = name.trimmingCharacters(in: .whitespaces)
        project.emoji = "\u{1F4B0}"
        project.budget = budget
        project.partner1Name = partner1Name.trimmingCharacters(in: .whitespaces)
        project.partner2Name = partner2Name.trimmingCharacters(in: .whitespaces)
        dismiss()
    }
}

#Preview {
    EditProjectView(project: SampleData.sampleProject)
        .modelContainer(SampleData.container)
}
