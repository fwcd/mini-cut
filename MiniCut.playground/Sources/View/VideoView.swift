import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

/// A view of the composited video.
final class VideoView: SKSpriteNode, SKInputHandler {
    private var state: MiniCutState!
    private var isPlayingSubscription: Subscription!
    private var timelineSubscription: Subscription!
    private var cursorSubscription: Subscription!
    private var updateStartSubscription: Subscription!
    
    private var crop: SKCropNode!
    private var videoClipNodes: [UUID: VideoClipView] = [:]
    
    private var startDate: Date?
    private var startCursor: TimeInterval?
    
    init(state: MiniCutState, size: CGSize) {
        super.init(texture: nil, color: .black, size: size)
        self.state = state
        
        isUserInteractionEnabled = true
        
        crop = SKCropNode()
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        addChild(crop)
        
        updateStartSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { [unowned self] in
            startDate = Date()
            startCursor = $0
        }
        cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { [unowned self] in
            let playing = state.timeline.playingClips(at: $0)
            crop.diffUpdate(nodes: &videoClipNodes, with: playing) {
                VideoClipView(state: state, trackId: $0.trackId, id: $0.clip.id, size: size, zIndex: $0.zIndex)
            }
        }
        timelineSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            let playing = $0.playingClips(at: state.cursor)
            crop.diffUpdate(nodes: &videoClipNodes, with: playing) {
                VideoClipView(state: state, trackId: $0.trackId, id: $0.clip.id, size: size, zIndex: $0.zIndex)
            }
        }
        isPlayingSubscription = state.isPlayingDidChange.subscribeFiring(state.isPlaying) { [unowned self] in
            if $0 {
                startDate = Date()
                startCursor = state.cursor
                
                run(.repeatForever(.sequence([
                    .run {
                        let videoCursorSubscriptions = videoClipNodes.values.compactMap(\.cursorSubscription)
                        state.cursorDidChange.silencing([updateStartSubscription] + videoCursorSubscriptions) {
                            state.cursor = startCursor! - startDate!.timeIntervalSinceNow
                        }
                    },
                    .wait(forDuration: cursorStride)
                ])), withKey: cursorActionKey)
            } else {
                removeAction(forKey: cursorActionKey)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    func inputDown(at point: CGPoint) {
        if let node = videoClipNodes.values.filter({ $0.contains(point) }).max(by: { $0.zPosition < $1.zPosition }) {
            state.selection = Selection(trackId: node.trackId, clipId: node.id)
        } else {
            state.selection = nil
        }
    }
    
    func inputDragged(to point: CGPoint) {
        // TODO
    }
    
    func inputUp(at point: CGPoint) {
        // TODO
    }
}
