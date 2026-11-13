//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Anjalie Kalansuriya on 2026-11-13.
//

import SwiftUI
import Combine

enum GamePhase {
    case idle
    case playing
    case over
}

struct ContentView: View {
    // MARK: - AppStorage & Core State
    @AppStorage("highScore") private var highScore = 0
    @State private var phase: GamePhase = .idle
    @State private var score = 0
    @State private var timeRemaining = 10

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
        guard phase == .playing else { return 200 }
        let shrink = CGFloat(score) * 1.8
        return max(110, 200 - shrink)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main Content
                VStack {
                    switch phase {
                    case .idle, .playing:
                        VStack(spacing: 30) {
                            // Score label with combo multiplier
                            HStack(alignment: .center, spacing: 10) {
                                Text("\(score)")
                                    .font(.system(size: 80, weight: .heavy))

                                if comboMultiplier > 1 {
                                    Text("x\(comboMultiplier)!")
                                        .font(.system(size: 26, weight: .black, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(
                                            LinearGradient(
                                                colors: [Color.orange, Color.red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .clipShape(Capsule())
                                        .shadow(color: Color.orange.opacity(0.5), radius: 5, x: 0, y: 2)
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: comboMultiplier)

                            Spacer()

                            // Big circular TAP button in the middle
                            Button(action: {
                                handleTap(in: geometry.size)
                            }) {
                                Text(isHazard ? "DON'T!" : "TAP")
                                    .font(.system(size: isHazard ? 32 : 40, weight: .heavy))
                                    .foregroundColor(.white)
                                    .frame(width: buttonSize, height: buttonSize)
                                    .background(isHazard ? Color.red : Color.blue)
                                    .clipShape(Circle())
                                    .shadow(
                                        color: (isHazard ? Color.red : Color.blue).opacity(0.4),
                                        radius: 12,
                                        x: 0,
                                        y: 6
                                    )
                                    .offset(x: hazardShake ? -6 : 0)
                            }
                            .buttonStyle(TapButtonStyle())
                            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: buttonSize)
                            .animation(.easeInOut(duration: 0.15), value: isHazard)

                            Spacer()

                            // Timer label
                            Text("Time: \(timeRemaining)")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(timeRemaining <= 3 && phase == .playing ? .red : .primary)
                        }
                        .padding(.vertical, 30)

                    case .over:
                        VStack(spacing: 24) {
                            Text("Time's Up!")
                                .font(.system(size: 36, weight: .heavy))
                                .foregroundColor(.red)

                            Text("Final Score: \(score)")
                                .font(.system(size: 50, weight: .heavy))

                            Text("Best: \(highScore)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.secondary)

                            if score == highScore && score > 0 {
                                Text("🎉 New High Score!")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }

                            Button("Play Again") {
                                playAgain()
                            }
                            .font(.title2.bold())
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            .padding(.top, 20)
                        }
                        .padding()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()

                // Bonus Gold "+5" Button Overlay
                if showBonusButton && phase == .playing {
                    Button(action: handleBonusTap) {
                        VStack(spacing: 2) {
                            Text("+5")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(.black)
                        }
                        .frame(width: 56, height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(Circle())
                        .shadow(color: Color.yellow.opacity(0.8), radius: 10, x: 0, y: 0)
                    }
                    .position(bonusPosition)
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .onReceive(timer) { _ in
            guard phase == .playing else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
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
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            scheduleHazard()
            scheduleBonusButton(in: geometrySize)
        }

        // Penalty if tapped while hazard (red light) is active
        if isHazard {
            score = max(0, score - 2)
            comboMultiplier = 1
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
        score += comboMultiplier
    }

    private func registerTapCombo() {
        let now = Date()
        if let last = lastTapTime, now.timeIntervalSince(last) <= 0.3 {
            // Consecutive tap within 300ms increases combo up to x4
            comboMultiplier = min(4, comboMultiplier + 1)
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
        withAnimation(.easeOut(duration: 0.15)) {
            showBonusButton = false
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

            var randomX = CGFloat.random(in: minX...maxX)
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
        }
    }

    private func playAgain() {
        score = 0
        timeRemaining = 10
        phase = .idle
        comboMultiplier = 1
        lastTapTime = nil
        isHazard = false
        showBonusButton = false
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
