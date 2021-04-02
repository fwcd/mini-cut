import Foundation
import SpriteKit

private let cursorZPosition: CGFloat = 100

/// A visual representation of a project's timeline.
final class TimelineView: SKNode, SKInputHandler, DropTarget {
    private var state: MiniCutState!
    private var textFieldSelection: TextFieldSelectionController!
    private var cursorSubscription: Subscription!
    private var tracksSubscription: Subscription!
    
    /// How zoomed-in the clips and marks on the timeline shall appear.
    var zoomLevel: Double! {
        didSet { updateMarks() }
    }
    /// How frequently (actually rarely) a time mark shall be rendered. In seconds.
    var markStride: Int! {
        didSet { updateMarks() }
    }
    
    private var toViewScale: AnyBijection<TimeInterval, CGFloat> {
        Scaling(factor: zoomLevel)
            .then(AnyBijection(CGFloat.init(_:), TimeInterval.init(_:)))
            .erase()
    }
    private var toViewX: AnyBijection<TimeInterval, CGFloat> {
        toViewScale
            .then(InverseTranslation(offset: (size.width / 2) - ViewDefaults.trackControlsWidth))
            .erase()
    }
    
    private var size: CGSize!
    private var background: SKSpriteNode!
    private var marks: SKNode!
    private var cursor: TimelineCursor!
    private var tracks: SKNode!
    private var trackNodes: [UUID: TrackView] = [:]
    
    private var dragState: DragState? = nil
    
    private enum DragState {
        case cursor
        case clip(ClipDragState)
        case trimming(TrackClipView)
        case inactive
    }
    
    private struct ClipDragState {
        var trackId: UUID
        var clipId: UUID
        let dxInClip: CGFloat
    }
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    convenience init(
        state: MiniCutState,
        textFieldSelection: TextFieldSelectionController,
        size: CGSize,
        zoomLevel: Double = 10.0,
        markStride: Int = 10
    ) {
        self.init()
        
        self.state = state
        self.textFieldSelection = textFieldSelection
        self.size = size
        self.zoomLevel = zoomLevel
        self.markStride = markStride
        dragState = .inactive
        
        background = SKSpriteNode(color: ViewDefaults.transparent, size: size)
        addChild(background)
        
        marks = SKNode()
        addChild(marks)
        updateMarks()
        
        tracks = Stack(.vertical, padding: 2, childs: [])
        addChild(tracks)
        
        let trackSize = CGSize(width: size.width, height: ViewDefaults.trackHeight)
        
        tracksSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] tl in
            tracks.diffUpdate(nodes: &trackNodes, with: tl.tracks) {
                TrackView(state: state, id: $0.id, size: trackSize, marked: tl.tracks.count % 2 == 0, toViewScale: toViewScale)
            }
        }
        
        cursor = TimelineCursor(height: size.height)
        cursor.zPosition = cursorZPosition
        addChild(cursor)
        
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            cursor.position = CGPoint(x: toViewX.apply($0), y: cursor.position.y)
        }
    }
    
    func inputDown(at point: CGPoint) {
        textFieldSelection.selection = nil
        
        for (trackId, track) in trackNodes {
            for (clipId, clip) in track.clipNodes {
                if let clipParent = clip.parent {
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
        dragState = .cursor
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState! {
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
        if case .trimming(let clip) = dragState {
            clip.finishTrimming()
        } else {
            inputDragged(to: point)
        }
        dragState = .inactive
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
    
    private func updateMarks() {
        for i in stride(from: 0, to: Int(toViewScale.inverseApply(size.width - ViewDefaults.trackControlsWidth)), by: markStride) {
            let mark = TimelineMark(height: size.height)
            mark.position = CGPoint(x: toViewX.apply(TimeInterval(i)), y: 0)
            marks.addChild(mark)
        }
    }
}
