import Foundation
import SpriteKit

private let trimHandleZPosition: CGFloat = 50

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    private var trackId: UUID!
    private var id: UUID!
    
    private var state: MiniCutState!
    private var clipSubscription: Subscription!
    private var selectionSubscription: Subscription!
    
    private var thumb: SKNode!
    private var leftHandle: TrimHandle!
    private var rightHandle: TrimHandle!
    
    private var toViewScale: AnyBijection<TimeInterval, CGFloat>!
    private var dragState: DragState? = nil
    var isTrimming: Bool { dragState != nil }
    
    private var clip: OffsetClip? {
        get { state.timeline[trackId]?[id] }
        set { state.timeline[trackId]?[id] = newValue }
    }
    
    private struct DragState {
        let side: TrimHandle.Side
        let startPoint: CGPoint
        let startClip: OffsetClip
    }
    
    convenience init(
        state: MiniCutState,
        trackId: UUID,
        id: UUID,
        height: CGFloat,
        toViewScale: AnyBijection<TimeInterval, CGFloat>,
        toClipX: AnyBijection<TimeInterval, CGFloat>
    ) {
        self.init()
        self.trackId = trackId
        self.id = id
        self.state = state
        self.toViewScale = toViewScale
        
        let handleSize = CGSize(width: ViewDefaults.trimHandleWidth, height: height)
        leftHandle = TrimHandle(side: .left, in: handleSize)
        rightHandle = TrimHandle(side: .right, in: handleSize)
        
        leftHandle.zPosition = trimHandleZPosition
        rightHandle.zPosition = trimHandleZPosition
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] in
            guard let clip = $0[trackId]?[id] else { return }
            
            color = clip.clip.content.color
            size = CGSize(width: toViewScale.apply(clip.clip.length), height: height)
            
            centerLeftPosition = CGPoint(x: toClipX.apply(clip.offset), y: 0)
            leftHandle.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
            rightHandle.centerRightPosition = CGPoint(x: (size.width / 2), y: 0)
            
            if thumb == nil {
                let aspectRatio: CGFloat = 16 / 9
                let thumbSize = CGSize(width: aspectRatio * height, height: height)
                thumb = generateThumbnail(from: clip.clip, size: thumbSize)
                addChild(thumb)
            }
            thumb.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
        }
        
        selectionSubscription = state.selectionDidChange.subscribeFiring(state.selection) { [unowned self] in
            if let selection = $0, selection.trackId == trackId && selection.clipId == id {
                if leftHandle.parent == nil {
                    addChild(leftHandle)
                }
                if rightHandle.parent == nil {
                    addChild(rightHandle)
                }
            } else {
                if leftHandle.parent != nil {
                    leftHandle.removeFromParent()
                }
                if rightHandle.parent != nil {
                    rightHandle.removeFromParent()
                }
                dragState = nil
            }
        }
    }
    
    func tryBeginTrimming(at parentPoint: CGPoint) {
        guard let clip = clip, let parent = parent else { return }
        let point = parent.convert(parentPoint, to: self)
        
        if leftHandle.calculateAccumulatedFrame().contains(point) {
            dragState = DragState(side: .left, startPoint: parentPoint, startClip: clip)
        } else if rightHandle.calculateAccumulatedFrame().contains(point) {
            dragState = DragState(side: .right, startPoint: parentPoint, startClip: clip)
        }
    }
    
    func moveTrimmer(to parentPoint: CGPoint) {
        guard let dragState = dragState, var newClip = clip else { return }
        
        let dx = parentPoint.x - dragState.startPoint.x
        let delta = toViewScale.inverseApply(dx)
        
        switch dragState.side {
        case .left:
            newClip.offset = dragState.startClip.offset + delta
            newClip.clip.start = dragState.startClip.clip.start + delta
            newClip.clip.length = dragState.startClip.clip.length - delta
        case .right:
            newClip.clip.length = dragState.startClip.clip.length + delta
        }
        
        clip = newClip
    }
    
    func finishTrimming() {
        dragState = nil
    }
}
