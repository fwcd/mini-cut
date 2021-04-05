import Foundation
import SpriteKit

/// Handles interactions from controls like buttons or sliders.
final class GenericDragController {
    private weak var parent: SKNode!
    private var nodes: [UUID: SKNode] = [:]
    private var active: SKNode? = nil
    
    init(parent: SKNode) {
        self.parent = parent
    }
    
    func register<N>(node: N) -> Subscription where N: SKNode & SKInputHandler {
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
            if self.node(node, contains: point), let handler = node as? SKInputHandler {
                handler.inputDown(at: self.point(point, in: node))
                active = node
                return true
            }
        }
        return false
    }
    
    @discardableResult
    func handleInputDragged(to point: CGPoint) -> Bool {
        if let handler = active as? SKInputHandler {
            handler.inputDragged(to: self.point(point, in: active!))
            return true
        }
        return false
    }
    
    @discardableResult
    func handleInputUp(at point: CGPoint) -> Bool {
        if let handler = active as? SKInputHandler {
            handler.inputUp(at: self.point(point, in: active!))
            active = nil
            return true
        }
        return false
    }
}
