import Foundation
import SpriteKit

/// Handles drag events.
class DragNDropController {
    private weak var parent: SKNode!
    private var nodes: [SKNode] = []
    private var inFlight: Any? = nil
    private var hoveringNode: SKNode? = nil
    private var hoverNode: SKNode? = nil
    
    init(parent: SKNode) {
        self.parent = parent
    }
    
    func clearSources() {
        nodes.removeAll { $0 is DragSource }
    }
    
    func clearTargets() {
        nodes.removeAll { $0 is DropTarget }
    }
    
    func register<N>(source node: N) where N: SKNode, N: DragSource {
        nodes.append(node)
    }
    
    func register<N>(target node: N) where N: SKNode, N: DropTarget {
        nodes.append(node)
    }
    
    private func node(_ node: SKNode, contains point: CGPoint) -> Bool {
        guard let nodeParent = node.parent else { return false }
        return node.contains(parent.convert(point, to: nodeParent))
    }
    
    func handleInputDown(at point: CGPoint) -> Bool {
        for node in nodes {
            if self.node(node, contains: point), let source = node as? DragSource {
                print("Starting drag")
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
    
    func handleInputDragged(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        
        hoverNode?.position = point
        
        if let hovering = hoveringNode, !node(hovering, contains: point) {
            (hovering as? DropTarget)?.onUnHover(value: inFlight)
            hoveringNode = nil
        }
        
        for node in nodes {
            if hoveringNode !== node, self.node(node, contains: point), let target = node as? DropTarget {
                target.onHover(value: inFlight)
                hoveringNode = node
                return true
            }
        }
        
        return false
    }
    
    func handleInputUp(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        
        (hoveringNode as? DropTarget)?.onUnHover(value: inFlight)
        hoveringNode = nil
        
        hoverNode?.removeFromParent()
        hoverNode = nil
        
        for node in nodes {
            if self.node(node, contains: point), let target = node as? DropTarget {
                target.onDrop(value: inFlight)
                return true
            }
        }
        
        return false
    }
}
