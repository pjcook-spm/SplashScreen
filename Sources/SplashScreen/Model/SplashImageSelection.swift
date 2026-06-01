import Foundation

/// Identifies the image used by the splash screen.
public enum SplashImageSelection: Equatable, Codable {
    case noOverlay
    case asset(String)
    case custom
}
