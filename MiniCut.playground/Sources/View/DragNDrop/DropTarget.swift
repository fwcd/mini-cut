/// Represents something that can accept values through drag-n-drop.
protocol DropTarget {
    func onHover(value: Any)
    
    func onDrop(value: Any)
}
