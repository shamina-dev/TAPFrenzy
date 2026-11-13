//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Anjalie Kalansuriya on 2026-11-13.
//

import SwiftUI
import Combine

// MARK: - Game Phase Definition
// Represents the core lifecycle: idle → playing → over
enum GamePhase {
    case idle
    case playing
    case over
}

struct ContentView: View {
    // MARK: - Persisted High Score
    // Persists high score across launches using @AppStorage
    @AppStorage("highScore") private var highScore: Int = 0

    // MARK: - State Properties
    // Core state loop: phase, score, countdown timer
    @State private var phase: GamePhase = .idle
    @State private var score: Int = 0
    @State private var timeRemaining: Int = 10
    @State private var canRestart: Bool = false

    // 1-second countdown timer publisher
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    // MARK: - Body
    var body: some View {
        VStack(spacing: 24) {
            headerView

            Spacer()

            statusSection

            Spacer()

            circularTapButton

            Spacer()
        }
        .padding()
        .onAppear(perform: migrateLegacyHighScoreIfNeeded)
        .onReceive(timer) { _ in
            handleTimerTick()
        }
    }

    // MARK: - Subviews

    /// App header displaying title and persisted high score
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Tap Frenzy")
                .font(.system(size: 36, weight: .black, design: .rounded))

            HStack(spacing: 6) {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("High Score: \(highScore)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 30)
    }

    /// Status display handled cleanly for each phase: idle → playing → over
    @ViewBuilder
    private var statusSection: some View {
        switch phase {
        case .idle:
            statsDisplay(time: 10, currentScore: 0, isUrgent: false)
                .transition(.opacity)

        case .playing:
            statsDisplay(time: timeRemaining, currentScore: score, isUrgent: timeRemaining <= 3)
                .transition(.opacity)

        case .over:
            gameOverDisplay
                .transition(.opacity)
        }
    }

    /// Shared stats layout for idle and playing phases
    private func statsDisplay(time: Int, currentScore: Int, isUrgent: Bool) -> some View {
        HStack(spacing: 50) {
            VStack(spacing: 4) {
                Text("TIME")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("\(time)s")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(isUrgent ? .red : .primary)
            }

            VStack(spacing: 4) {
                Text("SCORE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                Text("\(currentScore)")
                    .font(.system(size: 38, weight: .heavy, design: .rounded))
                    .foregroundStyle(.primary)
            }
        }
    }

    /// Results summary shown when the game is over
    private var gameOverDisplay: some View {
        VStack(spacing: 12) {
            Text("Time's Up!")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.red)

            VStack(spacing: 6) {
                Text("Final Score: \(score)")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                Text("High Score: \(highScore)")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)

                if score == highScore && score > 0 {
                    Text("🎉 New High Score!")
                        .font(.headline)
                        .foregroundStyle(.orange)
                        .padding(.top, 4)
                }
            }
        }
    }

    /// One big circular TAP button in the middle of the screen
    private var circularTapButton: some View {
        Button(action: handleButtonTap) {
            ZStack {
                Circle()
                    .fill(buttonGradient)
                    .frame(width: 220, height: 220)
                    .shadow(color: buttonShadowColor, radius: 16, x: 0, y: 8)

                buttonLabel
                    .foregroundStyle(.white)
            }
        }
        .buttonStyle(TapButtonStyle())
    }

    /// Button text and icon corresponding to the current phase
    @ViewBuilder
    private var buttonLabel: some View {
        switch phase {
        case .idle:
            VStack(spacing: 4) {
                Text("START")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                Text("Tap to play")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .opacity(0.85)
            }

        case .playing:
            Text("TAP!")
                .font(.system(size: 48, weight: .black, design: .rounded))

        case .over:
            VStack(spacing: 4) {
                Text("TRY")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                Text("AGAIN")
                    .font(.system(size: 22, weight: .black, design: .rounded))
            }
        }
    }

    /// Button background gradient based on phase
    private var buttonGradient: LinearGradient {
        switch phase {
        case .idle:
            return LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .playing:
            return LinearGradient(
                colors: [Color.orange, Color.pink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .over:
            return LinearGradient(
                colors: [Color.green, Color.teal],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// Button drop shadow color based on phase
    private var buttonShadowColor: Color {
        switch phase {
        case .idle:
            return Color.purple.opacity(0.4)
        case .playing:
            return Color.orange.opacity(0.45)
        case .over:
            return Color.green.opacity(0.4)
        }
    }

    // MARK: - Game Loop Logic

    /// Primary tap handler navigating phases: idle → playing → over
    private func handleButtonTap() {
        switch phase {
        case .idle:
            startGame()

        case .playing:
            score += 1

        case .over:
            guard canRestart else { return }
            startGame()
        }
    }

    /// Begins a fresh 10-second game session
    private func startGame() {
        score = 0
        timeRemaining = 10
        phase = .playing
        // Reset timer publisher so the first tick starts exactly 1 second from now
        timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }

    /// Concludes the game session and persists high score
    private func endGame() {
        timer.upstream.connect().cancel()
        phase = .over
        canRestart = false

        // Update high score across launches via @AppStorage
        if score > highScore {
            highScore = score
        }

        // Brief cooldown to avoid accidental tap carryover from frenzied tapping
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            canRestart = true
        }
    }

    /// Ticks the countdown down each second while playing
    private func handleTimerTick() {
        guard phase == .playing else { return }

        if timeRemaining > 1 {
            timeRemaining -= 1
        } else {
            timeRemaining = 0
            endGame()
        }
    }

    /// Checks if a score was previously saved under "bestScore" and migrates it to "highScore"
    private func migrateLegacyHighScoreIfNeeded() {
        let legacyBest = UserDefaults.standard.integer(forKey: "bestScore")
        if legacyBest > highScore {
            highScore = legacyBest
        }
    }
}

// MARK: - Button Style for Tactile Tap Feedback
struct TapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.08), value: configuration.isPressed)
    }
}

// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
