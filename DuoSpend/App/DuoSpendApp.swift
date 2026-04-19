import SwiftUI
import SwiftData

@main
struct DuoSpendApp: App {
    let modelContainer: ModelContainer
    private let screenshotRoute: ScreenshotRoute?

    @State private var showingSplash = true
    @State private var showingPaywallFromWidget = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("appTheme") private var appThemeRaw = 0

    init() {
        if let route = ScreenshotRoute.current {
            self.screenshotRoute = route
            self.modelContainer = Self.makeScreenshotContainer()
        } else {
            self.screenshotRoute = nil
            self.modelContainer = Self.makeDefaultContainer()
        }

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

                if let screenshotRoute {
                    ScreenshotRootView(route: screenshotRoute)
                } else {
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
            }
            .animation(.easeOut(duration: 0.4), value: showingSplash)
            .preferredColorScheme(AppTheme(rawValue: appThemeRaw)?.colorScheme)
            .onAppear {
                if screenshotRoute != nil {
                    #if DEBUG
                    StoreManager.shared.debugUnlock()
                    #endif
                    return
                }
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

    @MainActor
    private static func makeDefaultContainer() -> ModelContainer {
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
        return try! ModelContainer(for: schema, configurations: [config])
    }

    @MainActor
    private static func makeScreenshotContainer() -> ModelContainer {
        let container = try! ModelContainer(
            for: Project.self,
            Expense.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )

        let projects = ScreenshotSeed.projects
        for project in projects {
            container.mainContext.insert(project)
        }
        try? container.mainContext.save()
        return container
    }
}

private enum ScreenshotRoute: String {
    case projectList = "project-list"
    case projectDetail = "project-detail"
    case balance = "balance"
    case settingsPro = "settings-pro"

    static var current: ScreenshotRoute? {
        let processInfo = ProcessInfo.processInfo
        if let route = processInfo.environment["SCREENSHOT_ROUTE"].flatMap(Self.init(rawValue:)) {
            return route
        }
        if let index = processInfo.arguments.firstIndex(of: "--screenshot-route"),
           processInfo.arguments.indices.contains(index + 1) {
            return Self(rawValue: processInfo.arguments[index + 1])
        }
        return nil
    }
}

@MainActor
private enum ScreenshotSeed {
    static var projects: [Project] {
        [
            makeProject(
                name: "Italy Trip",
                emoji: "🇮🇹",
                budget: 1800,
                partner1: "Emma",
                partner2: "Jack",
                createdAt: date(2026, 4, 17),
                expenses: [
                    expense("Flights", 420.00, .partner1, .equal, date(2026, 4, 17)),
                    expense("Hotel", 286.50, .partner2, .equal, date(2026, 4, 16)),
                    expense("Restaurants", 84.50, .partner1, .equal, date(2026, 4, 15)),
                    expense("Museum tickets", 46.80, .partner2, .equal, date(2026, 4, 14)),
                    expense("Uber", 34.00, .partner1, .equal, date(2026, 4, 14)),
                    expense("Groceries", 126.50, .partner1, .custom(partner1Share: 60, partner2Share: 40), date(2026, 4, 13))
                ]
            ),
            makeProject(
                name: "Living Room Renovation",
                emoji: "🛠️",
                budget: 4200,
                partner1: "Sophie",
                partner2: "Liam",
                createdAt: date(2026, 4, 16),
                expenses: [
                    expense("Paint", 189.90, .partner1, .equal, date(2026, 4, 16)),
                    expense("Sofa", 799.00, .partner2, .equal, date(2026, 4, 15)),
                    expense("Delivery", 49.90, .partner2, .equal, date(2026, 4, 15)),
                    expense("Curtains", 119.00, .partner1, .equal, date(2026, 4, 13)),
                    expense("Lamp", 89.00, .partner2, .custom(partner1Share: 30, partner2Share: 70), date(2026, 4, 12)),
                    expense("Coffee table", 211.50, .partner2, .equal, date(2026, 4, 11))
                ]
            ),
            makeProject(
                name: "Lisbon Weekend",
                emoji: "✈️",
                budget: 650,
                partner1: "Chloe",
                partner2: "Noah",
                createdAt: date(2026, 4, 12),
                expenses: [
                    expense("Flights", 158.00, .partner2, .equal, date(2026, 4, 12)),
                    expense("Airbnb", 126.00, .partner1, .equal, date(2026, 4, 11)),
                    expense("Pastries", 22.50, .partner1, .equal, date(2026, 4, 11))
                ]
            ),
            makeProject(
                name: "Civil Wedding",
                emoji: "💍",
                budget: 3000,
                partner1: "Olivia",
                partner2: "Lucas",
                createdAt: date(2026, 4, 10),
                expenses: [
                    expense("Caterer", 520.00, .partner1, .equal, date(2026, 4, 10)),
                    expense("Rings", 399.00, .partner2, .equal, date(2026, 4, 9)),
                    expense("Flowers", 118.00, .partner1, .equal, date(2026, 4, 8)),
                    expense("Photographer", 155.00, .partner1, .custom(partner1Share: 70, partner2Share: 30), date(2026, 4, 8))
                ]
            ),
        ]
    }

    private static func makeProject(
        name: String,
        emoji: String,
        budget: Decimal,
        partner1: String,
        partner2: String,
        createdAt: Date,
        expenses: [Expense]
    ) -> Project {
        let project = Project(
            name: name,
            emoji: emoji,
            budget: budget,
            partner1Name: partner1,
            partner2Name: partner2,
            createdAt: createdAt
        )
        expenses.forEach { project.expenses.append($0) }
        return project
    }

    private static func expense(
        _ title: String,
        _ amount: Decimal,
        _ paidBy: PartnerRole,
        _ splitRatio: SplitRatio,
        _ date: Date
    ) -> Expense {
        Expense(title: title, amount: amount, paidBy: paidBy, splitRatio: splitRatio, date: date)
    }

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.calendar = Calendar(identifier: .gregorian)
        components.year = year
        components.month = month
        components.day = day
        return components.date ?? .now
    }
}

private struct ScreenshotRootView: View {
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    let route: ScreenshotRoute

    var body: some View {
        Group {
            switch route {
            case .projectList:
                ProjectListView()
            case .projectDetail:
                if let project = projects.dropFirst().first {
                    NavigationStack { ProjectDetailView(project: project) }
                }
            case .balance:
                if let project = projects.first {
                    NavigationStack { ProjectDetailView(project: project) }
                }
            case .settingsPro:
                NavigationStack { SettingsView() }
            }
        }
    }
}
