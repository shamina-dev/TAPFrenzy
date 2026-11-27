import SwiftUI

/// Grid card item for Light It Up mode
struct Card: Identifiable, Equatable {
    let id: Int
    var isLit: Bool = false
}

/// Visual tap feedback state for Light It Up cards
enum CardFlash: Equatable {
    case correct
    case wrong
}

/// Difficulty progression levels across the 60-second Light It Up round
enum Level: Int, CaseIterable, Equatable {
    case L1 = 1
    case L2 = 2
    case L3 = 3
    case L4 = 4

    var gridCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 4
        case .L3: return 6
        case .L4: return 9
        }
    }

    var litWindow: TimeInterval {
        switch self {
        case .L1: return 1.5
        case .L2: return 1.2
        case .L3: return 1.0
        case .L4: return 0.8
        }
    }

    var columnCount: Int {
        switch self {
        case .L1: return 3
        case .L2: return 2
        case .L3: return 3
        case .L4: return 3
        }
    }

    var maxSimultaneousLit: Int {
        switch self {
        case .L4: return 2
        default: return 1
        }
    }

    var badgeTitle: String {
        "LVL \(rawValue)"
    }

    var accentColor: Color {
        switch self {
        case .L1: return .cyan
        case .L2: return .yellow
        case .L3: return .orange
        case .L4: return .pink
        }
    }

    var litGradientColors: [Color] {
        switch self {
        case .L1:
            return [Color(red: 0.35, green: 0.92, blue: 1.0), Color(red: 0.0, green: 0.56, blue: 0.98)]
        case .L2:
            return [Color(red: 1.0, green: 0.92, blue: 0.25), Color(red: 1.0, green: 0.56, blue: 0.0)]
        case .L3:
            return [Color(red: 1.0, green: 0.58, blue: 0.2), Color(red: 0.94, green: 0.24, blue: 0.06)]
        case .L4:
            return [Color(red: 1.0, green: 0.35, blue: 0.85), Color(red: 0.68, green: 0.12, blue: 0.92)]
        }
    }

    static func forElapsed(_ elapsedSeconds: Int, totalDuration: Int = 60) -> Level {
        let safeTotal = max(1, totalDuration)
        let progress = Double(elapsedSeconds) / Double(safeTotal)
        switch progress {
        case ..<0.25: return .L1
        case 0.25..<0.50: return .L2
        case 0.50..<0.75: return .L3
        default: return .L4
        }
    }
}
