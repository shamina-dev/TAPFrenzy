import SwiftUI

// MARK: - 1. Cyber Arcade Animated Background
struct GameBackgroundView: View {
    let isHazard: Bool
    @State private var orbAnimate: Bool = false
    
    var body: some View {
        ZStack {
            // Base dark cosmic space gradient
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
            
            // Subtle ambient neon orbs in background
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
            
            // Subtle grid overlay for arcade atmosphere
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
            
            // Red Hazard Warning Vignette (Edge Alert)
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
            // High Score Pill
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
            
            // Dynamic Combo Multiplier Badge
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
            
            // Haptic feedback toggle button
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
    let totalTime: Int = 10
    
    private var progress: CGFloat {
        CGFloat(max(0, timeRemaining)) / CGFloat(totalTime)
    }
    
    private var isCritical: Bool {
        timeRemaining <= 3
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Timer Readout
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
            
            // Progress Bar Track
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 10)
                    
                    // Animated Fill
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

// MARK: - 4. Hero Score Display
struct HeroScoreView: View {
    let score: Int
    let highScore: Int
    let phase: GamePhase
    
    @State private var scoreScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 4) {
            // New High Score Banner during game
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
            
            // Giant stylized number
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

// MARK: - 5. Tactile 3D Hero Tap Button
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
                // Expanding Shockwave Ripple
                Circle()
                    .strokeBorder(
                        (isHazard ? Color.red : Color.cyan).opacity(rippleOpacity),
                        lineWidth: 3
                    )
                    .frame(width: buttonSize * rippleScale, height: buttonSize * rippleScale)
                
                // Outer Ambient Glowing Ring
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
                
                // Metallic Outer Bezel Ring
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
                
                // Inner Button Surface with 3D Depth
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
                        // Top Specular Highlight Ring for 3D glassy curve
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
                
                // Button Content (Icons & Labels)
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

// Button style helper to track live touch press
struct SquishButtonStyle: ButtonStyle {
    @Binding var isPressedBinding: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressedBinding = newValue
            }
    }
}

// MARK: - 6. Star Rush Bonus Button (+5)
struct BonusGoldTargetView: View {
    let position: CGPoint
    let onBonusTap: () -> Void
    
    @State private var rotateSunburst: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: onBonusTap) {
            ZStack {
                // Rotating Golden Sunburst Halo
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 68))
                    .foregroundColor(Color.yellow.opacity(0.35))
                    .rotationEffect(.degrees(rotateSunburst))
                
                // Pulsing outer aura ring
                Circle()
                    .strokeBorder(Color.yellow.opacity(0.6), lineWidth: 2)
                    .frame(width: 62, height: 62)
                    .scaleEffect(pulseScale)
                
                // Coin Body
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
                
                // Star & "+5" Label
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

// MARK: - 7. Floating Score Popups Layer
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

// MARK: - 8. Game Over Victory & Stats Modal
struct GameOverModalView: View {
    let score: Int
    let highScore: Int
    let isNewRecord: Bool
    let maxCombo: Int
    let totalTaps: Int
    let onPlayAgain: () -> Void
    
    var body: some View {
        ZStack {
            // Dark Frosted Backdrop
            Color.black.opacity(0.65)
                .ignoresSafeArea()
            
            // Modal Card
            VStack(spacing: 20) {
                // Header Banner
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
                
                // Final Score Hero Card
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
                
                // 2x2 Stats Grid
                HStack(spacing: 12) {
                    StatCard(title: "BEST RECORD", value: "\(highScore)", icon: "crown.fill", color: .yellow)
                    StatCard(title: "MAX COMBO", value: "\(maxCombo)x", icon: "flame.fill", color: .orange)
                }
                
                HStack(spacing: 12) {
                    StatCard(title: "TOTAL TAPS", value: "\(totalTaps)", icon: "hand.tap.fill", color: .cyan)
                    StatCard(title: "SPEED", value: String(format: "%.1f/s", Double(totalTaps) / 10.0), icon: "bolt.fill", color: .green)
                }
                
                // Play Again Action Button
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

// Mini Stat Card
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

// MARK: - 9. Confetti Victory Particle View
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
        
        // Animate them falling
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

// MARK: - 10. Idle Hero Welcome Card
struct IdleWelcomeView: View {
    var body: some View {
        VStack(spacing: 12) {
            // Neon Game Logo Header
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
            
            // Instruction Badges
            HStack(spacing: 8) {
                GuidePill(icon: "bolt.fill", title: "Combos", color: .cyan)
                GuidePill(icon: "exclamationmark.triangle.fill", title: "Avoid Red", color: .red)
                GuidePill(icon: "star.fill", title: "+5 Gold", color: .yellow)
            }
        }
        .padding(.top, 4)
    }
}

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
