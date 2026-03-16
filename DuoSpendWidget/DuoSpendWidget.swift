import WidgetKit
import SwiftUI
import AppIntents

/// Intent de configuration du widget (vide pour MVP — affiche le projet le plus récent)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "DuoSpend" }
    static var description: IntentDescription { "Affiche la balance du projet en cours." }
}

/// Widget principal DuoSpend
struct DuoSpendWidget: Widget {
    let kind: String = "DuoSpendWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: DuoSpendWidgetProvider()
        ) { entry in
            DuoSpendWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("DuoSpend")
        .description("Balance de votre projet en cours.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct DuoSpendWidgetBundle: WidgetBundle {
    var body: some Widget {
        DuoSpendWidget()
    }
}
