import SwiftUI

enum Logo {
    static let path: Path = {
        var path = Path()

        // Extracted from uploaded SVG
        path.move(to: CGPoint(x: 106.666, y: 203.466))
        path.addLine(to: CGPoint(x: 106.666, y: 203.021))
        path.addLine(to: CGPoint(x: 109.558, y: 203.021))
        path.addLine(to: CGPoint(x: 112.133, y: 209.847))
        path.addLine(to: CGPoint(x: 114.522, y: 203.021))
        path.addLine(to: CGPoint(x: 117.472, y: 203.021))
        path.addLine(to: CGPoint(x: 117.472, y: 203.466))
        path.addLine(to: CGPoint(x: 116.582, y: 203.466))
        path.addCurve(
            to: CGPoint(x: 116.102, y: 203.958),
            control1: CGPoint(x: 116.262, y: 203.466),
            control2: CGPoint(x: 116.102, y: 203.63)
        )
        path.addLine(to: CGPoint(x: 116.102, y: 210.807))
        path.addCurve(
            to: CGPoint(x: 116.699, y: 211.228),
            control1: CGPoint(x: 116.102, y: 211.088),
            control2: CGPoint(x: 116.301, y: 211.228)
        )
        path.addLine(to: CGPoint(x: 117.472, y: 211.228))
        path.addLine(to: CGPoint(x: 117.472, y: 211.673))
        path.addLine(to: CGPoint(x: 113.515, y: 211.673))
        path.addLine(to: CGPoint(x: 113.515, y: 211.228))
        path.addLine(to: CGPoint(x: 114.358, y: 211.228))
        path.addCurve(
            to: CGPoint(x: 114.873, y: 210.807),
            control1: CGPoint(x: 114.506, y: 211.228),
            control2: CGPoint(x: 114.873, y: 211.043)
        )
        path.addLine(to: CGPoint(x: 114.873, y: 203.455))
        path.addLine(to: CGPoint(x: 112.005, y: 211.673))
        path.addLine(to: CGPoint(x: 111.607, y: 211.673))
        path.addLine(to: CGPoint(x: 108.528, y: 203.49))
        path.addLine(to: CGPoint(x: 108.528, y: 209.776))
        path.addCurve(
            to: CGPoint(x: 109.944, y: 211.228),
            control1: CGPoint(x: 108.528, y: 210.323),
            control2: CGPoint(x: 108.637, y: 211.228)
        )
        path.addLine(to: CGPoint(x: 109.944, y: 211.673))
        path.addLine(to: CGPoint(x: 106.666, y: 211.673))
        path.addLine(to: CGPoint(x: 106.666, y: 211.228))
        path.addCurve(
            to: CGPoint(x: 108.048, y: 209.847),
            control1: CGPoint(x: 107.166, y: 211.228),
            control2: CGPoint(x: 108.048, y: 210.721)
        )
        path.addLine(to: CGPoint(x: 108.048, y: 203.876))
        path.addCurve(
            to: CGPoint(x: 107.532, y: 203.466),
            control1: CGPoint(x: 108.048, y: 203.603),
            control2: CGPoint(x: 107.876, y: 203.466)
        )
        path.addLine(to: CGPoint(x: 106.666, y: 203.466))
        path.closeSubpath()

        return path
    }()
}
