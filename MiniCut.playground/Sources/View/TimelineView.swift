import Foundation
import SpriteKit

private let cursorZPosition: CGFloat = 100

/// A visual representation of a project's timeline.
final class TimelineView: SKNode, SKInputHandler, DropTarget {
    private let state: MiniCutState
    private let textFieldSelection: GenericSelectionController
    
    private var cursorSubscription: Subscription!
    private var tracksSubscription: Subscription!
    private var timelineZoomSubscription: Subscription!
    private var timelineOffsetSubscription: Subscription!
    
    /// How responsive the timeline is to scroll events.
    private var scrollSpeed: Double = 4
    
    /// How wide the hitbox of the timeline cursor is (i.e. in which radius of the cursor the user may 'grab' it).
    private var cursorHitboxWidth: CGFloat = 25
    
    /// How frequently (actually rarely) a time mark shall be rendered. In seconds.
    var markStride: Int {
        didSet { updateMarks() }
    }
    
    private var toViewScale: AnyBijection<TimeInterval, CGFloat> {
        Scaling(factor: state.timelineZoom)
            .then(AnyBijection(CGFloat.init(_:), TimeInterval.init(_:)))
            .erase()
    }
    private var toViewX: AnyBijection<TimeInterval, CGFloat> {
        toViewScale
            .then(Translation(offset: -(size.width / 2) + ViewDefaults.trackControlsWidth - toViewScale.apply(state.timelineOffset)))
            .erase()
    }
    
    private let size: CGSize
    private var background: SKSpriteNode!
    private var marks: SKNode!
    private var gettingStartedHint: SKNode?
    private var cursor: TimelineCursor!
    private var tracks: SKNode!
    private var trackNodes: [UUID: TrackView] = [:] {
        didSet {
            if trackNodes.isEmpty {
                if let hint = gettingStartedHint {
                    addChild(hint)
                }
            } else {
                gettingStartedHint?.removeFromParent()
            }
        }
    }
    
    private var dragState: DragState? = nil
    
    private enum DragState {
        case scrolling(ScrollDragState)
        case cursor
        case clip(ClipDragState)
        case trimming(TrackClipView)
        case inactive
    }
    
    private struct ScrollDragState {
        let startX: CGFloat
        let startOffset: TimeInterval
        var moved: Bool = false
    }
    
    private struct ClipDragState {
        var trackId: UUID
        var clipId: UUID
        let dxInClip: CGFloat
    }
    
