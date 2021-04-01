import Foundation
import SpriteKit

/// A control for trimming a clip in the timeline.
final class TrimHandle: SKShapeNode {
    convenience init(
        in size: CGSize,
        thickness: CGFloat = ViewDefaults.trimHandleThickness,
        color: Color = ViewDefaults.trimHandleColor
    ) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: size.width / 2, y: size.height / 2))
        path.addLine(to: CGPoint(x: -(size.width / 2), y: size.height / 2))
        path.addLine(to: CGPoint(x: -(size.width / 2), y: -(size.height / 2)))
        path.addLine(to: CGPoint(x: size.width / 2, y: -(size.height / 2)))
        self.init(path: path)
        
        lineWidth = thickness
        lineJoin = .bevel
        strokeColor = color
    }
}
