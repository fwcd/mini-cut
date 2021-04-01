import Foundation
import SpriteKit

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    convenience init(state: MiniCutState, trackId: UUID, id: UUID, height: CGFloat, toViewScale: AnyBijection<TimeInterval, CGFloat>) {
        // TODO: Subscribe to listeners
        guard let clip = state.timeline[trackId]?[id] else {
            fatalError("Could not find track with id \(trackId)")
        }
        
        self.init(color: ViewDefaults.quaternary, size: CGSize(width: toViewScale.apply(clip.clip.length), height: height))
    }
}
