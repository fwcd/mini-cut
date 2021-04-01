/// Represents something that can accept values through drag-n-drop.
protocol DropTarget {
    func onHover(value: Any)
    
    func onUnHover(value: Any)
    
    func onDrop(value: Any)
}

extension DropTarget {
    func onHover(value: Any) {}
    
    func onUnHover(value: Any) {}
    
    func onDrop(value: Any) {}
}
