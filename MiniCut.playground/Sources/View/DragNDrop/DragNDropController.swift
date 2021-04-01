import Foundation
import SpriteKit

/// Handles drag events.
struct DragNDropController {
    private var nodes: [SKNode] = []
    private var inFlight: Any? = nil
    
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
    
    func handleInputDragged(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        for node in nodes {
            if let target = node as? DropTarget {
                target.onHover(value: inFlight)
            }
        }
        return false
    }
    
    mutating func handleInputUp(at point: CGPoint) -> Bool {
        guard let inFlight = inFlight else { return false }
        for node in nodes {
            if let target = node as? DropTarget {
                target.onDrop(value: inFlight)
            }
        }
        return false
    }
}
