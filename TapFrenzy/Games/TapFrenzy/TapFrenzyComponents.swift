import SwiftUI

// MARK: - 1. Hero Score Display
struct HeroScoreView: View {
    let score: Int
    let highScore: Int
    let phase: GamePhase

    @State private var scoreScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 4) {
            if score > highScore && highScore > 0 && phase == .playing {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .bold))
                    Text("NEW RECORD!")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                }
                .foregroundColor(.yellow)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.18))
                        .overlay(Capsule().strokeBorder(Color.yellow.opacity(0.5), lineWidth: 1))
                )
                .transition(.scale.combined(with: .opacity))
            }

            Text("\(score)")
                .font(.system(size: 88, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.85, green: 0.95, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .contentTransition(.numericText())
                .shadow(color: Color.blue.opacity(0.45), radius: 16, x: 0, y: 6)
                .scaleEffect(scoreScale)
                .animation(.spring(response: 0.18, dampingFraction: 0.5), value: scoreScale)
        }
        .onChange(of: score) { _, _ in
            scoreScale = 1.15
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scoreScale = 1.0
            }
        }
    }
}

// MARK: - 2. Tactile 3D Hero Tap Button
struct TapTargetButton: View {
    let phase: GamePhase
    let isHazard: Bool
    let hazardShake: Bool
    let buttonSize: CGFloat
    let onTap: () -> Void

    @State private var isPressed: Bool = false
    @State private var idlePulse: Bool = false
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.0

    var body: some View {
        Button(action: {
            triggerRipple()
            onTap()
        }) {
            ZStack {
                Circle()
                    .strokeBorder(
                        (isHazard ? Color.red : Color.cyan).opacity(rippleOpacity),
                        lineWidth: 3
                    )
                    .frame(width: buttonSize * rippleScale, height: buttonSize * rippleScale)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isHazard ? Color.red : Color.cyan).opacity(isHazard ? 0.45 : 0.25),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: buttonSize * 0.4,
                            endRadius: buttonSize * 0.72
                        )
                    )
                    .frame(width: buttonSize * 1.45, height: buttonSize * 1.45)
                    .scaleEffect(idlePulse && phase == .idle ? 1.08 : 1.0)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.25),
                                Color.black.opacity(0.55),
                                Color.white.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: buttonSize, height: buttonSize)
                    .shadow(
                        color: (isHazard ? Color.red : Color.blue).opacity(0.65),
                        radius: isPressed ? 8 : 18,
                        x: 0,
                        y: isPressed ? 4 : 10
                    )

                Circle()
                    .fill(
                        LinearGradient(
                            colors: isHazard
                                ? [Color(red: 1.0, green: 0.15, blue: 0.25), Color(red: 0.7, green: 0.0, blue: 0.12)]
                                : [Color(red: 0.0, green: 0.55, blue: 1.0), Color(red: 0.0, green: 0.25, blue: 0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: buttonSize - 12, height: buttonSize - 12)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.65), Color.clear],
                                    startPoint: .top,
                                    endPoint: .center
                                ),
                                lineWidth: 2.5
                            )
                            .padding(2)
                    )

                VStack(spacing: 4) {
                    if phase == .idle {
                        Image(systemName: "hand.tap.fill")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                            .symbolEffect(.bounce, options: .repeating)

                        Text("START")
                            .font(.system(size: 26, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
                    } else if isHazard {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: buttonSize < 140 ? 22 : 32, weight: .bold))
                            .foregroundColor(.yellow)
                            .symbolEffect(.pulse)

                        Text("DON'T!")
                            .font(.system(size: buttonSize < 140 ? 18 : 28, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.6), radius: 3, x: 0, y: 2)
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: buttonSize < 140 ? 16 : 22, weight: .heavy))
                            .foregroundColor(.white.opacity(0.85))

                        Text("TAP!")
                            .font(.system(size: buttonSize < 140 ? 24 : 36, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                    }
                }
            }
            .scaleEffect(isPressed ? 0.92 : 1.0)
            .offset(x: hazardShake ? -8 : 0)
        }
        .buttonStyle(SquishButtonStyle(isPressedBinding: $isPressed))
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                idlePulse.toggle()
            }
        }
    }

    private func triggerRipple() {
        rippleScale = 1.0
        rippleOpacity = 0.9
        withAnimation(.easeOut(duration: 0.35)) {
            rippleScale = 1.45
            rippleOpacity = 0.0
        }
    }
}

