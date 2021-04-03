import Foundation
import SpriteKit

/// A simple layout container that 'flows' nodes in a fixed box.
final class Flow: SKNode {
    private var padding: CGFloat!
    private var size: CGSize!
    
    init(padding: CGFloat = ViewDefaults.padding, size: CGSize, childs: [SKNode] = []) {
        super.init()
        self.padding = padding
        self.size = size
        
        for child in childs {
            addChild(child)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    override func addChild(_ node: SKNode) {
        let last = children.last?.calculateAccumulatedFrame()
        let width = node.calculateAccumulatedFrame().width
        let paddedWidth = padding + width
        let newX = (last?.maxX ?? 0) + paddedWidth
        
        if newX >= size.width {
            node.topLeftPosition = CGPoint(x: padding, y: (last?.minY ?? 0) - padding)
        } else {
            node.topLeftPosition = CGPoint(x: (last?.maxX ?? 0) + padding, y: last?.maxY ?? -padding)
        }
        
        super.addChild(node)
    }
}
