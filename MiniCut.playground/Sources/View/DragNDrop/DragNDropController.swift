import Foundation
import SpriteKit

/// Handles drag events.
struct DragNDropController {
    private var nodes: [SKNode] = []
    private var inFlight: Any? = nil
    private var hoveringNode: SKNode? = nil
    
    mutating func register<N>(source node: N) where N: SKNode, N: DragSource {
        nodes.append(node)
    }
    
    mutating func register<N>(target node: N) where N: SKNode, N: DropTarget {
        nodes.append(node)
    }
    
    mutating func handleInputDown(at point: CGPoint) -> Bool {
        for node in nodes {
            if let source = node as? DragSource {
                inFlight = source.draggableValue
                return true
            }
        }
        
        return false
    }
    
    mutating func handleInputDragged(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        
        for node in nodes {
            if hoveringNode !== node, node.contains(point), let target = node as? DropTarget {
                (hoveringNode as? DropTarget)?.onUnHover(value: inFlight)
                target.onHover(value: inFlight)
                hoveringNode = node
                return true
            }
        }
        
        return false
    }
    
    mutating func handleInputUp(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        (hoveringNode as? DropTarget)?.onUnHover(value: inFlight)
        hoveringNode = nil
        
        for node in nodes {
            if node.contains(point), let target = node as? DropTarget {
                target.onDrop(value: inFlight)
                return true
            }
        }
        
        return false
    }
}
