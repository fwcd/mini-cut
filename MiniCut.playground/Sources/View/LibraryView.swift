import Foundation
import SpriteKit

/// A view of the user's clip library.
final class LibraryView: SKSpriteNode {
    convenience init(size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
        
        let stack = Stack.vertical(anchored: true, [Label("Library", fontSize: ViewDefaults.headerFontSize, fontColor: ViewDefaults.secondary)])
        stack.position = CGPoint(x: 0, y: (size.height / 2) - ViewDefaults.padding - (stack.calculateAccumulatedFrame().height / 2))
        addChild(stack)
        
        stack.addChild(Flow(size: size, childs: [
            Label("This"),
            Label("is"),
            Label("a flow node"),
            Label("123"),
            Label("456")
        ]))
    }
}
