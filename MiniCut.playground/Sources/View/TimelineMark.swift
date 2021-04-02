import Foundation
import SpriteKit

/// A background (time) marker on the timeline.
final class TimelineMark: SKSpriteNode {
    init(
        height: CGFloat,
        thickness: CGFloat = 1,
        color: Color = ViewDefaults.quaternary
    ) {
        super.init(texture: nil, color: color, size: CGSize(width: thickness, height: height))
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
