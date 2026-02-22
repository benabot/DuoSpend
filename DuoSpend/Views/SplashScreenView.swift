import SwiftUI

/// Ecran de lancement anime avec le titre DuoSpend
struct SplashScreenView: View {
    @State private var circleScale: CGFloat = 0
    @State private var heartScale: CGFloat = 0
    @State private var heartOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var subtitleOpacity: Double = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentPrimary.opacity(0.08), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.accentPrimary.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .scaleEffect(circleScale)

                    DuoLogoView(size: 88, withBackground: false)
                        .scaleEffect(heartScale)
                        .opacity(heartOpacity)
                }

                Text("DuoSpend")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentPrimary)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)

                Text("G\u{00E9}rez vos d\u{00E9}penses \u{00E0} deux \u{1F495}")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(subtitleOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5)) {
                circleScale = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                heartScale = 1.0
                heartOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35)) {
                titleOpacity = 1.0
                titleOffset = 0
            }
            withAnimation(.easeIn(duration: 0.4).delay(0.5)) {
                subtitleOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
