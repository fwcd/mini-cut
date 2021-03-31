import Foundation
import SpriteKit

/// A simple UI element that lays out elements horizontally or vertically.
public class Stack: SKSpriteNode {
    private var direction: Direction!
    private var padding: CGFloat!
    
    public enum Direction {
        case horizontal
        case vertical
    }
    
    public convenience init(
        _ direction: Direction,
        padding: CGFloat = ViewDefaults.padding,
        childs: [SKNode]
    ) {
        self.init()
        
        self.direction = direction
        self.padding = padding
        
        for child in childs {
            addChild(child)
        }
    }
    
    public static func horizontal(_ childs: [SKNode] = []) -> Stack {
        Stack(.horizontal, childs: childs)
    }
    
    public static func vertical(_ childs: [SKNode] = []) -> Stack {
        Stack(.vertical, childs: childs)
    }
    
    public override func addChild(_ node: SKNode) {
        if let last = children.last {
            let frame = last.calculateAccumulatedFrame()
            let nodeFrame = node.calculateAccumulatedFrame()
            switch direction! {
            case .horizontal:
                node.position = CGPoint(x: last.position.x + (frame.width / 2) + (nodeFrame.width / 2) + padding, y: last.position.y)
            case .vertical:
                node.position = CGPoint(x: last.position.x, y: last.position.y - (frame.height / 2) - (nodeFrame.height / 2) - padding)
            }
        }
        super.addChild(node)
    }
}
