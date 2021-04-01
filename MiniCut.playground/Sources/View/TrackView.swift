import Foundation
import SpriteKit

/// A visual representation of a single track.
final class TrackView: SKSpriteNode {
    // TODO: Use state & ids instead
    
    convenience init(track: Track, size: CGSize, marked: Bool) {
        self.init(color: marked ? ViewDefaults.quaternary : ViewDefaults.transparent, size: size)
        
        let controls = TrackControlsView(track: track, size: CGSize(width: ViewDefaults.trackControlsWidth, height: size.height))
        controls.topLeftPosition = CGPoint(x: -(size.width / 2), y: size.height / 2)
        addChild(controls)
    }
}
