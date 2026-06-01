import Foundation

/// Identifies the animation style used by the splash screen.
enum SplashAnimationType: String, CaseIterable, Identifiable, Codable {
    case scale
    case wipe

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .scale: "Scale"
        case .wipe: "Wipe"
        }
    }
}
