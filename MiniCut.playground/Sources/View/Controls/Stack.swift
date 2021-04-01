import Foundation
import SpriteKit

/// A simple UI element that lays out elements horizontally or vertically.
public class Stack: SKSpriteNode {
    private var direction: Direction!
    private var padding: CGFloat!
    private var anchored: Bool!
    
    public enum Direction {
        case horizontal
        case vertical
    }
    
    public convenience init(
        _ direction: Direction,
        padding: CGFloat = ViewDefaults.padding,
        anchored: Bool = false,
        childs: [SKNode]
    ) {
        self.init()
        
        self.direction = direction
        self.padding = padding
        self.anchored = anchored
        
        for child in childs {
            addChild(child)
        }
    }
    
    public static func horizontal(anchored: Bool = false, _ childs: [SKNode] = []) -> Stack {
        Stack(.horizontal, anchored: anchored, childs: childs)
    }
    
    public static func vertical(anchored: Bool = false, _ childs: [SKNode] = []) -> Stack {
        Stack(.vertical, anchored: anchored, childs: childs)
    }
    
    public override func addChild(_ node: SKNode) {
        let shiftDelta: CGFloat
        
        if let last = children.last {
            let lastFrame = last.calculateAccumulatedFrame()
            let nodeFrame = node.calculateAccumulatedFrame()
            
            switch direction! {
            case .horizontal:
                shiftDelta = (nodeFrame.width / 2) + padding
                node.position = CGPoint(x: lastFrame.maxX + shiftDelta, y: last.position.y)
            case .vertical:
                shiftDelta = (nodeFrame.height / 2) + padding
                node.position = CGPoint(x: last.position.x, y: lastFrame.minY - shiftDelta)
            }
        } else {
            shiftDelta = 0
        }
        
        super.addChild(node)
        
        if !anchored {
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
}
