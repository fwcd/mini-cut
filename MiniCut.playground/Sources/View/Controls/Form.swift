import Foundation
import SpriteKit

/// A layout container that presents 'keyed' child nodes.
final class Form: SKNode {
    init(size: CGSize, padding: CGFloat = ViewDefaults.padding, childs: [(String, (CGFloat) -> SKNode)]) {
        super.init()
        
        let labelWidth = 0.25 * size.width
        let valueWidth = size.width - labelWidth - (padding * 2)
        
        var y: CGFloat = 0
        
        for (label, factory) in childs {
            let label = Label("\(label):", fontSize: ViewDefaults.textFieldFontSize, fontColor: ViewDefaults.formLabelFontColor)
            label.topRightPosition = CGPoint(x: labelWidth, y: y)
            addChild(label)
            
            let value = factory(valueWidth)
            value.topLeftPosition = CGPoint(x: labelWidth + padding, y: y)
            addChild(value)
            
            y -= max(label.calculateAccumulatedFrame().height, value.calculateAccumulatedFrame().height) + padding
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
