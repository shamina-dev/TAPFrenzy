//
//  ContentView.swift
//  TapFrenzy
//
//  Created by Anjalie Kalansuriya on 2026-11-13.
//

import SwiftUI

struct ContentView: View {
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
                    Text("0")
                        .font(.system(size: 38, weight: .heavy, design: .rounded))
                }
            }

            Spacer()

            // Big Circular TAP Button
            Button(action: {}) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 220, height: 220)
                        .shadow(color: Color.purple.opacity(0.4), radius: 16, x: 0, y: 8)

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
            .buttonStyle(TapButtonStyle())

            Spacer()
        }
        .padding()
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
