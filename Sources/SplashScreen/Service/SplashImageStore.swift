import SwiftUI

@MainActor
@Observable
public final class SplashImageStore {
    
    public let imageCatalog: SplashImageCatalog
    private let defaults: UserDefaults
    private let customImageURL: URL
    private let resolvedLogoMaskAssetName: String?
    
    public var bundledAssetNames: [String] {
        imageCatalog.bundledAssetNames
    }
    
    /// Returns a display label for the given bundled asset name.
    public func displayName(for assetName: String) -> String {
        imageCatalog.displayName(for: assetName)
    }
    
    public static let customImageFileName = "custom_splash_image.png"
    
    private let selectionDefaultsKey = "SplashImageStore.selection"
    private let animationTypeDefaultsKey = "SplashImageStore.animationType"
    private let timingCurveDefaultsKey = "SplashImageStore.timingCurve"
    private let animationDurationDefaultsKey = "SplashImageStore.animationDuration"
    private let animationDelayDefaultsKey = "SplashImageStore.animationDelay"
    private let finalWidthFractionDefaultsKey = "SplashImageStore.finalWidthFraction"
    private let maxFinalWidthDefaultsKey = "SplashImageStore.maxFinalWidth"
    private let startWidthMultiplierDefaultsKey = "SplashImageStore.startWidthMultiplier"
    private let lightTintColorDefaultsKey = "SplashImageStore.lightTintColor"
    private let darkTintColorDefaultsKey = "SplashImageStore.darkTintColor"
    
    public var selection: SplashImageSelection {
        didSet { persistSelection() }
    }
    
    /// Raw bytes of the user's custom image, if one has been imported.
    public private(set) var customImageData: Data?
    
    /// Determines how the splash logo is animated in.
    public var animationType: SplashAnimationType {
        didSet { defaults.set(animationType.rawValue, forKey: animationTypeDefaultsKey) }
    }
    
    /// Timing curve applied to the splash animation's progress.
    public var timingCurve: SplashTimingCurve {
        didSet { defaults.set(timingCurve.rawValue, forKey: timingCurveDefaultsKey) }
    }
    
    /// How long the splash logo animation plays for.
    public var animationDuration: TimeInterval {
        didSet { defaults.set(animationDuration, forKey: animationDurationDefaultsKey) }
    }
    
    /// How long to wait before starting the splash logo animation.
    public var animationDelay: TimeInterval {
        didSet { defaults.set(animationDelay, forKey: animationDelayDefaultsKey) }
    }
    
    /// Fraction of the container width the logo settles to at the end of the animation.
    public var finalWidthFraction: CGFloat {
        didSet { defaults.set(finalWidthFraction, forKey: finalWidthFractionDefaultsKey) }
    }
    
    /// Hard ceiling, in points, that the final logo width is clamped to.
    public var maxFinalWidth: CGFloat {
        didSet { defaults.set(maxFinalWidth, forKey: maxFinalWidthDefaultsKey) }
    }
    
    /// Multiplier applied to the largest screen dimension to derive the logo's starting width.
    public var startWidthMultiplier: CGFloat {
        didSet { defaults.set(startWidthMultiplier, forKey: startWidthMultiplierDefaultsKey) }
    }
    
