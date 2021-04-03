import Foundation
import SpriteKit

/// A simple layout container that aligns elements at leading, centered and trailing positions.
final class Bordered: SKNode {
    init(
        _ axis: Stack.Direction,
        length: CGFloat,
        padding: CGFloat = ViewDefaults.padding,
        leading: [SKNode] = [],
        centered: [SKNode] = [],
        trailing: [SKNode] = []
    ) {
        super.init()
        
        let leadingStack = Stack(axis, childs: leading)
        let centeredStack = Stack(axis, childs: centered)
        let trailingStack = Stack(axis, childs: trailing)
        
        switch axis {
        case .horizontal:
            leadingStack.centerLeftPosition = CGPoint(x: -(length / 2) + padding, y: 0)
            trailingStack.centerRightPosition = CGPoint(x: (length / 2) - padding, y: 0)
        case .vertical:
            leadingStack.topCenterPosition = CGPoint(x: 0, y: (length / 2) - padding)
            trailingStack.bottomCenterPosition = CGPoint(x: 0, y: -(length / 2) + padding)
        }
        
        centeredStack.centerPosition = CGPoint(x: 0, y: 0)
        
        addChild(leadingStack)
        addChild(centeredStack)
        addChild(trailingStack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
