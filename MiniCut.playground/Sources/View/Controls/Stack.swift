import Foundation
import SpriteKit

/// A simple UI element that lays out elements horizontally or vertically.
final class Stack: SKNode {
    private var direction: Direction!
    private var padding: CGFloat!
    private var useFixedPositions: Bool!
    private var anchored: Bool!
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    init(
        _ direction: Direction,
        padding: CGFloat = ViewDefaults.padding,
        useFixedPositions: Bool = false,
        anchored: Bool = false,
        childs: [SKNode]
    ) {
        super.init()
        
        self.direction = direction
        self.padding = padding
        self.useFixedPositions = useFixedPositions
        self.anchored = anchored
        
        for child in childs {
            addChild(child)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    static func horizontal(useFixedPositions: Bool = false, anchored: Bool = false, _ childs: [SKNode] = []) -> Stack {
        Stack(.horizontal, useFixedPositions: useFixedPositions, anchored: anchored, childs: childs)
    }
    
    static func vertical(useFixedPositions: Bool = false, anchored: Bool = false, _ childs: [SKNode] = []) -> Stack {
        Stack(.vertical, useFixedPositions: useFixedPositions, anchored: anchored, childs: childs)
    }
    
    override func addChild(_ node: SKNode) {
        let shiftDelta: CGFloat
        
        if let last = children.last {
            let lastFrame = last.calculateAccumulatedFrame()
            let nodeFrame = node.calculateAccumulatedFrame()
            
            switch direction! {
            case .horizontal:
                shiftDelta = (nodeFrame.width / 2) + padding
                if useFixedPositions {
                    node.position = CGPoint(x: lastFrame.maxX + shiftDelta, y: last.position.y)
                } else {
                    node.centerPosition = CGPoint(x: lastFrame.maxX + shiftDelta, y: last.centerPosition.y)
                }
            case .vertical:
                shiftDelta = (nodeFrame.height / 2) + padding
                if useFixedPositions {
                    node.position = CGPoint(x: last.position.x, y: lastFrame.minY - shiftDelta)
                } else {
                    node.centerPosition = CGPoint(x: last.centerPosition.x, y: lastFrame.minY - shiftDelta)
                }
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
