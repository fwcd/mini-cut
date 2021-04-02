import Foundation
import SpriteKit

/// A visual representation of a track's controls.
final class TrackControlsView: SKSpriteNode {
    // TODO: Use state & ids instead
    
    init(track: Track, size: CGSize) {
        super.init(texture: nil, color: ViewDefaults.quaternary, size: size)
        
        let stack = Stack.horizontal([Label(track.name, fontSize: ViewDefaults.trackHeight / 2)])
        addChild(stack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
