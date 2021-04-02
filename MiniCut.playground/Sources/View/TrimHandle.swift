import Foundation
import SpriteKit

/// A control for trimming a clip in the timeline.
final class TrimHandle: SKShapeNode {
    enum Side {
        case left
        case right
        
        var sign: CGFloat {
            switch self {
            case .left:
                return 1
            case .right:
                return -1
            }
        }
    }
    
    init(
        side: Side,
        in size: CGSize,
        thickness: CGFloat = ViewDefaults.trimHandleThickness,
        color: Color = ViewDefaults.trimHandleColor
    ) {
        super.init()
        
        let path = CGMutablePath()
        let sign = side.sign
        path.move(to: CGPoint(x: sign * (size.width / 2), y: size.height / 2))
        path.addLine(to: CGPoint(x: -sign * (size.width / 2), y: size.height / 2))
        path.addLine(to: CGPoint(x: -sign * (size.width / 2), y: -(size.height / 2)))
        path.addLine(to: CGPoint(x: sign * (size.width / 2), y: -(size.height / 2)))
        self.path = path
        
        lineWidth = thickness
        lineJoin = .bevel
        strokeColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
