import Foundation
import SpriteKit

/// A property inspector view for a single clip.
final class InspectorClipView: SKNode {
    convenience init(
        state: MiniCutState,
        textFieldSelection: TextFieldSelectionController,
        trackId: UUID,
        clipId: UUID,
        size: CGSize
    ) {
        self.init()
        
        let stack = Stack.vertical(anchored: true, [Label("TODO", fontSize: ViewDefaults.headerFontSize, fontColor: ViewDefaults.secondary)])
        stack.position = CGPoint(x: 0, y: (size.height / 2) - ViewDefaults.padding - (stack.calculateAccumulatedFrame().height / 2))
        addChild(stack)
        
        
        
//        // TODO
//        let textField = TextField(size: CGSize(width: size.width, height: ViewDefaults.textFieldHeight), text: "Test") { _ in
//            // TODO
//        }
//        stack.addChild(textField)
//        textFieldSubscriptions.append(textFieldSelection.register(textField: textField))
    }
}
