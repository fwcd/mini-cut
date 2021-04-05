import Foundation
import SpriteKit

private let log = Logger(name: "View.Controls.GenericSelectionController")

/// Manages nodes from which at any point of time only one may be selected.
final class GenericSelectionController {
    private weak var parent: SKNode!
    private var nodes: [UUID: SKNode] = [:]
    var selection: UUID? = nil {
        willSet {
            if selection != newValue {
                if let previousId = selection, let selectable = nodes[previousId] as? Selectable {
                    log.debug("Deselected \(previousId)")
                    selectable.isSelected = false
                }
                if let id = newValue, let selectable = nodes[id] as? Selectable {
                    log.debug("Selected \(id)")
                    selectable.isSelected = true
                }
            }
        }
    }
    
    init(parent: SKNode) {
        self.parent = parent
    }
    
    func register<N>(node: N) -> Subscription where N: SKNode & Selectable {
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
        for (id, node) in nodes {
            if self.node(node, contains: point) {
                selection = id
                return true
            }
        }
        
        selection = nil
        return false
    }
    
    @discardableResult
    func handleInputKeyDown(with keys: [KeyboardKey]) -> Bool {
        if let node = selection.flatMap({ nodes[$0] }), let handler = node as? SKInputHandler {
            handler.inputKeyDown(with: keys)
            return true
        }
        return false
    }
}
