import SwiftUI
import SwiftData

@main
struct DuoSpendApp: App {
    @AppStorage("hasLaunched") private var hasLaunched = false
    @State private var showingSplash = true

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
                ProjectListView()

                if showingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .task {
                if !hasLaunched {
                    hasLaunched = true
                    try? await Task.sleep(for: .seconds(1.8))
                } else {
                    try? await Task.sleep(for: .seconds(0.3))
                }
                withAnimation(.easeOut(duration: 0.4)) {
                    showingSplash = false
                }
            }
        }
        .modelContainer(for: [Project.self, Expense.self])
    }
}
