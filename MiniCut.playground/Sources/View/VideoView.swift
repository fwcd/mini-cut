import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

/// A view of the composited video.
final class VideoView: SKSpriteNode, SKInputHandler {
    private let state: MiniCutState
    
    private var isPlayingSubscription: Subscription?
    private var timelineSubscription: Subscription?
    private var cursorSubscription: Subscription?
    private var updateStartSubscription: Subscription?
    
    private var crop: SKCropNode!
    private var videoClipNodes: [UUID: VideoClipView] = [:]
    
    private var startDate: Date?
    private var startCursor: TimeInterval?
    
    private var dragState: DragState = .inactive
    
    private enum DragState {
        case resizing(VideoClipView)
        case clip(ClipDragState)
        case inactive
    }
    
    private struct ClipDragState {
        let trackId: UUID
        let clipId: UUID
        let startPoint: CGPoint
        let startOffsetDx: Double
        let startOffsetDy: Double
    }
    
    init(state: MiniCutState, size: CGSize) {
        self.state = state
        
        super.init(texture: nil, color: .black, size: size)
        
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
                        state.cursorDidChange.silencing([updateStartSubscription].compactMap { $0 } + videoCursorSubscriptions) {
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
        if let node = videoClipNodes.values.filter({ $0.contains(point) }).max(by: { $0.zPosition < $1.zPosition }), let nodeParent = node.parent {
            state.selection = Selection(trackId: node.trackId, clipId: node.id)
            node.tryBeginResizing(at: convert(point, to: nodeParent))
            if node.isResizing {
                dragState = .resizing(node)
            } else if let clip = state.timeline[node.trackId]?[node.id] {
                dragState = .clip(ClipDragState(
                    trackId: node.trackId,
                    clipId: node.id,
                    startPoint: point,
                    startOffsetDx: clip.clip.visualOffsetDx,
                    startOffsetDy: clip.clip.visualOffsetDy
                ))
            } else {
                dragState = .inactive
            }
        } else {
            dragState = .inactive
            state.selection = nil
        }
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState {
        case .resizing(let node):
            if let nodeParent = node.parent {
                node.moveResizer(to: convert(point, to: nodeParent))
            }
        case .clip(let clipState):
            if var clip = state.timeline[clipState.trackId]?[clipState.clipId] {
                clip.clip.visualOffsetDx = Double((point.x - clipState.startPoint.x) / size.width) + clipState.startOffsetDx
                clip.clip.visualOffsetDy = Double((point.y - clipState.startPoint.y) / size.height) + clipState.startOffsetDy
                state.timeline[clipState.trackId]?[clipState.clipId] = clip
            }
        default:
            break
        }
    }
    
    func inputUp(at point: CGPoint) {
        switch dragState {
        case .resizing(let node):
            node.finishResizing()
        default:
            break
        }
        dragState = .inactive
    }
}
