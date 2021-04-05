import Foundation
import SpriteKit

private let log = Logger(name: "View.Controls.TextFieldSelectionController")

/// Manages text fields from which at any point of time only one may be selected.
final class TextFieldSelectionController {
    private weak var parent: SKNode!
    private var nodes: [UUID: TextField] = [:]
    var selection: UUID? = nil {
        willSet {
            if selection != newValue {
                if let previousId = selection {
                    log.debug("Deselected \(previousId)")
                    nodes[previousId]?.isSelected = false
                }
                if let id = newValue {
                    log.debug("Selected \(id)")
                    nodes[id]?.isSelected = true
                }
            }
        }
    }
    
    init(parent: SKNode) {
        self.parent = parent
    }
    
    /// Registers the given text field. Make sure to store a strong reference
    /// to the subscription as the text field will be removed internally once
    /// it is dropped.
    func register(textField: TextField) -> Subscription {
        let id = UUID()
        nodes[id] = textField
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
        if let node = selection.flatMap({ nodes[$0] }) {
            node.enter(keys: keys)
            return true
        }
        return false
    }
}
