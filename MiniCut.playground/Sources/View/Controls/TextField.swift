import Foundation
import SpriteKit

private let log = Logger(name: "View.Controls.TextField")

/// A UI element that lets the user enter text.
final class TextField: SKSpriteNode {
    private var controllerSubscription: Subscription!
    
    private var label: SKLabelNode!
    private let onChange: ((String) -> Void)?
    
    /// Whether the text field is selected. Should only be set
    /// from TextFieldSelectionController, not manually.
    var isSelected: Bool = false {
        didSet { updateBackground() }
    }
    
    init(
        controller: TextFieldSelectionController,
        size: CGSize,
        text: String = "",
        fontSize: CGFloat = ViewDefaults.textFieldFontSize,
        fontName: String = ViewDefaults.fontName,
        fontColor: Color = ViewDefaults.primary,
        onChange: ((String) -> Void)? = nil
    ) {
        self.onChange = onChange
        
        super.init(texture: nil, color: ViewDefaults.fieldInactiveBgColor, size: size)
        controllerSubscription = controller.register(textField: self)
        
        label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = fontName
        label.fontColor = fontColor
        label.verticalAlignmentMode = .center
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    private func updateBackground() {
        color = isSelected ? ViewDefaults.fieldActiveBgColor : ViewDefaults.fieldInactiveBgColor
    }
    
    func enter(keys: [KeyboardKey]) {
        let newText = edit(label.text ?? "", with: keys)
        log.debug("Contents: '\(newText)'")
        onChange?(newText)
        label.text = newText
    }
    
    private func edit(_ s: String, with keys: [KeyboardKey]) -> String {
        var s = s
        for key in keys {
            switch key {
            case .char(let c):
                s.append(c)
            case .backspace:
                if !s.isEmpty {
                    s.removeLast()
                }
            default:
                break
            }
        }
        return s
    }
}
