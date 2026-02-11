import SwiftUI

extension Color {
    /// Violet/indigo vif — couleur d'accent principale
    static let accentPrimary = Color("AccentPrimary")
    /// Bleu chaleureux — partenaire 1
    static let partner1 = Color("Partner1Color")
    /// Rose/corail — partenaire 2
    static let partner2 = Color("Partner2Color")
    /// Fond de card adaptatif light/dark
    static let cardBackground = Color("CardBackground")
    /// Vert doux — équilibre
    static let successGreen = Color("SuccessGreen")
    /// Fond chaud crème en light, system background en dark
    static let warmBackground = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? .systemBackground
            : UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1.0)
    })
}