    init(
        state: MiniCutState,
        textFieldSelection: GenericSelectionController,
        size: CGSize,
        zoomLevel: Double = 10.0,
        markStride: Int = 10
    ) {
        self.state = state
        self.textFieldSelection = textFieldSelection
        self.size = size
        self.markStride = markStride
        
        super.init()
        
        dragState = .inactive
        
        background = SKSpriteNode(color: ViewDefaults.transparent, size: size)
        addChild(background)
        
        marks = SKNode()
        addChild(marks)
        updateMarks()
        
        tracks = Stack(.vertical, padding: ViewDefaults.trackSpacing, useFixedPositions: true, anchored: true, childs: [])
        tracks.position = CGPoint(x: 0, y: (size.height - ViewDefaults.trackHeight) / 2)
        addChild(tracks)
        
        let trackSize = CGSize(width: size.width, height: ViewDefaults.trackHeight)
        
        tracksSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] tl in
            tracks.diffUpdate(nodes: &trackNodes, with: tl.tracks) {
                TrackView(state: state, id: $0.id, size: trackSize, marked: tl.tracks.count % 2 == 0)
            }
        }
        
        cursor = TimelineCursor(height: size.height)
        cursor.zPosition = cursorZPosition
        addChild(cursor)
        
        timelineZoomSubscription = state.timelineZoomDidChange.subscribeFiring(state.timelineZoom) { [unowned self] _ in updatePositionRelated() }
        timelineOffsetSubscription = state.timelineOffsetDidChange.subscribeFiring(state.timelineOffset) { [unowned self] _ in updatePositionRelated() }
        cursorSubscription = state.cursorDidChange.subscribeFiring(state.cursor) { [unowned self] _ in updatePositionRelated() }
        
        gettingStartedHint = Label("Create a track with '+' and drag a clip from the library to get started!", fontSize: ViewDefaults.hintFontSize, fontColor: ViewDefaults.hintFontColor)
        addChild(gettingStartedHint!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    func inputDown(at point: CGPoint) {
        textFieldSelection.selection = nil
        
        for (trackId, track) in trackNodes {
            for (clipId, clip) in track.clipNodes {
                if let selection = state.selection,
                   selection.trackId == trackId && selection.clipId == clipId,
                   let clipParent = clip.parent {
                    clip.tryBeginTrimming(at: convert(point, to: clipParent))
                }
                if clip.isTrimming {
                    dragState = .trimming(clip)
                    return
                } else if let pointInClipParent = clip.parent.map({ convert(point, to: $0) }), clip.contains(pointInClipParent) {
                    let corner = clip.topLeftPosition
                    let dx = pointInClipParent.x - corner.x
                    dragState = .clip(ClipDragState(trackId: trackId, clipId: clipId, dxInClip: dx))
                    state.selection = Selection(trackId: trackId, clipId: clipId)
                    return
                }
            }
        }
        
        state.selection = nil
        
        if abs(cursor.position.x - point.x) <= cursorHitboxWidth {
            dragState = .cursor
            return
        }
        
        dragState = .scrolling(ScrollDragState(startX: point.x, startOffset: state.timelineOffset))
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState! {
        case .scrolling(var scrollState):
            let newOffset = scrollState.startOffset - toViewScale.inverseApply(point.x - scrollState.startX)
            state.timelineOffset = newOffset
            scrollState.moved = true
            dragState = .scrolling(scrollState)
        case .cursor:
            state.cursor = TimeInterval(toViewX.inverseApply(point.x))
        case .clip(var clipState):
            for (trackId, track) in trackNodes where trackId != clipState.trackId {
                if let pointInTrackParent = track.parent.map({ convert(point, to: $0) }), track.contains(pointInTrackParent) {
                    if var clip = state.timeline[clipState.trackId]?.remove(clipId: clipState.clipId) {
                        // We create a new clip id when switching tracks to
                        // ensure that a new VideoClipView is spawned.
                        clip.id = UUID()
                        clipState.clipId = clip.id
                        state.timeline[trackId]?.insert(clip: clip)
                        
                        // ...and we have to update the selection with the new ids too
                        state.selection?.clipId = clip.id
                        state.selection?.trackId = trackId
                    }
                    clipState.trackId = trackId
                    dragState = .clip(clipState)
                    break
                }
            }
            
            state.timeline[clipState.trackId]?[clipState.clipId]?.offset = toViewX.inverseApply(point.x - clipState.dxInClip)
        case .trimming(let clip):
            if let clipParent = clip.parent {
                clip.moveTrimmer(to: convert(point, to: clipParent))
            }
        default:
            break
        }
    }
    
    func inputUp(at point: CGPoint) {
        switch dragState {
        case .scrolling(let scrollState):
            // If user just taps the timeline, move the cursor there
            if !scrollState.moved {
                dragState = .cursor
                inputDragged(to: point)
            }
        case .trimming(let clip):
            clip.finishTrimming()
        default:
            inputDragged(to: point)
        }
        dragState = .inactive
    }
    
    func inputScrolled(deltaX: CGFloat, deltaY: CGFloat, deltaZ: CGFloat) {
        state.timelineOffset -= scrollSpeed * toViewScale.inverseApply(deltaX)
    }
    
    func onHover(value: Any, at position: CGPoint) {
        background.color = ViewDefaults.activeBgColor
    }
    
    func onUnHover(value: Any, at position: CGPoint) {
        background.color = ViewDefaults.transparent
    }
    
    func onDrop(value: Any, at position: CGPoint) {
        guard let clip = value as? Clip else { return }
        
        let pos = convert(position, to: tracks)
        if let id = trackNodes.first(where: { $0.value.contains(pos) })?.key {
            state.timeline[id]?.insert(clip: OffsetClip(clip: clip, offset: toViewX.inverseApply(position.x)))
        } else {
            // TODO: Warn when no tracks exist
        }
    }
    
    private func updatePositionRelated() {
        updateCursor()
        updateMarks()
    }
    
    private func updateCursor() {
        cursor.position = CGPoint(x: toViewX.apply(state.cursor), y: cursor.position.y)
    }
    
    private func updateMarks() {
        marks.removeAllChildren()
        for i in stride(from: roundToMarkStride(toViewX.inverseApply(-(size.width / 2))), to: roundToMarkStride(toViewX.inverseApply(size.width / 2)), by: markStride) {
            let mark = TimelineMark(height: size.height)
            mark.position = CGPoint(x: toViewX.apply(TimeInterval(i)), y: 0)
            marks.addChild(mark)
        }
    }
    
    private func roundToMarkStride(_ i: TimeInterval) -> Int {
        (Int(i) / markStride) * markStride
    }
}
