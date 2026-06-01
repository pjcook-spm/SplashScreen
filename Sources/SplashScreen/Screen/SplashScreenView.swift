import SwiftUI

struct SplashScreenView: View {
    @Environment(SplashImageStore.self) private var imageStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var startDate = Date()

    private struct LogoLayout {
        let frameWidth: CGFloat
        let frameHeight: CGFloat
        let revealWidth: CGFloat
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
                frameHeight: width / imageStore.gradientImageAspectRatio,
                revealWidth: width
            )
        case .wipe:
            return LogoLayout(
                frameWidth: finalWidth,
                frameHeight: finalHeight,
                revealWidth: max(0, finalWidth * progress)
            )
        }
    }

    var body: some View {
        GeometryReader { geo in

            let maxDimension = max(geo.size.width, geo.size.height)

            // Final width tracks the container width up to a hard ceiling.
            let finalWidth = min(
                geo.size.width * imageStore.finalWidthFraction,
                imageStore.maxFinalWidth
            )

            // Start scaled relative to the largest screen dimension.
            let startWidth = maxDimension * imageStore.startWidthMultiplier

            let finalHeight = finalWidth / imageStore.gradientImageAspectRatio

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
                        frameWidth: layout.frameWidth,
                        frameHeight: layout.frameHeight,
                        revealWidth: layout.revealWidth,
                        tintColor: tint
                    )
                    .tag(1)
                }
                .frame(
                    width: geo.size.width,
                    height: geo.size.height
                )
            }
            .onAppear {
                startDate = Date()
            }
            .onChange(of: imageStore.selection) {
                startDate = Date()
            }
            .onChange(of: imageStore.animationDuration) {
                startDate = Date()
            }
            .onChange(of: imageStore.animationDelay) {
                startDate = Date()
            }
            .onChange(of: imageStore.finalWidthFraction) {
                startDate = Date()
            }
            .onChange(of: imageStore.maxFinalWidth) {
                startDate = Date()
            }
            .onChange(of: imageStore.startWidthMultiplier) {
                startDate = Date()
            }
            .onChange(of: imageStore.animationType) {
                startDate = Date()
            }
            .onChange(of: imageStore.timingCurve) {
                startDate = Date()
            }
            .onChange(of: imageStore.animationRestartToken) {
                startDate = Date()
            }
        }
        .ignoresSafeArea()
    }

}

#Preview {
    SplashScreenView()
        .environment(SplashImageStore())
}

