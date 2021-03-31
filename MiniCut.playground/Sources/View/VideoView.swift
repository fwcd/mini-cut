import Foundation
import SpriteKit

/// A view of the composited video.
final class VideoView: SKSpriteNode {
    convenience init(size: CGSize) {
        self.init(color: .gray, size: size)
    }
}
