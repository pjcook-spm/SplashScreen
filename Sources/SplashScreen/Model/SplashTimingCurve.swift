import SwiftUI

/// Identifies the timing curve used to ease the splash animation's progress.
enum SplashTimingCurve: String, CaseIterable, Identifiable, Codable {
    case linear
    case easeIn
    case easeOut
    case easeInOut
    case smoothSpring
    case bouncySpring

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .linear: "Linear"
        case .easeIn: "Ease In"
        case .easeOut: "Ease Out"
        case .easeInOut: "Ease In Out"
        case .smoothSpring: "Spring (Smooth)"
        case .bouncySpring: "Spring (Bouncy)"
        }
    }

    /// Maps elapsed animation time to an interpolation factor.
    ///
    /// Non-spring curves are normalised against `duration` and clamped to `0...1`.
    /// Spring curves run on absolute time so they can overshoot `1` before settling.
    func progress(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        guard elapsed > 0 else { return 0 }
        guard duration > 0 else { return 1 }

        switch self {
        case .linear:
            return min(elapsed / duration, 1)
        case .easeIn:
            return UnitCurve.easeIn.value(at: min(elapsed / duration, 1))
        case .easeOut:
            return UnitCurve.easeOut.value(at: min(elapsed / duration, 1))
        case .easeInOut:
            return UnitCurve.easeInOut.value(at: min(elapsed / duration, 1))
        case .smoothSpring:
            return Spring(duration: duration, bounce: 0)
                .value(fromValue: 0.0, toValue: 1.0, initialVelocity: 0, time: elapsed)
        case .bouncySpring:
            return Spring(duration: duration, bounce: 0.4)
                .value(fromValue: 0.0, toValue: 1.0, initialVelocity: 0, time: elapsed)
        }
    }
}
