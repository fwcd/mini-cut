import Foundation
import SpriteKit

/// A visual representation of a single track.
final class TrackView: SKSpriteNode {
    convenience init(track: Track, size: CGSize, marked: Bool) {
        self.init(color: marked ? ViewDefaults.quaternary : ViewDefaults.transparent, size: size)
    }
}
