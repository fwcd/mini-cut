import Foundation
import SpriteKit

/// A background (time) marker on the timeline.
final class TimelineMark: SKSpriteNode {
    convenience init(
        height: CGFloat,
        thickness: CGFloat = 1,
        color: Color = ViewDefaults.quaternary
    ) {
        self.init(color: color, size: CGSize(width: thickness, height: height))
    }
}
