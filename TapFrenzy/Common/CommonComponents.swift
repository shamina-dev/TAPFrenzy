import SwiftUI

// MARK: - 1. Cyber Arcade Animated Background
struct GameBackgroundView: View {
    let isHazard: Bool
    @State private var orbAnimate: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.10),
                    Color(red: 0.08, green: 0.07, blue: 0.18),
                    Color(red: 0.04, green: 0.03, blue: 0.11)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 340, height: 340)
                .blur(radius: 80)
                .offset(x: orbAnimate ? -90 : -50, y: orbAnimate ? -180 : -220)

            Circle()
                .fill(Color.purple.opacity(0.16))
                .frame(width: 320, height: 320)
                .blur(radius: 75)
                .offset(x: orbAnimate ? 100 : 70, y: orbAnimate ? 200 : 250)

            Circle()
                .fill(Color.cyan.opacity(0.10))
                .frame(width: 250, height: 250)
                .blur(radius: 65)
                .offset(x: orbAnimate ? -40 : 40, y: orbAnimate ? 80 : 20)

            Canvas { context, size in
                let spacing: CGFloat = 40
                var path = Path()

                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }

                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }

                context.stroke(path, with: .color(Color.white.opacity(0.025)), lineWidth: 1)
            }
            .ignoresSafeArea()

            if isHazard {
                Rectangle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [Color.red.opacity(0.85), Color.red.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 6
                    )
                    .blur(radius: 4)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                orbAnimate.toggle()
            }
        }
    }
}

// MARK: - 2. Top Arcade HUD Bar
struct ArcadeHUDView: View {
    let highScore: Int
    let comboMultiplier: Int
    let isHapticsEnabled: Bool
    let onToggleHaptics: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 0) {
                    Text("BEST")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white.opacity(0.6))

                    Text("\(highScore)")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color.white.opacity(0.08))
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )

            Spacer()

            if comboMultiplier > 1 {
                HStack(spacing: 5) {
                    Image(systemName: comboIcon)
                        .font(.system(size: 13, weight: .bold))
                        .symbolEffect(.bounce, value: comboMultiplier)

                    Text(comboTitle)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(comboGradient)
                        .shadow(color: comboShadowColor.opacity(0.55), radius: 8, x: 0, y: 2)
                )
                .transition(.scale(scale: 0.8).combined(with: .opacity))
                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: comboMultiplier)
            }

            Spacer()

            Button(action: onToggleHaptics) {
                Image(systemName: isHapticsEnabled ? "iphone.radiowaves.left.and.right" : "iphone.slash")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isHapticsEnabled ? .cyan : .white.opacity(0.4))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                Circle()
                                    .strokeBorder(isHapticsEnabled ? Color.cyan.opacity(0.35) : Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
            }
            .buttonStyle(PlainButtonStyle())
            .accessibilityLabel("Toggle Haptics")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 6)
    }

    private var comboIcon: String {
        switch comboMultiplier {
        case 2: return "bolt.fill"
        case 3: return "flame.fill"
        default: return "sparkles"
        }
    }

    private var comboTitle: String {
        switch comboMultiplier {
        case 2: return "2X COMBO"
        case 3: return "3X ON FIRE!"
        default: return "4X FRENZY!"
        }
    }

    private var comboGradient: LinearGradient {
        switch comboMultiplier {
        case 2:
            return LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(colors: [Color.orange, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [Color.purple, Color.pink, Color.red], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var comboShadowColor: Color {
        switch comboMultiplier {
        case 2: return .cyan
        case 3: return .orange
        default: return .pink
        }
    }
}

// MARK: - 3. Futuristic Countdown Gauge
struct TimerProgressBar: View {
    let timeRemaining: Int
    var totalTime: Int = 10

    private var progress: CGFloat {
        CGFloat(max(0, timeRemaining)) / CGFloat(totalTime)
    }

    private var isCritical: Bool {
        timeRemaining <= 3
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: isCritical ? "exclamationmark.triangle.fill" : "stopwatch.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isCritical ? .red : .cyan)
                    .symbolEffect(.pulse, isActive: isCritical)

                Text(isCritical ? "CRITICAL: \(timeRemaining)s" : "TIME: \(timeRemaining)s")
                    .font(.system(size: 15, weight: .black, design: .monospaced))
                    .foregroundColor(isCritical ? .red : .white)

                Spacer()

                Text("\(Int(progress * 100))%")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 4)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isCritical
                                    ? [Color.orange, Color.red]
                                    : [Color.cyan, Color.blue, Color.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geo.size.width * progress), height: 10)
                        .shadow(
                            color: (isCritical ? Color.red : Color.cyan).opacity(0.6),
                            radius: isCritical ? 8 : 4,
                            x: 0,
                            y: 0
                        )
                        .animation(.linear(duration: 1.0), value: progress)
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(isCritical ? Color.red.opacity(0.4) : Color.white.opacity(0.06), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 4. Floating Score Popups Layer
struct FloatingScoreLayer: View {
    let items: [FloatingScoreItem]

    var body: some View {
        ZStack {
            ForEach(items) { item in
                HStack(spacing: 4) {
                    if !item.isPositive {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 16, weight: .bold))
                    }
                    Text(item.text)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                }
                .foregroundColor(item.color)
                .shadow(color: item.color.opacity(0.7), radius: 6, x: 0, y: 2)
                .offset(item.offset)
                .scaleEffect(item.scale)
                .opacity(item.opacity)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - 5. Mini Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }

            Text(value)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }
}

// MARK: - 6. Confetti Victory Particle View
struct ConfettiView: View {
    @State private var pieces: [ConfettiPiece] = []

    let colors: [Color] = [.yellow, .orange, .pink, .cyan, .green, .purple]

    var body: some View {
        TimelineView(.animation) { _ in
            Canvas { context, size in
                for piece in pieces {
                    context.opacity = piece.opacity
                    context.drawLayer { ctx in
                        ctx.translateBy(x: piece.x, y: piece.y)
                        ctx.rotate(by: .degrees(piece.rotation))
                        let rect = CGRect(x: -piece.size / 2, y: -piece.size / 4, width: piece.size, height: piece.size / 2)
                        ctx.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(piece.color))
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onAppear {
            spawnConfetti()
        }
    }

    private func spawnConfetti() {
        var newPieces: [ConfettiPiece] = []
        for _ in 0..<70 {
            let piece = ConfettiPiece(
                color: colors.randomElement() ?? .yellow,
                x: CGFloat.random(in: 20...380),
                y: CGFloat.random(in: -100...200),
                rotation: Double.random(in: 0...360),
                size: CGFloat.random(in: 8...14),
                opacity: 1.0
            )
            newPieces.append(piece)
        }
        pieces = newPieces

        withAnimation(.easeOut(duration: 3.0)) {
            for i in pieces.indices {
                pieces[i].y += CGFloat.random(in: 600...900)
                pieces[i].x += CGFloat.random(in: -80...80)
                pieces[i].rotation += Double.random(in: 360...1080)
                pieces[i].opacity = 0.0
            }
        }
    }
}

// MARK: - 7. Shared Guide Pill
struct GuidePill: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.85))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.06))
                .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 1))
        )
    }
}

// MARK: - 8. Shared Tactile Button Style
struct TapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}
