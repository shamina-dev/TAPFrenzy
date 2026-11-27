import SwiftUI

struct HomeView: View {
    @AppStorage("highScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("hapticsEnabled") private var isHapticsEnabled = true

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackgroundView(isHazard: false)

                VStack(spacing: 28) {
                    Spacer()

                    // App Title
                    Text("TAP FRENZY")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color(red: 0.78, green: 0.94, blue: 1.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .tracking(2.5)
                        .shadow(color: .blue.opacity(0.45), radius: 12, x: 0, y: 4)

                    // Two Large Game Mode Buttons
                    VStack(spacing: 18) {
                        NavigationLink {
                            ContentView()
                                .navigationTitle("Tap Frenzy")
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbarBackground(.hidden, for: .navigationBar)
                        } label: {
                            GameModeCard(
                                title: "Tap Frenzy",
                                subtitle: "10s rapid tapping with combos & hazards",
                                bestScore: tapFrenzyHighScore,
                                gradientColors: [
                                    Color(red: 0.0, green: 0.58, blue: 1.0),
                                    Color(red: 0.14, green: 0.24, blue: 0.88)
                                ],
                                accentColor: .cyan
                            )
                        }
                        .buttonStyle(TapButtonStyle())

                        NavigationLink {
                            LightItUpView()
                                .toolbarBackground(.hidden, for: .navigationBar)
                        } label: {
                            GameModeCard(
                                title: "Light It Up",
                                subtitle: "60s reaction grid with 4 speed levels",
                                bestScore: lightItUpHighScore,
                                gradientColors: [
                                    Color(red: 1.0, green: 0.58, blue: 0.05),
                                    Color(red: 0.92, green: 0.18, blue: 0.45)
                                ],
                                accentColor: .yellow
                            )
                        }
                        .buttonStyle(TapButtonStyle())
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                HapticManager.shared.isEnabled = isHapticsEnabled
                HapticManager.shared.prepareGenerators()
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Mode Selection Card Button
private struct GameModeCard: View {
    let title: String
    let subtitle: String
    let bestScore: Int
    let gradientColors: [Color]
    let accentColor: Color

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.leading)

                Text("Best: \(bestScore)")
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.28)))
                    .padding(.top, 4)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                )
        )
        .shadow(color: accentColor.opacity(0.4), radius: 14, x: 0, y: 8)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
