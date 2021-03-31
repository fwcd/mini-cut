import Foundation
import SpriteKit

/// The cursor used to scrub the project timeline.
final class TimelineCursor: SKShapeNode {
    convenience init(
        height: CGFloat,
        thickness: CGFloat = 0.5,
        knobWidth: CGFloat = 20,
        color: Color = ViewDefaults.cursorColor
    ) {
        let knobBezelHeight = knobWidth / 4
        let knobRestHeight = knobWidth / 2
        let knobHeight = knobBezelHeight + knobRestHeight
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -(knobWidth / 2), y: height / 2))
        path.addLine(to: CGPoint(x: (knobWidth / 2), y: height / 2))
        path.addLine(to: CGPoint(x: (knobWidth / 2), y: (height / 2) - knobBezelHeight))
        path.addLine(to: CGPoint(x: thickness, y: (height / 2) - knobHeight))
        path.addLine(to: CGPoint(x: thickness, y: -(height / 2)))
        path.addLine(to: CGPoint(x: -thickness, y: -(height / 2)))
        path.addLine(to: CGPoint(x: thickness, y: (height / 2) - knobHeight))
        path.addLine(to: CGPoint(x: -(knobWidth / 2), y: (height / 2) - knobBezelHeight))
        path.addLine(to: CGPoint(x: -(knobWidth / 2), y: height / 2))
        self.init(path: path)
        
        fillColor = color
        strokeColor = color
    }
}
