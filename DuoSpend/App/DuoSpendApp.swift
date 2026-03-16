import SwiftUI
import SwiftData

@main
struct DuoSpendApp: App {
    let modelContainer: ModelContainer

    @State private var showingSplash = true
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingOnboarding = false

    init() {
        let schema = Schema([Project.self, Expense.self])
        let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.fr.beabot.DuoSpend"
        )
        let config: ModelConfiguration
        if let groupURL {
            let storeURL = groupURL.appendingPathComponent("DuoSpend.store")
            config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
        } else {
            config = ModelConfiguration(schema: schema, cloudKitDatabase: .none)
        }
        self.modelContainer = try! ModelContainer(for: schema, configurations: [config])

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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showingSplash = false
                    if !hasSeenOnboarding {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showingOnboarding = true
                        }
                    }
                }
            }
            .onOpenURL { url in handleDeepLink(url) }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(isPresented: $showingOnboarding)
                    .onDisappear { hasSeenOnboarding = true }
            }
        }
        .modelContainer(modelContainer)
    }

    /// Gère les deep links depuis le widget (`duospend://project`)
    private func handleDeepLink(_ url: URL) {
        // MVP : le scheme duospend:// ouvre simplement l'app
        // TODO: navigation vers le projet spécifique si besoin
        guard url.scheme == "duospend" else { return }
    }
}
