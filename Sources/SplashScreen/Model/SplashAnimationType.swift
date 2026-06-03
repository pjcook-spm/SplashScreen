import Foundation

/// Identifies the animation style used by the splash screen.
public enum SplashAnimationType: String, CaseIterable, Identifiable, Codable {
    case scale
    case wipe
    case fadeIn
    case fadeOut

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
            case .scale: "Scale"
            case .wipe: "Wipe"
            case .fadeIn: "Fade In"
            case .fadeOut: "Fade Out"
        }
    }
}
