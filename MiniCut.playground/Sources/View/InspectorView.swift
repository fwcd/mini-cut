import Foundation
import SpriteKit

/// A property inspector view.
final class InspectorView: SKSpriteNode {
    private var textFieldSubscriptions: [Subscription] = []
    
    convenience init(textFieldSelection: TextFieldSelectionController, size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
        
        let stack = Stack.vertical(anchored: true, [Label("Inspector", fontSize: ViewDefaults.headerFontSize, fontColor: ViewDefaults.secondary)])
        stack.position = CGPoint(x: 0, y: (size.height / 2) - ViewDefaults.padding - (stack.calculateAccumulatedFrame().height / 2))
        addChild(stack)
        
        // TODO
        let textField = TextField(text: "Test") {
            print("Entered '\($0)'")
        }
        stack.addChild(textField)
        textFieldSubscriptions.append(textFieldSelection.register(textField: textField))
    }
}
