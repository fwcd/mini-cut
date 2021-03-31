import Foundation
import SpriteKit

/// A simple UI control that displays a label and performs an action when clicked.
public class Button: SKSpriteNode, SKInputHandler {
    var label: SKNode!
    
    private var inactiveBgColor: Color!
    private var activeBgColor: Color!
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
        inactiveBgColor: Color = ViewDefaults.inactiveBgColor,
        activeBgColor: Color = ViewDefaults.activeBgColor,
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
        let label = Label(text, fontSize: fontSize, fontName: fontName)
        self.init(label: label, size: label.frame.size, action: action)
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
    
    private func active(at point: CGPoint) -> Bool {
        parent.map { contains(convert(point, to: $0)) } ?? false
    }
    
    public func inputDown(at point: CGPoint) {
        color = activeBgColor
    }
    
    public func inputDragged(to point: CGPoint) {
        color = active(at: point) ? activeBgColor : inactiveBgColor
    }
    
    public func inputUp(at point: CGPoint) {
        color = inactiveBgColor
        if active(at: point) {
            action?(self)
        }
    }
    
    // TODO: Image-labelled buttons
}
