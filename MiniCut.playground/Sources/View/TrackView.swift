import Foundation
import SpriteKit

/// A visual representation of a single track.
final class TrackView: SKSpriteNode {
    convenience init(state: MiniCutState, id: UUID, size: CGSize, marked: Bool) {
        self.init(color: marked ? ViewDefaults.quaternary : ViewDefaults.transparent, size: size)
        
        let track = state.timeline.tracks.first { $0.id == id } ?? Track(id: id, name: "<undefined>")
        let controls = TrackControlsView(track: track, size: CGSize(width: ViewDefaults.trackControlsWidth, height: size.height))
        controls.topLeftPosition = CGPoint(x: -(size.width / 2), y: size.height / 2)
        addChild(controls)
        
        // TODO: Subscribe to changes
    }
}
