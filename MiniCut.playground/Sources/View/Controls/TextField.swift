import Foundation
import SpriteKit

/// A UI element that lets the user enter text.
final class TextField: SKSpriteNode {
    private var label: SKLabelNode!
    
    /// Whether the text field is selected. Should only be set
    /// from TextFieldSelectionController, not manually.
    var isSelected: Bool = false {
        didSet { updateBackground() }
    }
    
    convenience init(
        text: String = "",
        fontSize: CGFloat = ViewDefaults.fontSize,
        fontName: String = ViewDefaults.fontName,
        fontColor: Color = ViewDefaults.primary,
        onChange: @escaping (String) -> Void
    ) {
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontName = fontName
        label.fontColor = fontColor
        label.verticalAlignmentMode = .center
        
        // TODO: Store and fire onChange as needed
        
        self.init(color: ViewDefaults.fieldInactiveBgColor, size: label.frame.size)
        self.label = label
        addChild(label)
    }
    
    private func updateBackground() {
        color = isSelected ? ViewDefaults.fieldActiveBgColor : ViewDefaults.fieldInactiveBgColor
    }
    
    func enter(keys: [KeyboardKey]) {
        // TODO
    }
}
