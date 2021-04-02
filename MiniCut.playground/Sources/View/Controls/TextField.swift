import Foundation
import SpriteKit

private let log = Logger(name: "View.Controls.TextField")

/// A UI element that lets the user enter text.
final class TextField: SKSpriteNode {
    private var label: SKLabelNode!
    
    private var onChange: ((String) -> Void)?
    
    /// Whether the text field is selected. Should only be set
    /// from TextFieldSelectionController, not manually.
    var isSelected: Bool = false {
        didSet { updateBackground() }
    }
    
    convenience init(
        size: CGSize,
        text: String = "",
        fontSize: CGFloat = ViewDefaults.textFieldFontSize,
        fontName: String = ViewDefaults.fontName,
        fontColor: Color = ViewDefaults.primary,
        onChange: ((String) -> Void)? = nil
    ) {
        self.init(color: ViewDefaults.fieldInactiveBgColor, size: size)
        self.onChange = onChange
        
        label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = fontName
        label.fontColor = fontColor
        label.verticalAlignmentMode = .center
        addChild(label)
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
