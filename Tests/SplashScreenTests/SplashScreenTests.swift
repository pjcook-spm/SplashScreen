import Testing
@testable import SplashScreen

@Suite("Splash timing curves")
struct SplashTimingCurveTests {
    // MARK: - Happy paths

    @Test("Linear progress is clamped to one when elapsed exceeds duration")
    func linearProgressClampsToOne() {
        let sut = SplashTimingCurve.linear

        let result = sut.progress(elapsed: 2.0, duration: 1.0)

        #expect(result == 1)
    }

    @Test("Ease-in-out starts at zero progress when elapsed is zero")
    func zeroElapsedReturnsZero() {
        let sut = SplashTimingCurve.easeInOut

        let result = sut.progress(elapsed: 0, duration: 1.0)

        #expect(result == 0)
    }

    // MARK: - Un-happy paths

    @Test("Any curve returns one progress when duration is non-positive")
    func nonPositiveDurationReturnsOne() {
        let sut = SplashTimingCurve.bouncySpring

        let result = sut.progress(elapsed: 0.4, duration: 0)

        #expect(result == 1)
    }
}
