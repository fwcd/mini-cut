import SpriteKit

/// Represents something that can accept values through drag-n-drop.
protocol DropTarget {
    func onHover(value: Any, at position: CGPoint)
    
    func onUnHover(value: Any, at position: CGPoint)
    
    func onDrop(value: Any, at position: CGPoint)
}

extension DropTarget {
    func onHover(value: Any, at position: CGPoint) {}
    
    func onUnHover(value: Any, at position: CGPoint) {}
    
    func onDrop(value: Any, at position: CGPoint) {}
}
