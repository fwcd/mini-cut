import Foundation
import SpriteKit

/// A view of the user's clip library.
final class LibraryView: SKSpriteNode {
    convenience init(size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
    }
}
