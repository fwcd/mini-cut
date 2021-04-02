import Foundation
import SpriteKit

/// A layout container that presents 'keyed' child nodes.
final class Form: SKNode {
    convenience init(size: CGSize, childs: [(String, (CGFloat) -> SKNode)]) {
        self.init()
        
        let labelWidth = 0.3 * size.width
        let valueWidth = size.width - labelWidth
        
        addChild(Stack.vertical(childs.map { (label, factory) in
            Stack.horizontal([
                Label("\(label):", fontSize: ViewDefaults.textFieldFontSize, fontColor: ViewDefaults.formLabelFontColor),
                factory(valueWidth)
            ])
        }))
    }
}
