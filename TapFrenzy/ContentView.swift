//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Anjalie Kalansuriya on 2026-11-13.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Game State
    @State private var score: Int = 0
    @State private var isPlaying: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Text("Tap Frenzy")
                    .font(.system(size: 36, weight: .black, design: .rounded))

                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .foregroundStyle(.yellow)
                    Text("High Score: 0")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 30)

            Spacer()

            // Stats Layout
            HStack(spacing: 50) {
                VStack(spacing: 4) {
                    Text("TIME")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("10s")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                }

                VStack(spacing: 4) {
                    Text("SCORE")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    Text("\(score)")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }

            Spacer()

            // Big Circular TAP Button
            Button(action: handleTap) {
                ZStack {
                    Circle()
                        .fill(
                            isPlaying
                                ? LinearGradient(colors: [Color.orange, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                                : LinearGradient(colors: [Color.blue, Color.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 220, height: 220)
                        .shadow(
                            color: isPlaying ? Color.orange.opacity(0.45) : Color.purple.opacity(0.4),
                            radius: 16,
                            x: 0,
                            y: 8
                        )

                    if isPlaying {
                        Text("TAP!")
                            .font(.system(size: 48, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        VStack(spacing: 4) {
                            Text("START")
                                .font(.system(size: 38, weight: .black, design: .rounded))
                            Text("Tap to play")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .opacity(0.85)
                        }
                        .foregroundStyle(.white)
                    }
                }
            }
            .buttonStyle(TapButtonStyle())

            Spacer()
        }
        .padding()
    }

    private func handleTap() {
        if !isPlaying {
            isPlaying = true
            score = 0
        } else {
            score += 1
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
