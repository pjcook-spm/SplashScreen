import Foundation

/// Configures which bundled splash assets are available and how they are labeled.
public struct SplashImageCatalog: Sendable {
    public let bundledAssetNames: [String]
    public let displayNames: [String: String]
    public let bundle: Bundle

    public static let `default` = SplashImageCatalog(
        bundledAssetNames: [],
        displayNames: [:],
        bundle: .main
    )

    public init(bundledAssetNames: [String], displayNames: [String: String], bundle: Bundle) {
        self.bundledAssetNames = bundledAssetNames
        self.displayNames = displayNames
        self.bundle = bundle
    }

    public func displayName(for assetName: String) -> String {
        displayNames[assetName] ?? assetName
    }
}
