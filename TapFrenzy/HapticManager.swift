import SwiftUI
import UIKit

/// Centralized manager for rich tactile feedback in TapFrenzy
final class HapticManager {
    static let shared = HapticManager()
    
    @AppStorage("hapticsEnabled") var isEnabled: Bool = true
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
    private let notification = UINotificationFeedbackGenerator()
    
    private init() {
        prepareGenerators()
    }
    
    func prepareGenerators() {
        guard isEnabled else { return }
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        rigidImpact.prepare()
        notification.prepare()
    }
    
    /// Normal tap feedback with escalation based on combo level
    func tap(combo: Int = 1) {
        guard isEnabled else { return }
        switch combo {
        case 1:
            lightImpact.impactOccurred(intensity: 0.7)
        case 2:
            mediumImpact.impactOccurred(intensity: 0.85)
        case 3:
            rigidImpact.impactOccurred(intensity: 0.95)
        default:
            heavyImpact.impactOccurred(intensity: 1.0)
        }
    }
    
    /// Gold star bonus collected (+5)
    func bonusCollected() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }
    
    /// Red hazard penalty triggered (-2)
    func hazardPenalty() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }
    
    /// Game over warning
    func gameOver() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }
    
    /// Celebratory new personal best
    func newRecord() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.heavyImpact.impactOccurred(intensity: 1.0)
        }
    }
}
