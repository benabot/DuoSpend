import SwiftUI

/// Vue permettant de visualiser et exporter l'icône d'app.
///
/// Pour exporter en 1024x1024 PNG :
/// 1. Ouvrir cette Preview dans Xcode
/// 2. Clic droit sur la preview → "Copy" ou faire un screenshot
/// 3. Redimensionner à 1024x1024 si nécessaire
/// 4. Placer dans Assets.xcassets/AppIcon.appiconset/
struct AppIconExporter: View {
    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)

            // Fond gradient violet
            let backgroundGradient = Gradient(colors: [
                Color(red: 0.424, green: 0.361, blue: 0.906),
                Color(red: 0.35, green: 0.28, blue: 0.85),
            ])
            context.fill(
                Path(roundedRect: rect, cornerRadius: 0),
                with: .linearGradient(
                    backgroundGradient,
                    startPoint: .init(x: 0, y: 0),
                    endPoint: .init(x: size.width, y: size.height)
                )
            )

            // Cœur 1 (partenaire 1 — bleu)
            let heart1 = context.resolveSymbol(id: "heart1")!
            context.draw(
                heart1,
                at: CGPoint(x: size.width * 0.38, y: size.height * 0.38)
            )

            // Cœur 2 (partenaire 2 — rose)
            let heart2 = context.resolveSymbol(id: "heart2")!
            context.draw(
                heart2,
                at: CGPoint(x: size.width * 0.62, y: size.height * 0.38)
            )

            // Symbole €
            let euroSign = context.resolveSymbol(id: "euro")!
            context.draw(
                euroSign,
                at: CGPoint(x: size.width * 0.5, y: size.height * 0.68)
            )
        } symbols: {
            Image(systemName: "heart.fill")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(Color(red: 0.035, green: 0.518, blue: 0.890))
                .tag("heart1")

            Image(systemName: "heart.fill")
                .font(.system(size: 120, weight: .bold))
                .foregroundStyle(Color(red: 0.910, green: 0.263, blue: 0.576))
                .tag("heart2")

            Text("€")
                .font(.system(size: 100, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .tag("euro")
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    AppIconExporter()
        .frame(width: 256, height: 256)
        .clipShape(RoundedRectangle(cornerRadius: 48))
}
