import Foundation
import SpriteKit

/// A simple layout container that aligns elements at leading, centered and trailing positions.
final class Bordered: SKNode {
    init(
        _ axis: Stack.Direction,
        size: CGSize,
        leading: [SKNode] = [],
        centered: [SKNode] = [],
        trailing: [SKNode] = []
    ) {
        super.init()
        
        let leadingStack = Stack(axis, childs: leading)
        let centeredStack = Stack(axis, childs: centered)
        let trailingStack = Stack(axis, childs: trailing)
        
        leadingStack.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
        centeredStack.centerPosition = CGPoint(x: 0, y: 0)
        trailingStack.centerRightPosition = CGPoint(x: size.width / 2, y: 0)
        
        addChild(leadingStack)
        addChild(centeredStack)
        addChild(trailingStack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
