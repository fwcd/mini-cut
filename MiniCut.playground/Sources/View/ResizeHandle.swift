import Foundation
import SpriteKit

/// A control for resizing a clip.
class ResizeHandle: SKShapeNode {
    init(radius: CGFloat = ViewDefaults.resizeHandleRadius, color: Color = ViewDefaults.resizeHandleColor) {
        super.init()
        
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: 2 * radius, height: 2 * radius), transform: nil)
        fillColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
