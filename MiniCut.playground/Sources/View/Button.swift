import Foundation
import SpriteKit

/// A simple UI control that displays a label and performs an action when clicked.
public class Button: SKSpriteNode {
    private var inactiveBgColor: NSColor!
    private var activeBgColor: NSColor!
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    public convenience init(
        label: SKNode,
        padding: CGFloat = ViewDefaults.padding,
        inactiveBgColor: NSColor = ViewDefaults.inactiveBgColor,
        activeBgColor: NSColor = ViewDefaults.activeBgColor
    ) {
        self.init(color: inactiveBgColor, size: CGSize(width: label.frame.width + padding, height: label.frame.height + padding))
        self.inactiveBgColor = inactiveBgColor
        self.activeBgColor = activeBgColor
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
    
    public override func mouseDown(with event: NSEvent) {
        color = activeBgColor
    }
    
    public override func mouseUp(with event: NSEvent) {
        color = inactiveBgColor
    }
    
    // TODO: Image-labelled buttons
}
