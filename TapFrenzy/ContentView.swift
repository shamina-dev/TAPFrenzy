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
    @AppStorage("highScore") private var highScore = 0
    @State private var phase: GamePhase = .idle
    @State private var score = 0
    @State private var timeRemaining = 10

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            switch phase {
            case .idle, .playing:
                VStack(spacing: 40) {
                    // Score label with chunky font
                    Text("\(score)")
                        .font(.system(size: 80, weight: .heavy))

                    Spacer()

                    // Big circular TAP Button in the middle
                    Button(action: handleTap) {
                        Text("TAP")
                            .font(.system(size: 40, weight: .heavy))
                            .foregroundColor(.white)
                            .frame(width: 200, height: 200)
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .buttonStyle(TapButtonStyle())

                    Spacer()

                    // Timer label
                    Text("Time: \(timeRemaining)")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(timeRemaining <= 3 && phase == .playing ? .red : .primary)
                }
                .padding(.vertical, 40)

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
        .padding()
        .onReceive(timer) { _ in
            guard phase == .playing else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining == 0 {
                    phase = .over
                    if score > highScore {
                        highScore = score
                    }
                }
            }
        }
    }

    private func handleTap() {
        if phase == .idle {
            phase = .playing
            timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        }
        score += 1
    }

    private func playAgain() {
        score = 0
        timeRemaining = 10
        phase = .idle
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
