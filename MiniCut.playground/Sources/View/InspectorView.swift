import Foundation
import SpriteKit

/// A property inspector view.
final class InspectorView: SKSpriteNode {
    convenience init(size: CGSize) {
        self.init(color: .yellow, size: size)
    }
}
