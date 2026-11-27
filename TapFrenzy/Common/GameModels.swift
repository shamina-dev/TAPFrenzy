import SwiftUI

enum GamePhase: Equatable {
    case idle
    case playing
    case over
}

/// Floating arcade indicator that pops up when points are scored or lost
struct FloatingScoreItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let color: Color
    var offset: CGSize
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    let isPositive: Bool
}

/// Dynamic confetti particle for high-score celebration
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    var rotation: Double
    var size: CGFloat
    var opacity: Double = 1.0
}
