import Foundation
import SpriteKit

/// A simple UI control that displays a label and performs an action when clicked.
public class Button: SKSpriteNode {
    public convenience init(label: SKNode, padding: CGFloat = ViewDefaults.padding) {
        self.init(color: NSColor(white: 1, alpha: 0.2), size: CGSize(width: label.frame.width + padding, height: label.frame.height + padding))
        addChild(label)
    }
    
    /// Creates a textual button.
    public convenience init(
        _ text: String,
        fontSize: CGFloat = ViewDefaults.fontSize,
        fontName: String = ViewDefaults.fontName
    ) {
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = fontName
        label.position = CGPoint(x: 0, y: -label.frame.size.height / 2)
        self.init(label: label)
    }
}
