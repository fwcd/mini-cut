import Foundation
import SpriteKit

/// A background (time) marker on the timeline.
final class TimelineMark: SKSpriteNode {
    convenience init(height: CGFloat, color: NSColor = ViewDefaults.quaternary) {
        self.init(color: color, size: CGSize(width: 1, height: height))
    }
}
