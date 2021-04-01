import Foundation
import SpriteKit

/// A visual representation of a track's controls.
final class TrackControlsView: SKSpriteNode {
    // TODO: Use state & ids instead
    
    convenience init(track: Track, size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
        
        let stack = Stack.horizontal([Label(track.name, fontSize: ViewDefaults.trackHeight / 2)])
        addChild(stack)
    }
}
