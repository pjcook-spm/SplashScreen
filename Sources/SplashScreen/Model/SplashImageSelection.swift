import Foundation

/// Identifies the image used by the splash screen.
enum SplashImageSelection: Equatable, Codable {
    case noOverlay
    case asset(String)
    case custom
}
