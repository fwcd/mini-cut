import Foundation
import SpriteKit

private let trimHandleZPosition: CGFloat = 50

/// A visual representation of a track's controls.
final class TrackClipView: SKSpriteNode {
    private let state: MiniCutState
    private let trackId: UUID
    private let id: UUID
    
    private var clipSubscription: Subscription?
    private var timelineZoomSubscription: Subscription?
    private var timelineOffsetSubscription: Subscription?
    private var selectionSubscription: Subscription?
    
    private let parentWidth: CGFloat
    private var label: SKNode!
    private var labelThumb: SKNode!
    private var labelText: SKNode!
    private var leftHandle: TrimHandle!
    private var rightHandle: TrimHandle!
    
    private var toViewScale: AnyBijection<TimeInterval, CGFloat> {
        Scaling(factor: state.timelineZoom)
            .then(AnyBijection(CGFloat.init(_:), TimeInterval.init(_:)))
            .erase()
    }
    private var toViewX: AnyBijection<TimeInterval, CGFloat> {
        (toViewScale + (ViewDefaults.trackControlsWidth - (parentWidth / 2) - toViewScale.apply(state.timelineOffset))).erase()
    }
    
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
    
    init(
        state: MiniCutState,
        trackId: UUID,
        id: UUID,
        parentWidth: CGFloat,
        height: CGFloat,
        clipPadding: CGFloat = ViewDefaults.clipPadding,
        labelPadding: CGFloat = ViewDefaults.clipLabelPadding
    ) {
        self.state = state
        self.trackId = trackId
        self.id = id
        self.parentWidth = parentWidth
        
        super.init(texture: nil, color: .clear, size: CGSize(width: 0, height: 0))
        
        let handleSize = CGSize(width: ViewDefaults.trimHandleWidth, height: height)
        leftHandle = TrimHandle(side: .left, in: handleSize)
        rightHandle = TrimHandle(side: .right, in: handleSize)
        
        leftHandle.zPosition = trimHandleZPosition
        rightHandle.zPosition = trimHandleZPosition
        
        let updateClip = { [unowned self] in
            guard let clip = state.timeline[trackId]?[id] else { return }
            
            color = clip.clip.color
            size = CGSize(width: toViewScale.apply(clip.clip.length) - clipPadding, height: height - clipPadding)
            
            centerLeftPosition = CGPoint(x: toViewX.apply(clip.offset), y: 0)
            leftHandle.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
            rightHandle.centerRightPosition = CGPoint(x: (size.width / 2), y: 0)
            
            if label == nil {
                label = SKNode()
                addChild(label)
                
                let aspectRatio: CGFloat = 16 / 9
                let thumbSize = CGSize(width: aspectRatio * height, height: height)
                labelThumb = generateThumbnail(from: clip.clip, size: thumbSize)
                label.addChild(labelThumb)
                
                labelText = Label(clip.clip.name, fontSize: ViewDefaults.thumbnailLabelFontSize)
                labelText.position = CGPoint(
                    x: (thumbSize.width / 2) + labelPadding + (labelText.frame.width / 2),
                    y: (thumbSize.height / 2) - labelPadding - (labelText.frame.height / 2)
                )
                label.addChild(labelText)
            }
            
            label.centerLeftPosition = CGPoint(x: -(size.width / 2), y: 0)
            
            let thumbWidth = labelThumb.calculateAccumulatedFrame().width
            let textWidth = labelText.calculateAccumulatedFrame().width
            label.setVisibility(of: labelThumb, to: size.width >= thumbWidth)
            label.setVisibility(of: labelText, to: size.width >= textWidth + thumbWidth)
        }
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { _ in updateClip() }
        timelineZoomSubscription = state.timelineZoomDidChange.subscribeFiring(state.timelineZoom) { _ in updateClip() }
        timelineOffsetSubscription = state.timelineOffsetDidChange.subscribeFiring(state.timelineOffset) { _ in updateClip() }
        
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
    
    required init?(coder aDecoder: NSCoder) {
        nil
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
