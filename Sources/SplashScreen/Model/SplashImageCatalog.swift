import Foundation

/// Configures which bundled splash assets are available and how they are labeled.
public struct SplashImageCatalog: Sendable {
    public let bundledAssetNames: [String]
    public let displayNames: [String: String]
    public let bundle: Bundle
    /// Optional asset-catalog image used as the splash logo mask silhouette.
    public let logoMaskAssetName: String?
    
    public static let `default` = SplashImageCatalog(
        bundledAssetNames: [],
        displayNames: [:],
        bundle: .main,
        logoMaskAssetName: nil
    )
    
    public init(
        bundledAssetNames: [String],
        displayNames: [String: String],
        bundle: Bundle,
        logoMaskAssetName: String? = nil
    ) {
        self.bundledAssetNames = bundledAssetNames
        self.displayNames = displayNames
        self.bundle = bundle
        self.logoMaskAssetName = logoMaskAssetName
    }
    
    public func displayName(for assetName: String) -> String {
        displayNames[assetName] ?? assetName
    }
}
