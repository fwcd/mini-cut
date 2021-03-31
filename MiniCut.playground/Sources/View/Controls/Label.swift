import Foundation
import SpriteKit

/// A textual UI element. Wraps SKLabelNode by positioning it in a way
/// that interacts better with Button.
final class Label: SKLabelNode {
    convenience init(
        _ text: String,
        fontSize: CGFloat = ViewDefaults.fontSize,
        fontName: String = ViewDefaults.fontName
    ) {
        self.init(text: text)
        self.fontSize = fontSize
        self.fontName = fontName
        verticalAlignmentMode = .center
    }
}
