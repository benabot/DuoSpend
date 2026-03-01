import SwiftUI
import SwiftData

@main
struct DuoSpendApp: App {
    @State private var showingSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingOnboarding = false

    init() {
        let largeFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        let inlineFont = UIFont.systemFont(ofSize: 17, weight: .semibold)

        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        if let roundedDesc = largeFont.fontDescriptor.withDesign(.rounded) {
            appearance.largeTitleTextAttributes = [
                .font: UIFont(descriptor: roundedDesc, size: 34),
                .foregroundColor: UIColor(Color.accentPrimary),
            ]
        }
        if let roundedInline = inlineFont.fontDescriptor.withDesign(.rounded) {
            appearance.titleTextAttributes = [
                .font: UIFont(descriptor: roundedInline, size: 17),
                .foregroundColor: UIColor(Color.accentPrimary),
            ]
        }

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Fond de base toujours visible — évite l'écran noir au démarrage
                Color(.systemBackground).ignoresSafeArea()

                ProjectListView()

                // Splash par-dessus — fond opaque garanti par SplashScreenView
                if showingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .allowsHitTesting(true)
                        .zIndex(1)
                }
            }
            .animation(.easeOut(duration: 0.4), value: showingSplash)
            .onAppear {
                guard showingSplash else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingSplash = false
                    if !hasSeenOnboarding {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingOnboarding = true
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(isPresented: $showingOnboarding)
                    .onDisappear { hasSeenOnboarding = true }
            }
        }
        .modelContainer(for: [Project.self, Expense.self])
    }
}
