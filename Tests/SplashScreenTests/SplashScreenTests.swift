import Foundation
import Testing
@testable import SplashScreen

@Suite("Splash model behavior")
struct SplashModelTests {
    // MARK: - Happy paths

    @Test("Linear progress is clamped to one when elapsed exceeds duration")
    func linearProgressClampsToOne() {
        let sut = SplashTimingCurve.linear

        let result = sut.progress(elapsed: 2.0, duration: 1.0)

        #expect(result == 1)
    }

    @Test("Linear progress returns fractional value when elapsed is within duration")
    func linearProgressReturnsFractionalValue() {
        let sut = SplashTimingCurve.linear

        let result = sut.progress(elapsed: 0.25, duration: 1.0)

        #expect(result == 0.25)
    }

    @Test("Ease-in-out starts at zero progress when elapsed is zero")
    func zeroElapsedReturnsZero() {
        let sut = SplashTimingCurve.easeInOut

        let result = sut.progress(elapsed: 0, duration: 1.0)

        #expect(result == 0)
    }

    @Test("Animation type display names are stable for UI labels")
    func animationTypeDisplayNamesMatchExpectedValues() {
        let scale = SplashAnimationType.scale
        let wipe = SplashAnimationType.wipe

        let scaleName = scale.displayName
        let wipeName = wipe.displayName

        #expect(scaleName == "Scale")
        #expect(wipeName == "Wipe")
    }

    @Test("Image catalog returns custom display name when mapped")
    func imageCatalogReturnsMappedDisplayName() {
        let sut = SplashImageCatalog(
            bundledAssetNames: ["logo_a"],
            displayNames: ["logo_a": "Logo A"],
            bundle: .main
        )

        let result = sut.displayName(for: "logo_a")

        #expect(result == "Logo A")
    }

    @Test("Image selection codable round-trip preserves associated asset value")
    func imageSelectionCodableRoundTripForAssetCase() throws {
        let sut = SplashImageSelection.asset("brand_hero")

        let encoded = try JSONEncoder().encode(sut)
        let decoded = try JSONDecoder().decode(SplashImageSelection.self, from: encoded)

        #expect(decoded == .asset("brand_hero"))
    }

    @MainActor
    @Test("Store reload restores a previously selected bundled asset using isolated defaults")
    func storeReloadRestoresSelectedBundledAsset() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let firstStore = buildSplashImageStore(
            bundledAssetNames: ["alpha", "beta"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        firstStore.selection = .asset("beta")

        let sut = buildSplashImageStore(
            bundledAssetNames: ["alpha", "beta"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .asset("beta"))
    }

    @MainActor
    @Test("Setting a custom image persists bytes and restores custom selection on reload")
    func setCustomImagePersistsDataAndSelection() throws {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let firstStore = buildSplashImageStore(
            bundledAssetNames: ["alpha"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        let payload = Data([0x01, 0x02, 0x03, 0x04])
        try firstStore.setCustomImage(data: payload)

        let sut = buildSplashImageStore(
            bundledAssetNames: ["alpha"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .custom)
        #expect(sut.customImageData == payload)
    }

    @MainActor
    @Test("Store uses documented default animation and layout settings when defaults are empty")
    func storeUsesDocumentedDefaultSettings() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let sut = buildSplashImageStore(
            bundledAssetNames: ["default_asset"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .asset("default_asset"))
        #expect(sut.animationType == .scale)
        #expect(sut.timingCurve == .linear)
        #expect(sut.animationDuration == 1.0)
        #expect(sut.animationDelay == 0.0)
        #expect(sut.finalWidthFraction == 0.6)
        #expect(sut.maxFinalWidth == 350)
        #expect(sut.startWidthMultiplier == 2)
    }

    @MainActor
    @Test("Store reload restores persisted animation and size settings from isolated defaults")
    func storeReloadRestoresPersistedAnimationAndSizeSettings() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let firstStore = buildSplashImageStore(
            bundledAssetNames: ["alpha"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        firstStore.animationType = .wipe
        firstStore.timingCurve = .easeInOut
        firstStore.animationDuration = 2.5
        firstStore.animationDelay = 0.4
        firstStore.finalWidthFraction = 0.73
        firstStore.maxFinalWidth = 420
        firstStore.startWidthMultiplier = 3.2

        let sut = buildSplashImageStore(
            bundledAssetNames: ["alpha"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.animationType == .wipe)
        #expect(sut.timingCurve == .easeInOut)
        #expect(sut.animationDuration == 2.5)
        #expect(sut.animationDelay == 0.4)
        #expect(sut.finalWidthFraction == 0.73)
        #expect(sut.maxFinalWidth == 420)
        #expect(sut.startWidthMultiplier == 3.2)
    }

    @MainActor
    @Test("Store defaults to no overlay when bundled catalog is empty")
    func storeDefaultsToNoOverlayWhenCatalogIsEmpty() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let sut = buildSplashImageStore(
            bundledAssetNames: [],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .noOverlay)
    }

    // MARK: - Un-happy paths

    @Test("Any curve returns one progress when duration is non-positive")
    func nonPositiveDurationReturnsOne() {
        let sut = SplashTimingCurve.bouncySpring

        let result = sut.progress(elapsed: 0.4, duration: 0)

        #expect(result == 1)
    }

    @Test("Image catalog falls back to asset name when no display mapping exists")
    func imageCatalogFallsBackToRawAssetName() {
        let sut = SplashImageCatalog(
            bundledAssetNames: ["logo_b"],
            displayNames: [:],
            bundle: .main
        )

        let result = sut.displayName(for: "logo_b")

        #expect(result == "logo_b")
    }

    @MainActor
    @Test("Store falls back to first bundled asset when persisted selection references missing asset")
    func storeFallsBackWhenPersistedAssetIsMissing() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let originalStore = buildSplashImageStore(
            bundledAssetNames: ["legacy_asset"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        originalStore.selection = .asset("legacy_asset")

        let sut = buildSplashImageStore(
            bundledAssetNames: ["new_default", "new_alt"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .asset("new_default"))
    }

    @MainActor
    @Test("Store falls back from custom selection when custom image file is missing")
    func storeFallsBackWhenCustomSelectionHasNoBackingFile() {
        let suiteName = "SplashModelTests.\(#function).\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let customImageURL = URL.temporaryDirectory.appending(path: "\(UUID().uuidString).png")
        defer {
            defaults.removePersistentDomain(forName: suiteName)
            try? FileManager.default.removeItem(at: customImageURL)
        }

        let originalStore = buildSplashImageStore(
            bundledAssetNames: ["fallback"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        originalStore.selection = .custom

        let sut = buildSplashImageStore(
            bundledAssetNames: ["fallback"],
            userDefaults: defaults,
            customImageURL: customImageURL
        )

        #expect(sut.selection == .asset("fallback"))
        #expect(sut.customImageData == nil)
    }
}

private extension SplashModelTests {
    @MainActor
    func buildSplashImageStore(
        bundledAssetNames: [String],
        userDefaults: UserDefaults,
        customImageURL: URL
    ) -> SplashImageStore {
        let imageCatalog = buildSplashImageCatalog(bundledAssetNames: bundledAssetNames)

        let sut = SplashImageStore(
            imageCatalog: imageCatalog,
            userDefaults: userDefaults,
            customImageURL: customImageURL
        )

        return sut
    }

    func buildSplashImageCatalog(bundledAssetNames: [String]) -> SplashImageCatalog {
        SplashImageCatalog(
            bundledAssetNames: bundledAssetNames,
            displayNames: [:],
            bundle: .main
        )
    }
}
