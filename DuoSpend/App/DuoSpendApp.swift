import SwiftUI
import SwiftData

@main
struct DuoSpendApp: App {
    let modelContainer: ModelContainer

    @State private var showingSplash = true
    @State private var showingPaywallFromWidget = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") private var appThemeRaw = 0

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

                // Onboarding directement dans le ZStack — évite tout flash entre splash et onboarding
                if !hasSeenOnboarding && !showingSplash {
                    OnboardingView(isPresented: Binding(
                        get: { !hasSeenOnboarding },
                        set: { if !$0 { hasSeenOnboarding = true } }
                    ))
                    .transition(.opacity)
                    .zIndex(2)
                }

                // Splash par-dessus tout pendant le chargement
                if showingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .allowsHitTesting(true)
                        .zIndex(3)
                }
            }
            .animation(.easeOut(duration: 0.4), value: showingSplash)
            .preferredColorScheme(AppTheme(rawValue: appThemeRaw)?.colorScheme)
            .onAppear {
                guard showingSplash else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    showingSplash = false
                }
            }
            .sheet(isPresented: $showingPaywallFromWidget) { PaywallView() }
            .onOpenURL { url in handleDeepLink(url) }
        }
        .modelContainer(modelContainer)
    }

    /// Gère les deep links depuis le widget
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "duospend" else { return }
        if url.host == "paywall" {
            showingPaywallFromWidget = true
        }
    }
}
