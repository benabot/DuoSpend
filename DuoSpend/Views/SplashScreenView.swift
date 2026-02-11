import SwiftUI

/// Écran de lancement animé avec le titre DuoSpend
struct SplashScreenView: View {
    @State private var heartScale: CGFloat = 0
    @State private var heartOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.accentPrimary.opacity(0.05), Color(.systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                Text("💕")
                    .font(.system(size: 48))
                    .scaleEffect(heartScale)
                    .opacity(heartOpacity)

                Text("DuoSpend")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentPrimary)
                    .opacity(titleOpacity)
                    .offset(y: titleOffset)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                heartScale = 1.0
                heartOpacity = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.35)) {
                titleOpacity = 1.0
                titleOffset = 0
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
