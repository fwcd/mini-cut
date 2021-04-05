import Foundation
import SpriteKit

/// A simple UI control that displays a label and performs an action when clicked.
final class Button: SKSpriteNode, SKInputHandler {
    private var controllerSubscription: Subscription!
    
    let label: SKNode
    private let inactiveBgColor: Color
    private let activeBgColor: Color
    private let padding: CGFloat
    private let action: ((Button) -> Void)?
    
    /// A toggle state that overrides the usual input handling.
    var isToggled: Bool? {
        didSet {
            color = (isToggled ?? false) ? activeBgColor : inactiveBgColor
        }
    }
    
    init(
        controller: GenericDragController,
        label: SKNode,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding,
        inactiveBgColor: Color = ViewDefaults.inactiveBgColor,
        activeBgColor: Color = ViewDefaults.activeBgColor,
        action: ((Button) -> Void)? = nil
    ) {
        self.label = label
        self.inactiveBgColor = inactiveBgColor
        self.activeBgColor = activeBgColor
        self.padding = padding
        self.action = action
        
        super.init(texture: nil, color: inactiveBgColor, size: CGSize(width: size.width + padding, height: size.height + padding))
        controllerSubscription = controller.register(node: self)
        
        addChild(label)
    }
    
    /// Creates a textual button.
    convenience init(
        controller: GenericDragController,
        _ text: String,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        fontSize: CGFloat = ViewDefaults.fontSize,
        fontName: String = ViewDefaults.fontName,
        action: ((Button) -> Void)? = nil
    ) {
        let label = Label(text, fontSize: fontSize, fontName: fontName)
        let frameSize = label.frame.size
        let size = CGSize(width: width ?? frameSize.width, height: height ?? frameSize.height)
        self.init(controller: controller, label: label, size: size, action: action)
    }
    
    /// Creates a textural button.
    convenience init(
        controller: GenericDragController,
        iconTexture: SKTexture,
        size: CGFloat = ViewDefaults.fontSize,
        action: ((Button) -> Void)? = nil
    ) {
        let size = CGSize(width: size, height: size)
        let label = SKSpriteNode(texture: iconTexture, size: size)
        self.init(controller: controller, label: label, size: size, action: action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    private func active(at point: CGPoint) -> Bool {
        parent.map { contains(convert(point, to: $0)) } ?? false
    }
    
    func inputDown(at point: CGPoint) {
        if isToggled == nil {
            color = activeBgColor
        }
    }
    
    func inputDragged(to point: CGPoint) {
        if isToggled == nil {
            color = active(at: point) ? activeBgColor : inactiveBgColor
        }
    }
    
    func inputUp(at point: CGPoint) {
        color = inactiveBgColor
        if active(at: point) {
            action?(self)
        }
    }
}
