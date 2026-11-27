import SwiftUI
import Combine

struct LightItUpView: View {
    // MARK: - Persisted Settings & High Score
    @AppStorage("lightItUpHighScore") private var highScore = 0
    @AppStorage("lightItUpRoundLength") private var roundDuration = 60
    @AppStorage("hapticsEnabled") private var isHapticsEnabled = true

    // MARK: - Game State
    @State private var phase: GamePhase = .idle
    @State private var cards: [Card] = (0..<Level.L1.gridCount).map { Card(id: $0) }
    @State private var currentLevel: Level = .L1
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 60
    @State private var lives: Int = 3

    // Round Statistics
    @State private var hits: Int = 0
    @State private var wrongTaps: Int = 0
    @State private var streak: Int = 0
    @State private var isNewRecord: Bool = false
    @State private var endedOutOfLives: Bool = false

    // Visual Feedback & Tokens
    @State private var cardFlashes: [Int: CardFlash] = [:]
    @State private var litTokens: [Int: UUID] = [:]
    @State private var floatingScores: [FloatingScoreItem] = []
    @State private var levelUpBannerText: String? = nil
    @State private var levelUpDismissWorkItem: DispatchWorkItem? = nil

    // MARK: - Timers
    @State private var roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var litTimer = Timer.publish(every: Level.L1.litWindow, on: .main, in: .common).autoconnect()

