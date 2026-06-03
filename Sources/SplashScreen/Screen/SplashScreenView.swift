import SwiftUI

/// Renders the animated splash logo using the current `SplashImageStore` configuration.
public struct SplashScreenView: View {
    @Environment(SplashImageStore.self) private var imageStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var startDate = Date()
    @State private var hasReportedCompletion = false

    public let onAnimationCompleted: @MainActor () -> Void

    private struct LogoLayout {
        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let revealWidth: CGFloat
        let opacity: CGFloat
    }

    private func logoLayout(
        at date: Date,
        startWidth: CGFloat,
        finalWidth: CGFloat,
        finalHeight: CGFloat
    ) -> LogoLayout {
        let elapsed = date.timeIntervalSince(startDate) - imageStore.animationDelay
        let progress = imageStore.timingCurve.progress(
            elapsed: elapsed,
            duration: imageStore.animationDuration
        )

        switch imageStore.animationType {
            case .scale:
                // Spring overshoot can drive the interpolated width below zero when
                // shrinking from a large start to a small final; clamp to keep the
                // frame dimensions valid.
                let width = max(0, startWidth + ((finalWidth - startWidth) * progress))
                return LogoLayout(
                    frameWidth: width,
                    frameHeight: width / imageStore.logoMaskImageAspectRatio,
                    revealWidth: width,
                    opacity: 1
                )
            case .wipe:
                return LogoLayout(
                    frameWidth: finalWidth,
                    frameHeight: finalHeight,
                    revealWidth: max(0, finalWidth * progress),
                    opacity: 1
                )
            case .fadeIn:
                return LogoLayout(
                    frameWidth: finalWidth,
                    frameHeight: finalHeight,
                    revealWidth: finalWidth,
                    opacity: max(0, min(1, progress))
                )
            case .fadeOut:
                return LogoLayout(
                    frameWidth: finalWidth,
                    frameHeight: finalHeight,
                    revealWidth: finalWidth,
                    opacity: max(0, min(1, 1 - progress))
                )
        }
    }

    public init(onAnimationCompleted: @escaping @MainActor () -> Void = {}) {
        self.onAnimationCompleted = onAnimationCompleted
    }

    private func resetAnimation() {
        startDate = Date()
        hasReportedCompletion = false
    }

    private func reportAnimationCompletionIfNeeded(at date: Date) {
        guard hasReportedCompletion == false else { return }

        let completionTime = max(0, imageStore.animationDelay) + max(0, imageStore.animationDuration)
        let elapsedSinceStart = date.timeIntervalSince(startDate)
        guard elapsedSinceStart >= completionTime else { return }

        hasReportedCompletion = true
        onAnimationCompleted()
    }

    public var body: some View {
        GeometryReader { geo in

            let maxDimension = max(geo.size.width, geo.size.height)

            // Final width tracks the container width up to a hard ceiling.
            let finalWidth = min(
                geo.size.width * imageStore.finalWidthFraction,
                imageStore.maxFinalWidth
            )

            // Start scaled relative to the largest screen dimension.
            let startWidth = maxDimension * imageStore.startWidthMultiplier

            let finalHeight = finalWidth / imageStore.logoMaskImageAspectRatio

            TimelineView(.animation) { timeline in

                let layout = logoLayout(
                    at: timeline.date,
                    startWidth: startWidth,
                    finalWidth: finalWidth,
                    finalHeight: finalHeight
                )

                Canvas { context, size in

                    guard let symbol = context.resolveSymbol(id: 1) else {
                        return
                    }

                    context.draw(
                        symbol,
                        at: CGPoint(
                            x: size.width / 2,
                            y: size.height / 2
                        ),
                        anchor: .center
                    )
                } symbols: {
                    let tint = (imageStore.selection == .noOverlay) ? imageStore.tintColor(for: colorScheme) : nil
                    LogoMaskImage(
                        image: imageStore.currentImage,
                        logoPath: imageStore.logoPath,
                        logoMaskImage: imageStore.logoMaskImage,
                        frameWidth: layout.frameWidth,
                        frameHeight: layout.frameHeight,
                        revealWidth: layout.revealWidth,
                        tintColor: tint
                    )
                    .opacity(layout.opacity)
                    .tag(1)
                }
                .frame(
                    width: geo.size.width,
                    height: geo.size.height
                )
                .onChange(of: timeline.date, initial: true) { _, newDate in
                    reportAnimationCompletionIfNeeded(at: newDate)
                }
            }
            .onAppear {
                resetAnimation()
            }
            .onChange(of: imageStore.selection) {
                resetAnimation()
            }
            .onChange(of: imageStore.animationDuration) {
                resetAnimation()
            }
            .onChange(of: imageStore.animationDelay) {
                resetAnimation()
            }
            .onChange(of: imageStore.finalWidthFraction) {
                resetAnimation()
            }
            .onChange(of: imageStore.maxFinalWidth) {
                resetAnimation()
            }
            .onChange(of: imageStore.startWidthMultiplier) {
                resetAnimation()
            }
            .onChange(of: imageStore.animationType) {
                resetAnimation()
            }
            .onChange(of: imageStore.timingCurve) {
                resetAnimation()
            }
            .onChange(of: imageStore.animationRestartToken) {
                resetAnimation()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreenView()
        .environment(SplashImageStore())
}
