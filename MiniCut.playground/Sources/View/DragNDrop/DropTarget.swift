/// Represents something that can accept values through drag-n-drop.
protocol DropTarget {
    associatedtype Value
    
    func onHover(value: Value)
    
    func onDrop(value: Value)
}
