import SwiftUI

/// Formulaire de création d'un nouveau projet
struct CreateProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

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
            ZStack {
                // Fond dégradé
                LinearGradient(
                    colors: [Color.accentPrimary.opacity(0.12), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .center
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // Logo + titre section
                        DuoLogoView(size: 64, withBackground: true)
                            .padding(.top, 8)

                        // Section Projet
                        FormSection(
                            icon: "folder.fill",
                            iconColor: Color.accentPrimary,
                            title: "Projet"
                        ) {
                            TextField("Voyage à Rome, Mariage, Bébé…", text: $name)
                                .font(.body)
                        }

                        // Section Partenaires
                        FormSection(
                            icon: "heart.fill",
                            iconColor: Color.partner1,
                            title: "Partenaires"
                        ) {
                            VStack(spacing: 0) {
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.partner1)
                                        .frame(width: 8, height: 8)
                                    TextField("Prénom (ex : Marie)", text: $partner1Name)
                                        .font(.body)
                                }
                                Divider().padding(.vertical, 10)
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.partner2)
                                        .frame(width: 8, height: 8)
                                    TextField("Prénom (ex : Thomas)", text: $partner2Name)
                                        .font(.body)
                                }
                            }
                            if hasIdenticalNames {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.orange)
                                        .font(.caption)
                                    Text("Les prénoms doivent être différents.")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                                .padding(.top, 4)
                            }
                        }

                        // Section Budget
                        FormSection(
                            icon: "eurosign.circle.fill",
                            iconColor: Color.successGreen,
                            title: "Budget du projet"
                        ) {
                            HStack {
                                TextField("Ex : 5 000", text: $budgetText)
                                    .keyboardType(.decimalPad)
                                    .font(.body)
                                Text("€")
                                    .foregroundStyle(.secondary)
                                    .font(.body.weight(.semibold))
                            }
                        }

                        // Bouton Créer
                        Button(action: createProject) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                Text("Créer le projet")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                isFormValid
                                    ? LinearGradient(colors: [Color.accentPrimary, Color.accentPrimary.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [Color(.systemGray4), Color(.systemGray4)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
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
        dismiss()
    }
}

// MARK: - FormSection

/// Carte de section générique avec icône colorée et titre
private struct FormSection<Content: View>: View {
    let icon: String
    let iconColor: Color
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // En-tête
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.system(size: 15, weight: .semibold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }

            // Contenu dans une carte blanche
            VStack(alignment: .leading, spacing: 4) {
                content()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: iconColor.opacity(0.08), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(iconColor.opacity(0.15), lineWidth: 1)
            )
        }
    }
}

#Preview {
    CreateProjectView()
        .modelContainer(SampleData.container)
}
