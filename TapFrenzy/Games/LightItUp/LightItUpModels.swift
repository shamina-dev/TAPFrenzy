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
        case .L2: return .green
        case .L3: return .orange
        case .L4: return .pink
        }
    }

    static func forElapsed(_ elapsedSeconds: Int) -> Level {
        switch elapsedSeconds {
        case ..<15: return .L1
        case 15..<30: return .L2
        case 30..<45: return .L3
        default: return .L4
        }
    }
}
