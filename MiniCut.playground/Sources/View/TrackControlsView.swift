import Foundation
import SpriteKit

private let trackControlsZPosition: CGFloat = 80

/// A visual representation of a track's controls.
final class TrackControlsView: SKSpriteNode {
    init(track: Track, size: CGSize) {
        super.init(texture: nil, color: ViewDefaults.translucentBackground, size: size)
        
        let stack = Stack.horizontal([Label(track.name, fontSize: ViewDefaults.trackHeight / 2)])
        addChild(stack)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
