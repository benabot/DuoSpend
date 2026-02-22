import SwiftUI

/// Logo DuoSpend : deux cœurs partenaires côte à côte, réutilisable à toutes tailles.
///
/// Fidèle à l'icône d'app : cœur bleu (partner1) légèrement en haut à gauche,
/// cœur rose (partner2) légèrement en bas à droite.
struct DuoLogoView: View {
    /// Taille globale du composant (width = height)
    var size: CGFloat = 44
    /// Affiche le fond dégradé violet (identique à l'icône d'app)
    var withBackground: Bool = false

    // Couleurs exactes de l'icône
    private let blueHeart  = Color(red: 0.035, green: 0.518, blue: 0.890)
    private let pinkHeart  = Color(red: 0.910, green: 0.263, blue: 0.576)
    private let gradientTop    = Color(red: 0.424, green: 0.361, blue: 0.906)
    private let gradientBottom = Color(red: 0.350, green: 0.280, blue: 0.850)

    var body: some View {
        ZStack {
            if withBackground {
                RoundedRectangle(cornerRadius: size * 0.22)
                    .fill(
                        LinearGradient(
                            colors: [gradientTop, gradientBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            duoHearts
        }
        .frame(width: size, height: size)
    }

    private var heartSize: CGFloat { size * 0.40 }
    private var spacing: CGFloat   { size * 0.04 }
    private var verticalShift: CGFloat { size * 0.05 }

    private var duoHearts: some View {
        HStack(spacing: spacing) {
            Image(systemName: "heart.fill")
                .font(.system(size: heartSize, weight: .bold))
                .foregroundStyle(withBackground ? blueHeart : Color.partner1)
                .offset(y: -verticalShift)

            Image(systemName: "heart.fill")
                .font(.system(size: heartSize, weight: .bold))
                .foregroundStyle(withBackground ? pinkHeart : Color.partner2)
                .offset(y: verticalShift)
        }
    }
}

#Preview {
    HStack(spacing: 20) {
        DuoLogoView(size: 28)
        DuoLogoView(size: 44)
        DuoLogoView(size: 64, withBackground: true)
        DuoLogoView(size: 88, withBackground: true)
    }
    .padding()
}
