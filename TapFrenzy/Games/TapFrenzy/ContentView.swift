import SwiftUI
import Combine

struct ContentView: View {
    // AppStorage & Core State
    @AppStorage("highScore") private var highScore = 0
    @AppStorage("hapticsEnabled") private var isHapticsEnabled = true

    @State private var phase: GamePhase = .idle
    @State private var score = 0
    @State private var timeRemaining = 10

    // Statistics for Game Over breakdown
    @State private var totalTaps = 0
    @State private var maxCombo = 1
    @State private var isNewRecord = false

    // Floating score animation items
    @State private var floatingScores: [FloatingScoreItem] = []

    // MARK: - Timer
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Challenge 1: Red Hazard ("Red Light")
    @State private var isHazard: Bool = false
    @State private var hazardShake: Bool = false

    // MARK: - Challenge 2: Bonus Gold Button (+5)
    @State private var showBonusButton: Bool = false
    @State private var bonusPosition: CGPoint = .zero

    // MARK: - Challenge 3: Fast-Tap Combo Multiplier (< 300ms)
    @State private var lastTapTime: Date? = nil
    @State private var comboMultiplier: Int = 1
    @State private var comboResetItem: DispatchWorkItem? = nil

    // MARK: - Challenge 4: Shrinking Target Size
    private var buttonSize: CGFloat {
        guard phase == .playing else { return 205 }
        let shrink = CGFloat(score) * 1.8
        return max(115, 205 - shrink)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Dynamic Cyber Background & Hazard Vignette
                GameBackgroundView(isHazard: isHazard)

                // 2. Main Gameplay Layer
                VStack(spacing: 0) {
                    // Top HUD Bar (High Score, Combo Multiplier, Haptic Toggle)
                    ArcadeHUDView(
                        highScore: highScore,
                        comboMultiplier: comboMultiplier,
                        isHapticsEnabled: isHapticsEnabled,
                        onToggleHaptics: {
                            isHapticsEnabled.toggle()
                            HapticManager.shared.isEnabled = isHapticsEnabled
                            HapticManager.shared.tap(combo: 1)
                        }
                    )
                    .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 8)

                    // Timer Progress Bar or Welcome Header
                    if phase == .playing {
                        TimerProgressBar(timeRemaining: timeRemaining)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 8)
                    } else if phase == .idle {
                        IdleWelcomeView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 8)
                    }

                    Spacer()

                    // Big Hero Score Display
                    HeroScoreView(
                        score: score,
                        highScore: highScore,
                        phase: phase
                    )

                    Spacer()

                    // Center Hero Tap Button with Floating Score Overlay
                    ZStack {
                        TapTargetButton(
                            phase: phase,
                            isHazard: isHazard,
                            hazardShake: hazardShake,
                            buttonSize: buttonSize,
                            onTap: {
                                handleTap(in: geometry.size)
                            }
                        )

                        FloatingScoreLayer(items: floatingScores)
                    }
                    .frame(height: 240)

                    Spacer()

                    // Bottom Guidance Pill
                    HStack(spacing: 6) {
                        if phase == .idle {
                            Text("TAP START TO BEGIN 10s FRENZY")
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.white.opacity(0.75))
                                .tracking(1)
                        } else if phase == .playing {
                            if comboMultiplier > 1 {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(.orange)
                                Text("COMBO STREAK ACTIVE!")
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundColor(.orange)
                            } else {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.cyan)
                                Text("TAP FAST FOR COMBO BOOST")
                                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.06))
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    )
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 12 : 24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // 3. Bonus Gold Target Overlay (+5 Star Rush)
                if showBonusButton && phase == .playing {
                    BonusGoldTargetView(
                        position: bonusPosition,
                        onBonusTap: handleBonusTap
                    )
                }

                // 4. Game Over Modal Overlay
                if phase == .over {
                    GameOverModalView(
                        score: score,
                        highScore: highScore,
                        isNewRecord: isNewRecord,
                        maxCombo: maxCombo,
                        totalTaps: totalTaps,
                        onPlayAgain: playAgain
                    )

                    if isNewRecord {
                        ConfettiView()
                    }
                }
            }
        }
        .onAppear {
            HapticManager.shared.isEnabled = isHapticsEnabled
            HapticManager.shared.prepareGenerators()
        }
        .onReceive(timer) { _ in
            guard phase == .playing else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining <= 3 && timeRemaining > 0 {
                    HapticManager.shared.tap(combo: 2)
                }
                if timeRemaining == 0 {
                    endGame()
                }
            }
        }
    }

    // MARK: - Tap & Game Actions

    private func handleTap(in geometrySize: CGSize) {
        if phase == .idle {
            phase = .playing
            totalTaps = 0
            maxCombo = 1
            isNewRecord = false
            floatingScores.removeAll()
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            scheduleHazard()
            scheduleBonusButton(in: geometrySize)
        }

        totalTaps += 1

        // Penalty if tapped while hazard (red light) is active
        if isHazard {
            score = max(0, score - 2)
            comboMultiplier = 1
            HapticManager.shared.hazardPenalty()
            spawnFloatingScore(text: "-2", color: .red, isPositive: false)

            withAnimation(.default) {
                hazardShake = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                hazardShake = false
            }
            return
        }

        // Fast-tap combo calculation
        registerTapCombo()

        // Haptic feedback matching combo intensity
        HapticManager.shared.tap(combo: comboMultiplier)

        let earnedPoints = comboMultiplier
        score += earnedPoints

        // Spawn floating score feedback
        let popupText = comboMultiplier > 1 ? "+\(earnedPoints) (x\(comboMultiplier))" : "+\(earnedPoints)"
        let popupColor: Color = {
            switch comboMultiplier {
            case 2: return .cyan
            case 3: return .orange
            case 4: return .pink
            default: return .white
            }
        }()
        spawnFloatingScore(text: popupText, color: popupColor, isPositive: true)
    }

    private func registerTapCombo() {
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.3 {
            // Consecutive tap within 300ms increases combo up to x4
            comboMultiplier = min(4, comboMultiplier + 1)
            if comboMultiplier > maxCombo {
                maxCombo = comboMultiplier
            }
        } else {
            comboMultiplier = 1
        }
        lastTapTime = now

        // Expire combo if user doesn't tap within 350ms
        comboResetItem?.cancel()
        let resetWork = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.2)) {
                comboMultiplier = 1
            }
        }
        comboResetItem = resetWork
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35, execute: resetWork)
    }

    private func handleBonusTap() {
        guard showBonusButton && phase == .playing else { return }
        score += 5
        HapticManager.shared.bonusCollected()
        spawnFloatingScore(text: "+5 BONUS! ⭐", color: .yellow, isPositive: true)
        withAnimation(.easeOut(duration: 0.15)) {
            showBonusButton = false
        }
    }

    private func spawnFloatingScore(text: String, color: Color, isPositive: Bool) {
        let randomXOffset = CGFloat.random(in: -35...35)
        let item = FloatingScoreItem(
            text: text,
            color: color,
            offset: CGSize(width: randomXOffset, height: 10),
            opacity: 1.0,
            scale: 0.8,
            isPositive: isPositive
        )
        floatingScores.append(item)

        // Animate floating up and fading away
        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            if let index = floatingScores.firstIndex(where: { $0.id == item.id }) {
                floatingScores[index].scale = 1.15
                floatingScores[index].offset.height = -45
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.35)) {
                if let index = floatingScores.firstIndex(where: { $0.id == item.id }) {
                    floatingScores[index].offset.height = -80
                    floatingScores[index].opacity = 0.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            floatingScores.removeAll(where: { $0.id == item.id })
        }
    }

    // MARK: - Hazard & Bonus Schedulers

    private func scheduleHazard() {
        // Trigger red hazard at a random moment between 3 and 4.5 seconds
        let delay = Double.random(in: 3.0...4.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard phase == .playing else { return }

            withAnimation(.easeInOut(duration: 0.15)) {
                isHazard = true
            }

            // Hazard lasts for 0.6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isHazard = false
                }
            }
        }
    }

    private func scheduleBonusButton(in size: CGSize) {
        // Trigger bonus button at a random moment between 2.5 and 5.5 seconds
        let delay = Double.random(in: 2.5...5.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard phase == .playing else { return }

            let minX: CGFloat = 60
            let maxX: CGFloat = max(minX + 20, size.width - 60)
            let minY: CGFloat = 130
            let maxY: CGFloat = max(minY + 20, size.height - 130)

            let randomX = CGFloat.random(in: minX...maxX)
            var randomY = CGFloat.random(in: minY...maxY)

            // Ensure bonus button does not directly overlap the center button
            let centerX = size.width / 2
            let centerY = size.height / 2
            if hypot(randomX - centerX, randomY - centerY) < 130 {
                randomY += (randomY > centerY ? 120 : -120)
            }

            bonusPosition = CGPoint(x: randomX, y: max(minY, min(maxY, randomY)))

            withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                showBonusButton = true
            }

            // Disappears after 1.5 seconds if uncollected
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) {
                    showBonusButton = false
                }
            }
        }
    }

    private func endGame() {
        phase = .over
        isHazard = false
        showBonusButton = false
        comboMultiplier = 1
        comboResetItem?.cancel()

        if score > highScore {
            highScore = score
            isNewRecord = true
            HapticManager.shared.newRecord()
        } else {
            isNewRecord = false
            HapticManager.shared.gameOver()
        }
    }

    private func playAgain() {
        score = 0
        timeRemaining = 10
        totalTaps = 0
        maxCombo = 1
        isNewRecord = false
        phase = .idle
        comboMultiplier = 1
        lastTapTime = nil
        isHazard = false
        showBonusButton = false
        floatingScores.removeAll()
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