    private let maxLives = 3

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 14), count: currentLevel.columnCount)
    }

    private var cardHeight: CGFloat {
        switch currentLevel {
        case .L1: return 132
        case .L2: return 132
        case .L3: return 112
        case .L4: return 94
        }
    }

    var body: some View {
        ZStack {
            GameBackgroundView(isHazard: false)

            VStack(spacing: 12) {
                ArcadeHUDView(
                    highScore: highScore,
                    comboMultiplier: streak >= 3 ? min(4, streak / 3 + 1) : 1,
                    isHapticsEnabled: isHapticsEnabled,
                    onToggleHaptics: {
                        isHapticsEnabled.toggle()
                        HapticManager.shared.isEnabled = isHapticsEnabled
                        HapticManager.shared.tap(combo: 1)
                    }
                )

                if phase == .playing {
                    TimerProgressBar(timeRemaining: timeRemaining, totalTime: roundDuration)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Level, Lives & Score Row
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(currentLevel.badgeTitle)
                                .font(.system(size: 12, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                                .padding(.horizontal, 9)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(currentLevel.accentColor))

                            Text("\(String(format: "%.1fs", currentLevel.litWindow))")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.75))
                        }

                        // 3 Lives Indicator
                        HStack(spacing: 6) {
                            ForEach(0..<maxLives, id: \.self) { index in
                                Image(systemName: index < lives ? "heart.fill" : "heart")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(index < lives ? .red : .white.opacity(0.25))
                                    .scaleEffect(index < lives ? 1.0 : 0.85)
                                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: lives)
                            }
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 0) {
                        Text("SCORE")
                            .font(.system(size: 10, weight: .black, design: .rounded))
                            .foregroundColor(.white.opacity(0.55))
                            .tracking(1)

                        Text("\(score)")
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, currentLevel.accentColor],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentTransition(.numericText())
                    }
                }
                .padding(.horizontal, 22)

                Spacer(minLength: 4)

                // Card Grid + Floating Score Overlay
                ZStack {
                    LazyVGrid(columns: gridColumns, spacing: 14) {
                        ForEach(cards) { card in
                            LightUpCardView(
                                card: card,
                                level: currentLevel,
                                flash: cardFlashes[card.id],
                                height: cardHeight,
                                isInteractive: phase == .playing,
                                onTap: {
                                    handleCardTap(card)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.spring(response: 0.35, dampingFraction: 0.78), value: currentLevel)

                    FloatingScoreLayer(items: floatingScores)
                }

                Spacer(minLength: 4)

                // Bottom Start Button (Idle)
                if phase == .idle {
                    Button(action: startGame) {
                        Text("START")
                            .font(.system(size: 18, weight: .black, design: .rounded))
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
                            .shadow(color: Color.orange.opacity(0.5), radius: 12, x: 0, y: 5)
                    }
                    .buttonStyle(TapButtonStyle())
                    .padding(.horizontal, 28)
                    .padding(.bottom, 16)
                }
            }
            .padding(.top, 4)

            // Brief Level-Up Flash Overlay
            if let bannerText = levelUpBannerText {
                Text(bannerText)
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: currentLevel.litGradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: currentLevel.accentColor.opacity(0.85), radius: 22, x: 0, y: 6)
                    )
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.45), lineWidth: 2)
                    )
                    .transition(.scale(scale: 0.75).combined(with: .opacity))
                    .allowsHitTesting(false)
            }

            // Game Over Overlay
            if phase == .over {
                LightItUpGameOverModalView(
                    score: score,
                    highScore: highScore,
                    isNewRecord: isNewRecord,
                    hits: hits,
                    wrongTaps: wrongTaps,
                    livesRemaining: lives,
                    endedOutOfLives: endedOutOfLives,
                    levelReached: currentLevel,
                    onPlayAgain: resetToIdle
                )

                if isNewRecord {
                    ConfettiView()
                }
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            HapticManager.shared.isEnabled = isHapticsEnabled
            HapticManager.shared.prepareGenerators()
            if phase == .idle {
                timeRemaining = roundDuration
            }
        }
        .onChange(of: roundDuration) { _, newValue in
            if phase == .idle {
                timeRemaining = newValue
            }
        }
        .onDisappear {
            stopActiveRound()
        }
        .onReceive(roundTimer) { _ in
            guard phase == .playing else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
                let elapsed = roundDuration - timeRemaining
                let nextLevel = Level.forElapsed(elapsed, totalDuration: roundDuration)

                if nextLevel != currentLevel && timeRemaining > 0 {
                    switchLevel(to: nextLevel)
                }

                if timeRemaining <= 3 && timeRemaining > 0 {
                    HapticManager.shared.tap(combo: 2)
                }

                if timeRemaining == 0 {
                    endGame(outOfLives: false)
                }
            }
        }
        .onReceive(litTimer) { _ in
            guard phase == .playing else { return }
            lightUpRandomCards()
        }
    }

    // MARK: - Game Lifecycle

    private func startGame() {
        score = 0
        hits = 0
        wrongTaps = 0
        streak = 0
        lives = maxLives
        timeRemaining = roundDuration
        isNewRecord = false
        endedOutOfLives = false
        currentLevel = .L1
        cards = (0..<Level.L1.gridCount).map { Card(id: $0) }
        cardFlashes.removeAll()
        litTokens.removeAll()
        floatingScores.removeAll()
        levelUpDismissWorkItem?.cancel()
        levelUpBannerText = nil

        phase = .playing
        roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        litTimer = Timer.publish(every: Level.L1.litWindow, on: .main, in: .common).autoconnect()
        HapticManager.shared.tap(combo: 2)

        lightUpRandomCards()
    }

    private func switchLevel(to newLevel: Level) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
            currentLevel = newLevel
            if cards.count < newLevel.gridCount {
                let extra = (cards.count..<newLevel.gridCount).map { Card(id: $0) }
                cards.append(contentsOf: extra)
            } else if cards.count > newLevel.gridCount {
                cards = Array(cards.prefix(newLevel.gridCount))
            }
        }
        litTimer = Timer.publish(every: newLevel.litWindow, on: .main, in: .common).autoconnect()
        HapticManager.shared.tap(combo: 3)
        showLevelUpFlash(level: newLevel)
    }

    private func showLevelUpFlash(level: Level) {
        levelUpDismissWorkItem?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
            levelUpBannerText = "Level \(level.rawValue)!"
        }

        let workItem = DispatchWorkItem {
            withAnimation(.easeOut(duration: 0.22)) {
                levelUpBannerText = nil
            }
        }
        levelUpDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.95, execute: workItem)
    }

    private func lightUpRandomCards() {
        let unlitIndices = cards.indices.filter { !cards[$0].isLit }
        guard !unlitIndices.isEmpty else { return }

        let targetCount: Int
        if currentLevel == .L4 {
            targetCount = (unlitIndices.count >= 2 && Double.random(in: 0...1) < 0.7) ? 2 : 1
        } else {
            targetCount = 1
        }

        let chosenIndices = unlitIndices.shuffled().prefix(targetCount)
        let window = currentLevel.litWindow

        for idx in chosenIndices {
            let cardID = cards[idx].id
            let token = UUID()
            litTokens[cardID] = token
            cards[idx].isLit = true

            DispatchQueue.main.asyncAfter(deadline: .now() + window) {
                guard phase == .playing,
                      litTokens[cardID] == token,
                      let currentIndex = cards.firstIndex(where: { $0.id == cardID }),
                      cards[currentIndex].isLit else { return }

                cards[currentIndex].isLit = false
                litTokens.removeValue(forKey: cardID)
                handleMissedWindow(cardID: cardID)
            }
        }
    }

    private func handleCardTap(_ card: Card) {
        guard phase == .playing,
              let idx = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[idx].isLit {
            cards[idx].isLit = false
            litTokens.removeValue(forKey: card.id)
            hits += 1
            streak += 1
            score += 2

            triggerFlash(cardID: card.id, flash: .correct)
            HapticManager.shared.tap(combo: min(4, max(1, streak / 3 + 1)))
            spawnFloatingScore(text: "+2", color: .green, isPositive: true)
        } else {
            wrongTaps += 1
            streak = 0
            lives = max(0, lives - 1)

            triggerFlash(cardID: card.id, flash: .wrong)
            HapticManager.shared.hazardPenalty()
            spawnFloatingScore(text: "-1 LIFE", color: .red, isPositive: false)

            if lives == 0 {
                endGame(outOfLives: true)
            }
        }
    }

    private func handleMissedWindow(cardID: Int) {
        streak = 0
        triggerFlash(cardID: cardID, flash: .wrong)
    }

    private func triggerFlash(cardID: Int, flash: CardFlash) {
        withAnimation(.easeInOut(duration: 0.12)) {
            cardFlashes[cardID] = flash
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(.easeOut(duration: 0.18)) {
                if cardFlashes[cardID] == flash {
                    cardFlashes.removeValue(forKey: cardID)
                }
            }
        }
    }

    private func spawnFloatingScore(text: String, color: Color, isPositive: Bool) {
        let randomXOffset = CGFloat.random(in: -45...45)
        let item = FloatingScoreItem(
            text: text,
            color: color,
            offset: CGSize(width: randomXOffset, height: 10),
            opacity: 1.0,
            scale: 0.85,
            isPositive: isPositive
        )
        floatingScores.append(item)

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            if let index = floatingScores.firstIndex(where: { $0.id == item.id }) {
                floatingScores[index].scale = 1.15
                floatingScores[index].offset.height = -45
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.35)) {
                if let index = floatingScores.firstIndex(where: { $0.id == item.id }) {
                    floatingScores[index].offset.height = -85
                    floatingScores[index].opacity = 0.0
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            floatingScores.removeAll(where: { $0.id == item.id })
        }
    }

    private func stopActiveRound() {
        litTokens.removeAll()
        levelUpDismissWorkItem?.cancel()
        levelUpBannerText = nil
        for idx in cards.indices {
            cards[idx].isLit = false
        }
        if phase == .playing {
            phase = .idle
        }
    }

    private func endGame(outOfLives: Bool) {
        phase = .over
        endedOutOfLives = outOfLives
        litTokens.removeAll()
        levelUpDismissWorkItem?.cancel()
        levelUpBannerText = nil
        for idx in cards.indices {
            cards[idx].isLit = false
        }

        if score > highScore {
            highScore = score
            isNewRecord = true
            HapticManager.shared.newRecord()
        } else {
            isNewRecord = false
            HapticManager.shared.gameOver()
        }
    }

    private func resetToIdle() {
        score = 0
        hits = 0
        wrongTaps = 0
        streak = 0
        lives = maxLives
        timeRemaining = roundDuration
        isNewRecord = false
        endedOutOfLives = false
        currentLevel = .L1
        cards = (0..<Level.L1.gridCount).map { Card(id: $0) }
        cardFlashes.removeAll()
        litTokens.removeAll()
        floatingScores.removeAll()
        levelUpDismissWorkItem?.cancel()
        levelUpBannerText = nil
        phase = .idle
    }
}

struct LightItUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LightItUpView()
        }
    }
}
