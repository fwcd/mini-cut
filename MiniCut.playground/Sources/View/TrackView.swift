import Foundation
import SpriteKit

/// A visual representation of a single track.
final class TrackView: SKSpriteNode {
    private var clipsSubscription: Subscription!
    
    private(set) var clipNodes: [UUID: SKNode] = [:]
    
    convenience init(
        state: MiniCutState,
        id: UUID,
        size: CGSize,
        marked: Bool,
        toViewScale: AnyBijection<TimeInterval, CGFloat>
    ) {
        self.init(color: marked ? ViewDefaults.quaternary : ViewDefaults.transparent, size: size)
        
        let track = state.timeline[id] ?? Track(id: id, name: "<undefined>")
        let trackControlsWidth = ViewDefaults.trackControlsWidth
        let controls = TrackControlsView(track: track, size: CGSize(width: trackControlsWidth, height: size.height))
        controls.topLeftPosition = CGPoint(x: -(size.width / 2), y: size.height / 2)
        addChild(controls)
        
        let clips = SKNode()
        addChild(clips)
        
        let toClipX = (toViewScale + (trackControlsWidth - (size.width / 2))).erase()
        
        clipsSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            guard let track = $0[id] else { return }
            clips.diffUpdate(nodes: &clipNodes, with: track.clips) {
                TrackClipView(state: state, trackId: id, id: $0.id, height: size.height, toViewScale: toViewScale, toClipX: toClipX)
            }
        }
    }
}
