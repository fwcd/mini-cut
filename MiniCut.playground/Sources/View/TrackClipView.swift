import Foundation
import SpriteKit

private let trimHandleZPosition: CGFloat = 50

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode, SKInputHandler {
    private var trackId: UUID!
    private var id: UUID!
    
    private var state: MiniCutState!
    private var clipSubscription: Subscription!
    private var selectionSubscription: Subscription!
    
    private var thumb: SKNode!
    private var leftHandle: TrimHandle!
    private var rightHandle: TrimHandle!
    
    private var toViewScale: AnyBijection<TimeInterval, CGFloat>!
    private var lastDragPoint: CGPoint? = nil
    private var draggedHandle: DraggedHandle? = nil
    var isTrimming: Bool { draggedHandle != nil }
    
    private var clip: OffsetClip? {
        get { state.timeline[trackId]?[id] }
        set { state.timeline[trackId]?[id] = newValue }
    }
    
    private enum DraggedHandle {
        case left
        case right
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
        leftHandle = TrimHandle(in: handleSize)
        rightHandle = TrimHandle(in: handleSize)
        
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
                lastDragPoint = nil
                draggedHandle = nil
            }
        }
    }
    
    func inputDown(at point: CGPoint) {
        if leftHandle.calculateAccumulatedFrame().contains(point) {
            draggedHandle = .left
            lastDragPoint = point
        } else if rightHandle.calculateAccumulatedFrame().contains(point) {
            draggedHandle = .right
            lastDragPoint = point
        }
    }
    
    func inputDragged(to point: CGPoint) {
        guard let last = lastDragPoint else { return }
        let dx = point.x - last.x
        let delta = toViewScale.inverseApply(dx)
        
        switch draggedHandle! {
        case .left:
            if delta > 0 {
                print("Delta: \(delta)")
                clip?.offset += delta
                clip?.clip.start += delta
                clip?.clip.length -= delta
                lastDragPoint = point
            }
        case .right:
            if delta < 0 {
                clip?.clip.length += delta
                lastDragPoint = point
            }
        }
    }
    
    func inputUp(at point: CGPoint) {
        lastDragPoint = nil
        draggedHandle = nil
    }
}
