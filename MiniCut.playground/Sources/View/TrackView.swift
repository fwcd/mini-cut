import Foundation
import SpriteKit

private let trackControlsZPosition: CGFloat = 75

/// A visual representation of a single track.
final class TrackView: SKSpriteNode {
    private var state: MiniCutState!
    private var clipsSubscription: Subscription!
    
    private(set) var clipNodes: [UUID: TrackClipView] = [:]
    
    init(
        state: MiniCutState,
        id: UUID,
        size: CGSize,
        marked: Bool
    ) {
        super.init(texture: nil, color: marked ? ViewDefaults.quaternary : ViewDefaults.transparent, size: size)
        self.state = state
        
        let track = state.timeline[id] ?? Track(id: id, name: "<undefined>")
        let trackControlsWidth = ViewDefaults.trackControlsWidth
        let controls = TrackControlsView(track: track, size: CGSize(width: trackControlsWidth, height: size.height))
        controls.topLeftPosition = CGPoint(x: -(size.width / 2), y: size.height / 2)
        controls.zPosition = trackControlsZPosition
        let clips = SKNode()
        
        addChild(clips)
        addChild(controls)
        
        clipsSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            guard let track = $0[id] else { return }
            clips.diffUpdate(nodes: &clipNodes, with: track.clips) {
                TrackClipView(state: state, trackId: id, id: $0.id, parentWidth: size.width, height: size.height)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
