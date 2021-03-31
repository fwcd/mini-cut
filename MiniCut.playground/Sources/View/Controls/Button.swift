import Foundation
import SpriteKit

/// A simple UI control that displays a label and performs an action when clicked.
public class Button: SKSpriteNode {
    var label: SKNode!
    
    private var inactiveBgColor: NSColor!
    private var activeBgColor: NSColor!
    private var padding: CGFloat!
    private var action: ((Button) -> Void)?
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    public convenience init(
        label: SKNode,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding,
        inactiveBgColor: NSColor = ViewDefaults.inactiveBgColor,
        activeBgColor: NSColor = ViewDefaults.activeBgColor,
        action: ((Button) -> Void)? = nil
    ) {
        self.init(color: inactiveBgColor, size: CGSize(width: size.width + padding, height: size.height + padding))
        self.label = label
        self.inactiveBgColor = inactiveBgColor
        self.activeBgColor = activeBgColor
        self.padding = padding
        self.action = action
        addChild(label)
    }
    
    /// Creates a textual button.
    public convenience init(
        _ text: String,
        fontSize: CGFloat = ViewDefaults.fontSize,
        fontName: String = ViewDefaults.fontName,
        action: ((Button) -> Void)? = nil
    ) {
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = fontName
        self.init(label: label, size: label.frame.size, action: action)
        label.position = CGPoint(x: 0, y: padding - (size.height / 2))
    }
    
    /// Creates a textural button.
    public convenience init(
        iconTexture: SKTexture,
        size: CGFloat = ViewDefaults.fontSize,
        action: ((Button) -> Void)? = nil
    ) {
        let size = CGSize(width: size, height: size)
        let label = SKSpriteNode(texture: iconTexture, size: size)
        self.init(label: label, size: size, action: action)
    }
    
    private func active(with event: NSEvent) -> Bool {
        parent.map { contains(event.location(in: $0)) } ?? false
    }
    
    public override func mouseDown(with event: NSEvent) {
        color = activeBgColor
    }
    
    public override func mouseDragged(with event: NSEvent) {
        color = active(with: event) ? activeBgColor : inactiveBgColor
    }
    
    public override func mouseUp(with event: NSEvent) {
        color = inactiveBgColor
        if active(with: event) {
            action?(self)
        }
    }
    
    // TODO: Image-labelled buttons
}
