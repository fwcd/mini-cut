import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

/// A view of the composited video.
final class VideoView: SKSpriteNode {
    private var state: MiniCutState!
    private var isPlayingSubscription: Subscription!
    private var cursorSubscription: Subscription!
    private var updateStartSubscription: Subscription!
    
    private var crop: SKCropNode!
    private var videoClipNodes: [UUID: VideoClipView] = [:]
    
    private var startDate: Date?
    private var startCursor: TimeInterval?
    
    convenience init(state: MiniCutState, size: CGSize) {
        self.init(color: .black, size: size)
        self.state = state
        
        crop = SKCropNode()
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        addChild(crop)
        
        updateStartSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            startDate = Date()
            startCursor = $0
        }
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            let playing = Array(state.timeline.playingClips(at: $0).reversed())
            crop.diffUpdate(nodes: &videoClipNodes, with: playing) {
                VideoClipView(state: state, trackId: $0.trackId, id: $0.clip.id, size: size)
            }
        }
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) { [unowned self] in
            if $0 {
                startDate = Date()
                startCursor = state.cursor
                
                run(.repeatForever(.sequence([
                    .run {
                        let videoCursorSubscriptions = videoClipNodes.values.compactMap(\.cursorSubscription)
                        state.cursorWillChange.silencing([updateStartSubscription] + videoCursorSubscriptions) {
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
}
