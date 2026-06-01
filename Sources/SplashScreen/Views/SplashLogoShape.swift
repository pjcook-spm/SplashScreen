import SwiftUI

struct SplashLogoShape: Shape {
    let logoPath: Path

    func path(in rect: CGRect) -> Path {

        let path = logoPath
        // Scale the original PDF coordinates, then centre within `rect`.
        let bounds = path.boundingRect

        let scale = min(
            rect.width / bounds.width,
            rect.height / bounds.height
        )

        let scaledWidth = bounds.width * scale
        let scaledHeight = bounds.height * scale

        let offsetX = rect.minX + (rect.width - scaledWidth) / 2
        let offsetY = rect.minY + (rect.height - scaledHeight) / 2

        let transform = CGAffineTransform(translationX: offsetX, y: offsetY)
            .scaledBy(x: scale, y: scale)
            .translatedBy(
                x: -bounds.minX,
                y: -bounds.minY
            )

        return path.applying(transform)
    }
}
