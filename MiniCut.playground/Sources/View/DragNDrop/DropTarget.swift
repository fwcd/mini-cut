import SpriteKit

/// Represents something that can accept values through drag-n-drop.
protocol DropTarget {
    /// Invoked when dragged item hovers over the current node. Position is in the current node's coordinate system.
    func onHover(value: Any, at position: CGPoint)
    
    /// Invoked when dragged item leaves the current node. Position is in the current node's coordinate system.
    func onUnHover(value: Any, at position: CGPoint)
    
    /// Invoked when dragged item hovers is dropped on the current node. Position is in the current node's coordinate system.
    func onDrop(value: Any, at position: CGPoint)
}

extension DropTarget {
    func onHover(value: Any, at position: CGPoint) {}
    
    func onUnHover(value: Any, at position: CGPoint) {}
    
    func onDrop(value: Any, at position: CGPoint) {}
}
