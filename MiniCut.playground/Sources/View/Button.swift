import Foundation
import SpriteKit

public class Button: SKSpriteNode {
    public convenience init(_ text: String, padding: CGFloat = 10) {
        let label = SKLabelNode(text: text)
        label.position = CGPoint(x: 0, y: -label.frame.size.height / 2)
        self.init(color: NSColor(white: 1, alpha: 0.2), size: CGSize(width: label.frame.width + padding, height: label.frame.height + padding))
        addChild(label)
    }
}
