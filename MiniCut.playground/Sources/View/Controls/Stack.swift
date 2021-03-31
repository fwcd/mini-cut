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
        let shiftDelta: CGFloat
        
        if let last = children.last {
            let lastFrame = last.calculateAccumulatedFrame()
            let nodeFrame = node.calculateAccumulatedFrame()
            
            switch direction! {
            case .horizontal:
                shiftDelta = (nodeFrame.width / 2) + padding
                node.position = CGPoint(x: last.position.x + (lastFrame.width / 2) + shiftDelta, y: last.position.y)
            case .vertical:
                shiftDelta = (nodeFrame.height / 2) + padding
                node.position = CGPoint(x: last.position.x, y: last.position.y - (lastFrame.height / 2) - shiftDelta)
            }
        } else {
            shiftDelta = 0
        }
        
        super.addChild(node)
        
        for child in children {
            switch direction! {
            case .horizontal:
                child.position = CGPoint(x: child.position.x - shiftDelta, y: child.position.y)
            case .vertical:
                child.position = CGPoint(x: child.position.x, y: child.position.y + shiftDelta)
            }
        }
    }
}
