import SwiftUI

// MARK: - 1. Individual Grid Card View
struct LightUpCardView: View {
    let card: Card
    let level: Level
    let flash: CardFlash?
    let height: CGFloat
    let isInteractive: Bool
    let onTap: () -> Void

    private var fillStyle: LinearGradient {
        if let flash {
            switch flash {
            case .correct:
                return LinearGradient(
                    colors: [Color(red: 0.1, green: 0.85, blue: 0.35), Color(red: 0.0, green: 0.58, blue: 0.24)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .wrong:
                return LinearGradient(
                    colors: [Color(red: 0.98, green: 0.2, blue: 0.25), Color(red: 0.65, green: 0.05, blue: 0.12)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }

        if card.isLit {
            return LinearGradient(
                colors: level.litGradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }

        return LinearGradient(
            colors: [
                Color(red: 0.14, green: 0.15, blue: 0.28),
                Color(red: 0.10, green: 0.11, blue: 0.22)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderColor: Color {
        if let flash {
            return flash == .correct ? .green : .red
        }
        return card.isLit ? level.accentColor : Color(red: 0.26, green: 0.28, blue: 0.45)
    }

    private var shadowColor: Color {
        if let flash {
            return (flash == .correct ? Color.green : Color.red).opacity(0.65)
        }
        return card.isLit ? level.accentColor.opacity(0.85) : .clear
    }

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 18)
                .fill(fillStyle)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(borderColor, lineWidth: card.isLit || flash != nil ? 2.5 : 1)
                )
                .shadow(color: shadowColor, radius: card.isLit || flash != nil ? 14 : 0, x: 0, y: 4)
                .frame(height: height)
                .scaleEffect(card.isLit ? 1.08 : 1.0)
                .animation(.easeInOut(duration: 0.16), value: card.isLit)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isInteractive)
    }
}

// MARK: - 2. Light It Up Game Over Modal
struct LightItUpGameOverModalView: View {
    let score: Int
    let highScore: Int
    let isNewRecord: Bool
    let hits: Int
    let wrongTaps: Int
    let livesRemaining: Int
    let endedOutOfLives: Bool
    let levelReached: Level
    let onPlayAgain: () -> Void

    private var accuracyText: String {
        let totalAttempts = hits + wrongTaps
        guard totalAttempts > 0 else { return "0%" }
        let pct = Int((Double(hits) / Double(totalAttempts)) * 100.0)
        return "\(pct)%"
    }

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

                        Text("NEW HIGH SCORE!")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.yellow)
                            .shadow(color: Color.yellow.opacity(0.5), radius: 6, x: 0, y: 2)
                    } else {
                        Text(endedOutOfLives ? "OUT OF LIVES" : "ROUND COMPLETE")
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundColor(endedOutOfLives ? .red : .white)
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
                                colors: [Color.white, Color.yellow],
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
                                .strokeBorder(isNewRecord ? Color.yellow.opacity(0.4) : Color.orange.opacity(0.25), lineWidth: 1)
                        )
                )

                HStack(spacing: 12) {
                    StatCard(title: "BEST RECORD", value: "\(highScore)", icon: "crown.fill", color: .yellow)
                    StatCard(title: "ACCURACY", value: accuracyText, icon: "scope", color: .green)
                }

                HStack(spacing: 12) {
                    StatCard(title: "CARDS HIT", value: "\(hits)", icon: "checkmark.circle.fill", color: .cyan)
                    StatCard(title: "LIVES LEFT", value: "\(livesRemaining)/3", icon: "heart.fill", color: .red)
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
                            colors: [Color.orange, Color.pink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadow(color: Color.orange.opacity(0.55), radius: 12, x: 0, y: 6)
                }
                .buttonStyle(TapButtonStyle())
                .padding(.top, 4)
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
