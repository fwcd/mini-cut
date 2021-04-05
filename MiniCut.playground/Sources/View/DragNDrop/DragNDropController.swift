import Foundation
import SpriteKit

/// Implement drag-n-drop over SpriteKit nodes.
final class DragNDropController {
    private weak var parent: SKNode!
    private var nodes: [UUID: SKNode] = [:]
    private var inFlight: Any? = nil
    private var hoveringNode: SKNode? = nil
    private var hoverNode: SKNode? = nil
    
    init(parent: SKNode) {
        self.parent = parent
    }
    
    /// Registers a node as a drag source. The drag source will
    /// be removed once the returned Subscription is dropped.
    func register<N>(source node: N) -> Subscription where N: SKNode & DragSource {
        register(node: node)
    }
    
    /// Registers a node as a drop target. The drop target will
    /// be removed once the returned Subscription is dropped.
    func register<N>(target node: N) -> Subscription where N: SKNode & DropTarget {
        register(node: node)
    }
    
    private func register(node: SKNode) -> Subscription {
        let id = UUID()
        nodes[id] = node
        return Subscription(id: id) { [weak self] in
            self?.nodes[id] = nil
        }
    }
    
    private func point(_ point: CGPoint, in node: SKNode) -> CGPoint {
        parent.convert(point, to: node)
    }
    
    private func node(_ node: SKNode, contains point: CGPoint) -> Bool {
        guard let nodeParent = node.parent else { return false }
        return node.contains(self.point(point, in: nodeParent))
    }
    
    @discardableResult
    func handleInputDown(at point: CGPoint) -> Bool {
        for node in nodes.values {
            if self.node(node, contains: point), let source = node as? DragSource {
                inFlight = source.draggableValue
                let hover = source.makeHoverNode()
                hover.zPosition = 100
                hover.position = point
                parent.addChild(hover)
                hoverNode = hover
                hoveringNode = node
                return true
            }
        }
        
        return false
    }
    
    @discardableResult
    func handleInputDragged(to point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        
        hoverNode?.position = point
        
        if let hovering = hoveringNode, !node(hovering, contains: point) {
            (hovering as? DropTarget)?.onUnHover(value: inFlight, at: self.point(point, in: hovering))
            hoveringNode = nil
        }
        
        for node in nodes.values {
            if hoveringNode !== node, self.node(node, contains: point), let target = node as? DropTarget {
                target.onHover(value: inFlight, at: self.point(point, in: node))
                hoveringNode = node
                return true
            }
        }
        
        return false
    }
    
    @discardableResult
    func handleInputUp(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        
        if let hovering = hoveringNode {
            (hoveringNode as? DropTarget)?.onUnHover(value: inFlight, at: self.point(point, in: hovering))
            hoveringNode = nil
        }
        
        hoverNode?.removeFromParent()
        hoverNode = nil
        
        self.inFlight = nil
        
        for node in nodes.values {
            if self.node(node, contains: point), let target = node as? DropTarget {
                target.onDrop(value: inFlight, at: self.point(point, in: node))
                return true
            }
        }
        
        return false
    }
}
