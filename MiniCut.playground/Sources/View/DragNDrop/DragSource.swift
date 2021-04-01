/// Represents something that can provide a value for drag-n-drop.
protocol DragSource {
    associatedtype Value
    
    var draggableValue: Value { get }
}
