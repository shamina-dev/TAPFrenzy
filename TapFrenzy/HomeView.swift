import SwiftUI

struct HomeView: View {
    @AppStorage("highScore") private var tapFrenzyHighScore = 0
    @AppStorage("lightItUpHighScore") private var lightItUpHighScore = 0
    @AppStorage("lightItUpRoundLength") private var lightItUpRoundLength = 60
    @AppStorage("hapticsEnabled") private var isHapticsEnabled = true

    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackgroundView(isHazard: false)

                VStack(spacing: 28) {
                    // Top Settings Button
                    HStack {
                        Spacer()

                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 42, height: 42)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.14, green: 0.16, blue: 0.30))
                                        .overlay(
                                            Circle()
                                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1.2)
                                        )
                                )
                        }
                        .buttonStyle(TapButtonStyle())
                        .accessibilityLabel("Settings")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)

                    Spacer()

                    // App Title
                    Text("MY GAMES")
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
                                subtitle: "\(lightItUpRoundLength)s reaction grid with 4 speed levels",
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
            .sheet(isPresented: $showSettings) {
                SettingsSheetView()
            }
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

// MARK: - Settings Sheet
private struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("lightItUpRoundLength") private var roundLength = 60
    @AppStorage("hapticsEnabled") private var isHapticsEnabled = true

    private let roundOptions = [30, 60, 90]

    var body: some View {
        NavigationStack {
            ZStack {
                GameBackgroundView(isHazard: false)

                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("LIGHT IT UP ROUND LENGTH")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1.2)

                        HStack(spacing: 12) {
                            ForEach(roundOptions, id: \.self) { seconds in
                                let isSelected = roundLength == seconds
                                Button {
                                    roundLength = seconds
                                    HapticManager.shared.tap(combo: 1)
                                } label: {
                                    Text("\(seconds)s")
                                        .font(.system(size: 18, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(
                                                    isSelected
                                                        ? LinearGradient(
                                                            colors: [Color.orange, Color.pink],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                        : LinearGradient(
                                                            colors: [Color(red: 0.14, green: 0.15, blue: 0.28), Color(red: 0.11, green: 0.12, blue: 0.24)],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .strokeBorder(
                                                            isSelected ? Color.yellow : Color(red: 0.26, green: 0.28, blue: 0.45),
                                                            lineWidth: isSelected ? 2 : 1
                                                        )
                                                )
                                        )
                                }
                                .buttonStyle(TapButtonStyle())
                            }
                        }
                    }

                    Toggle(isOn: $isHapticsEnabled) {
                        Text("Haptic Feedback")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .tint(.cyan)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 0.14, green: 0.15, blue: 0.28))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color(red: 0.26, green: 0.28, blue: 0.45), lineWidth: 1)
                            )
                    )
                    .onChange(of: isHapticsEnabled) { _, newValue in
                        HapticManager.shared.isEnabled = newValue
                        if newValue {
                            HapticManager.shared.tap(combo: 1)
                        }
                    }

                    Spacer()
                }
                .padding(22)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
        .preferredColorScheme(.dark)
        .presentationDetents([.medium])
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
