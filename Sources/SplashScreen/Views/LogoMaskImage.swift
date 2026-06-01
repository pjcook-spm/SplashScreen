import SwiftUI

/// Renders the splash image clipped to the logo path and revealed to `revealWidth`.
/// When `image` is `nil`, the logo is filled with `Color.primary` instead.
struct LogoMaskImage: View {

    let image: Image?
    let logoPath: Path
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    let revealWidth: CGFloat
    var tintColor: Color? = nil

    var body: some View {
        Group {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
                    .modifier(Colorize(if: tintColor))
            } else {
                (tintColor ?? Color.primary)
            }
        }
        .frame(width: frameWidth, height: frameHeight)
        .mask {
            SplashLogoShape(logoPath: logoPath)
                .mask(alignment: .leading) {
                    Rectangle()
                        .frame(width: revealWidth)
                }
        }
    }
}

private struct Colorize: ViewModifier {
    let color: Color?
    init(if color: Color?) { self.color = color }
    func body(content: Content) -> some View {
        if let color {
            content.colorMultiply(color)
        } else {
            content
        }
    }
}