struct SquishButtonStyle: ButtonStyle {
    @Binding var isPressedBinding: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressedBinding = newValue
            }
    }
}

// MARK: - 3. Star Rush Bonus Button (+5)
struct BonusGoldTargetView: View {
    let position: CGPoint
    let onBonusTap: () -> Void

    @State private var rotateSunburst: Double = 0
    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        Button(action: onBonusTap) {
            ZStack {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 68))
                    .foregroundColor(Color.yellow.opacity(0.35))
                    .rotationEffect(.degrees(rotateSunburst))

                Circle()
                    .strokeBorder(Color.yellow.opacity(0.6), lineWidth: 2)
                    .frame(width: 62, height: 62)
                    .scaleEffect(pulseScale)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.9, blue: 0.4),
                                Color(red: 1.0, green: 0.65, blue: 0.0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.yellow.opacity(0.9), radius: 12, x: 0, y: 0)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.7), lineWidth: 2)
                    )

                VStack(spacing: 0) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundColor(Color.black.opacity(0.8))

                    Text("+5")
                        .font(.system(size: 17, weight: .black, design: .rounded))
                        .foregroundColor(Color.black.opacity(0.9))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .position(position)
        .transition(.scale(scale: 0.2).combined(with: .opacity))
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotateSunburst = 360
            }
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                pulseScale = 1.25
            }
        }
    }
}

// MARK: - 4. Game Over Victory & Stats Modal
struct GameOverModalView: View {
    let score: Int
    let highScore: Int
    let isNewRecord: Bool
    let maxCombo: Int
    let totalTaps: Int
    let onPlayAgain: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    if isNewRecord {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.2))
                                .frame(width: 80, height: 80)

                            Image(systemName: "trophy.fill")
                                .font(.system(size: 42))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.yellow, Color.orange],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .shadow(color: Color.yellow.opacity(0.8), radius: 14, x: 0, y: 4)
                        }

                        Text("🎉 NEW HIGH SCORE!")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 6, x: 0, y: 2)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 70, height: 70)

                            Image(systemName: "flag.checkered")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.cyan)
                        }

                        Text("TIME'S UP!")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 8)

                VStack(spacing: 4) {
                    Text("FINAL SCORE")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                        .tracking(1.5)

                    Text("\(score)")
                        .font(.system(size: 64, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white, Color.cyan],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(isNewRecord ? Color.yellow.opacity(0.4) : Color.cyan.opacity(0.2), lineWidth: 1)
                        )
                )

                HStack(spacing: 12) {
                    StatCard(title: "BEST RECORD", value: "\(highScore)", icon: "crown.fill", color: .yellow)
                    StatCard(title: "MAX COMBO", value: "\(maxCombo)x", icon: "flame.fill", color: .orange)
                }

                HStack(spacing: 12) {
                    StatCard(title: "TOTAL TAPS", value: "\(totalTaps)", icon: "hand.tap.fill", color: .cyan)
                    StatCard(title: "SPEED", value: String(format: "%.1f/s", Double(totalTaps) / 10.0), icon: "bolt.fill", color: .green)
                }

                Button(action: onPlayAgain) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))

                        Text("PLAY AGAIN")
                            .font(.system(size: 18, weight: .black, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.0, green: 0.6, blue: 1.0), Color(red: 0.1, green: 0.3, blue: 0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.blue.opacity(0.6), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(TapButtonStyle())
                .padding(.top, 8)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2), Color.white.opacity(0.04)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .shadow(color: Color.black.opacity(0.7), radius: 30, x: 0, y: 15)
            )
            .padding(.horizontal, 28)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }
}

// MARK: - 5. Idle Hero Welcome Card
struct IdleWelcomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.shield.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.cyan, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("TAP FRENZY")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.white, Color(red: 0.8, green: 0.95, blue: 1.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .tracking(2)
            }
            .shadow(color: Color.cyan.opacity(0.5), radius: 10, x: 0, y: 3)

            HStack(spacing: 8) {
                GuidePill(icon: "bolt.fill", title: "Combos", color: .cyan)
                GuidePill(icon: "exclamationmark.triangle.fill", title: "Avoid Red", color: .red)
                GuidePill(icon: "star.fill", title: "+5 Gold", color: .yellow)
            }
        }
        .padding(.top, 4)
    }
}
