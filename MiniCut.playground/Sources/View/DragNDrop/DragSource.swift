import SpriteKit

/// Represents something that can provide a value for drag-n-drop.
protocol DragSource {
    var draggableValue: Any { get }
    
    func makeHoverNode() -> SKNode
}