    /// Tint color applied to the splash image in Light appearance.
    public var lightTintColor: Color {
        didSet {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(lightTintColor), requiringSecureCoding: false) {
                defaults.set(data, forKey: lightTintColorDefaultsKey)
            }
        }
    }
    
    /// Tint color applied to the splash image in Dark appearance.
    public var darkTintColor: Color {
        didSet {
            if let data = try? NSKeyedArchiver.archivedData(withRootObject: UIColor(darkTintColor), requiringSecureCoding: false) {
                defaults.set(data, forKey: darkTintColorDefaultsKey)
            }
        }
    }
    
    /// Path used to mask the splash image. Override to use a different logo silhouette.
    public let logoPath: Path
    
    /// Optional asset-catalog image used as the splash mask silhouette.
    public var logoMaskAssetName: String? {
        resolvedLogoMaskAssetName
    }
    
    /// Image used as the splash mask silhouette when `logoMaskAssetName` is configured.
    public var logoMaskImage: Image? {
        guard let logoMaskAssetName else { return nil }
        return Image(logoMaskAssetName, bundle: imageCatalog.bundle)
    }
    
    /// Resolves the active tint color for the provided color scheme.
    public func tintColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkTintColor : lightTintColor
    }
    
    /// The aspectRatio of the Logo image
    public var gradientImageAspectRatio: CGFloat {
        guard
            let size = currentImageSize,
            size.height > 0
        else {
            if
                let logoMaskImageSize,
                logoMaskImageSize.height > 0
            {
                return logoMaskImageSize.width / logoMaskImageSize.height
            }
            return nativeAspectRatio(for: logoPath)
        }
        return size.width / size.height
    }
    
    /// Native pixel size of the logo-mask asset image, if configured and available.
    public var logoMaskImageSize: CGSize? {
        guard let logoMaskAssetName else { return nil }
        return UIImage(named: logoMaskAssetName, in: imageCatalog.bundle, compatibleWith: nil)?.size
    }
    
    public func nativeAspectRatio(for path: Path) -> CGFloat {
        let bounds = path.boundingRect
        return bounds.width / bounds.height
    }
    
    /// Bumped to signal that the splash animation should play again from the start. Used for testing
    public private(set) var animationRestartToken = UUID()
    
    /// Creates a splash image store, optionally with a custom bundled image catalog.
    public init(
        imageCatalog: SplashImageCatalog = .default,
        userDefaults: UserDefaults = .standard,
        customImageURL: URL? = nil,
        logoPath: Path? = nil
    ) {
        self.resolvedLogoMaskAssetName = logoPath == nil ? imageCatalog.logoMaskAssetName : nil
        self.logoPath = logoPath ?? Logo.path
        self.imageCatalog = imageCatalog
        self.defaults = userDefaults
        self.customImageURL = customImageURL ?? SplashImageStore.customImageURL
        
        let fallbackSelection = imageCatalog.bundledAssetNames.first.map(SplashImageSelection.asset) ?? .noOverlay
        let defaults = userDefaults
        
        if
            let data = defaults.data(forKey: selectionDefaultsKey),
            let decoded = try? JSONDecoder().decode(
                SplashImageSelection.self,
                from: data
            )
        {
            self.selection = decoded
        } else {
            self.selection = fallbackSelection
        }
        
        if
            let raw = defaults.string(forKey: animationTypeDefaultsKey),
            let decoded = SplashAnimationType(rawValue: raw)
        {
            self.animationType = decoded
        } else {
            self.animationType = .scale
        }
        
        if
            let raw = defaults.string(forKey: timingCurveDefaultsKey),
            let decoded = SplashTimingCurve(rawValue: raw)
        {
            self.timingCurve = decoded
        } else {
            self.timingCurve = .linear
        }
        
        self.animationDuration = defaults.object(forKey: animationDurationDefaultsKey) as? TimeInterval ?? 1.0
        self.animationDelay = defaults.object(forKey: animationDelayDefaultsKey) as? TimeInterval ?? 0.0
        self.finalWidthFraction = defaults.object(forKey: finalWidthFractionDefaultsKey) as? CGFloat ?? 0.6
        self.maxFinalWidth = defaults.object(forKey: maxFinalWidthDefaultsKey) as? CGFloat ?? 350
        self.startWidthMultiplier = defaults.object(forKey: startWidthMultiplierDefaultsKey) as? CGFloat ?? 2
        
        if let data = defaults.data(forKey: lightTintColorDefaultsKey),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            self.lightTintColor = Color(uiColor)
        } else {
            self.lightTintColor = .primary
        }
        
        if let data = defaults.data(forKey: darkTintColorDefaultsKey),
           let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
            self.darkTintColor = Color(uiColor)
        } else {
            self.darkTintColor = .primary
        }
        
        if FileManager.default.fileExists(atPath: self.customImageURL.path(percentEncoded: false)) {
            self.customImageData = try? Data(contentsOf: self.customImageURL)
        }
        
        // Fall back to a bundled asset if the custom file went missing.
        if case .custom = self.selection, customImageData == nil {
            self.selection = fallbackSelection
        }
        
        if
            case .asset(let selectedAssetName) = self.selection,
            !imageCatalog.bundledAssetNames.contains(selectedAssetName)
        {
            self.selection = fallbackSelection
        }
    }
    
    public static var customImageURL: URL {
        URL.documentsDirectory.appending(path: customImageFileName)
    }
    
    /// Sets a custom splash image from raw data and persists it to disk.
    public func setCustomImage(data: Data) throws {
        try data.write(to: customImageURL, options: .atomic)
        customImageData = data
        selection = .custom
    }
    
    /// Forces the splash animation to restart on observing views.
    public func restartAnimation() {
        animationRestartToken = UUID()
    }
    
    /// The image currently chosen for the splash screen, or `nil` if it can't be resolved.
    public var currentImage: Image? {
        switch selection {
            case .noOverlay:
                return nil
            case .asset(let name):
                return Image(name, bundle: imageCatalog.bundle)
            case .custom:
                guard let data = customImageData, let uiImage = UIImage(data: data) else {
                    return nil
                }
                return Image(uiImage: uiImage)
        }
    }
    
    /// Native pixel size of the current image, used to derive the gradient aspect ratio.
    public var currentImageSize: CGSize? {
        switch selection {
            case .noOverlay:
                return nil
            case .asset(let name):
                return UIImage(named: name, in: imageCatalog.bundle, compatibleWith: nil)?.size
            case .custom:
                guard let data = customImageData else { return nil }
                return UIImage(data: data)?.size
        }
    }
    
    private func persistSelection() {
        guard let data = try? JSONEncoder().encode(selection) else { return }
        defaults.set(data, forKey: selectionDefaultsKey)
    }
}
