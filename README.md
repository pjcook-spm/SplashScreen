# SplashScreen

A SwiftUI package for rendering a logo-masked splash screen with configurable animation, optional image overlays, and runtime settings UI.

By default, the splash mask uses `Logo.path`, and you can now override it via `SplashImageStore(logoPath:)`.

## What it does

- Draws a vector logo mask (`Logo.path`) and reveals it using animation.
- Supports two reveal styles: `scale` and `wipe`.
- Supports multiple timing curves, including spring curves.
- Lets users pick from bundled images, no overlay, or a custom photo.
- Persists splash configuration in `UserDefaults` and custom image data in Documents.

## Requirements

- iOS 18+
- Swift 6 mode (`swiftLanguageModes: [.v6]`)
- Xcode with Swift Package Manager support

## Installation

### Swift Package Manager (Xcode)

1. Open your app project in Xcode.
2. Go to **File > Add Package Dependencies...**
3. Add this repository URL.
4. Link the `SplashScreen` library product to your app target.

### Local package during development

Add the package from local path in Xcode and select:

- Package: `SplashScreen`
- Product: `SplashScreen`

## Public API

The package now exposes the following public API for app integration:

- `SplashScreenView`
- `SplashSettingsView`
- `SplashImageStore`
- `SplashImageCatalog`
- `SplashImageSelection`
- `SplashAnimationType`
- `SplashTimingCurve`

## Basic usage pattern

Wire the store into your app environment and present the splash/settings views.

```swift
import SwiftUI
import SplashScreen

@main
struct DemoApp: App {
    @State private var splashStore = SplashImageStore(
        imageCatalog: SplashImageCatalog(
            bundledAssetNames: ["SplashGradientA", "SplashGradientB"],
            displayNames: [
                "SplashGradientA": "Blue Aurora",
                "SplashGradientB": "Sunset"
            ],
            bundle: .main
        ),
        logoPath: Logo.path
    )

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                SplashScreenView()
                    .toolbar {
                        NavigationLink("Settings") {
                            SplashSettingsView()
                        }
                    }
            }
            .environment(splashStore)
        }
    }
}
```

## Configuration options in `SplashImageStore`

- `selection`: no overlay, bundled asset, or custom photo
- `animationType`: scale or wipe
- `timingCurve`: linear/ease/spring presets
- `animationDuration` and `animationDelay`
- `finalWidthFraction`, `maxFinalWidth`, `startWidthMultiplier`
- `lightTintColor`, `darkTintColor`
- `logoPath` override for custom logo silhouettes

Custom logo path example:

```swift
let customStore = SplashImageStore(
    imageCatalog: .default,
    logoPath: MyBrandLogo.path
)
```

Additional public helpers:

- `setCustomImage(data:)` to persist a custom image and select it
- `restartAnimation()` to trigger replay
- `customImageData`, `currentImage`, and `currentImageSize` for inspection

## Assets and custom images

- Bundled asset names are provided via `SplashImageCatalog`.
- Custom imported image is stored at:
  - `URL.documentsDirectory.appending(path: "custom_splash_image.png")`

## Testing

`swift test` is not the right workflow for this iOS-only package. Run tests against an iOS Simulator destination instead.

```bash
cd /Users/pj/Development/SplashScreen
xcrun simctl list devices available | grep "iPhone"
xcodebuild test -scheme SplashScreen -destination 'id=<SIMULATOR_ID>'
```

You can also run tests directly in Xcode by opening the package and running the `SplashScreen` scheme.

## License

This project is licensed under the MIT License. See `license.md`.
