import SwiftUI

// MARK: - Modèle de page

private struct OnboardingPage {
    let emoji: String
    let title: String
    let description: String
    let accentColor: Color
    let iconName: String
}

// MARK: - Vue principale

/// Onboarding affiché uniquement à la première ouverture
struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "💑",
            title: "À deux, c'est\nmieux géré",
            description: "DuoSpend suit vos dépenses communes et répond à une seule question : qui doit combien à qui ?",
            accentColor: .accentPrimary,
            iconName: "heart.fill"
        ),
        OnboardingPage(
            emoji: "🗂️",
            title: "Organisez par\nprojet",
            description: "Voyage, mariage, colocation, travaux… Créez un projet pour chaque aventure commune et gardez un œil sur le budget.",
            accentColor: .partner1,
            iconName: "folder.fill"
        ),
        OnboardingPage(
            emoji: "🔒",
            title: "Privé et\nhors-ligne",
            description: "Aucune inscription. Aucun cloud imposé. Vos données restent sur votre iPhone. iCloud sync disponible si vous le souhaitez.",
            accentColor: .successGreen,
            iconName: "lock.shield.fill"
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            // Fond adaptatif selon la page
            Color.warmBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Skip en haut à droite
                HStack {
                    Spacer()
                    if currentPage < pages.count - 1 {
                        Button("Passer") {
                            dismiss()
                        }
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding()
                    }
                }

                // Pages swipables
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                // Bas : indicateurs + bouton
                VStack(spacing: 28) {
                    // Indicateurs de page
                    HStack(spacing: 8) {
                        ForEach(pages.indices, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage
                                      ? pages[currentPage].accentColor
                                      : Color.secondary.opacity(0.25))
                                .frame(width: index == currentPage ? 28 : 8, height: 8)
                                .animation(.spring(duration: 0.4), value: currentPage)
                        }
                    }

                    // Bouton principal
                    Button(action: advance) {
                        HStack(spacing: 8) {
                            Text(currentPage < pages.count - 1 ? "Continuer" : "C'est parti !")
                                .fontWeight(.semibold)
                            Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "checkmark")
                                .font(.subheadline.weight(.semibold))
                        }
                        .font(.system(.body, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(pages[currentPage].accentColor)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: pages[currentPage].accentColor.opacity(0.35), radius: 10, x: 0, y: 5)
                    }
                    .animation(.spring(duration: 0.3), value: currentPage)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 48)
                .padding(.top, 8)
            }
        }
    }

    private func advance() {
        if currentPage < pages.count - 1 {
            withAnimation { currentPage += 1 }
        } else {
            dismiss()
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            isPresented = false
        }
    }
}

// MARK: - Vue d'une page

private struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var appeared = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Illustration avec cercles concentriques
            ZStack {
                Circle()
                    .fill(page.accentColor.opacity(0.07))
                    .frame(width: 200, height: 200)
                    .scaleEffect(appeared ? 1.0 : 0.6)

                Circle()
                    .fill(page.accentColor.opacity(0.13))
                    .frame(width: 150, height: 150)
                    .scaleEffect(appeared ? 1.0 : 0.6)

                Text(page.emoji)
                    .font(.system(size: 80))
                    .scaleEffect(appeared ? 1.0 : 0.4)
                    .opacity(appeared ? 1.0 : 0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: appeared)

            // Textes
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1.0 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(.spring(response: 0.5).delay(0.1), value: appeared)

                Text(page.description)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
                    .opacity(appeared ? 1.0 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(response: 0.5).delay(0.2), value: appeared)
            }

            Spacer()
            // Espace pour les contrôles du bas
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            appeared = true
        }
        .onDisappear {
            // Reset pour que l'animation rejoue si on revient en arrière
            appeared = false
        }
    }
}

// MARK: - Preview

#Preview("Onboarding complet") {
    OnboardingView(isPresented: .constant(true))
}

#Preview("Page 1 seule") {
    OnboardingView(isPresented: .constant(true))
}
