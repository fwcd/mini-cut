import Foundation
import SpriteKit

/// A visual representation of a project's timeline.
final class TimelineView: SKNode, SKInputHandler, DropTarget {
    private var state: MiniCutState!
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
    private var dragState: DragState!
    
    private enum DragState {
        case cursor
        case inactive
    }
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    convenience init(state: MiniCutState, size: CGSize, zoomLevel: Double = 10.0, markStride: Int = 10) {
        self.init()
        
        self.state = state
        self.size = size
        self.zoomLevel = zoomLevel
        self.markStride = markStride
        dragState = .inactive
        
        background = SKSpriteNode(color: ViewDefaults.transparent, size: size)
        addChild(background)
        
        marks = SKNode()
        addChild(marks)
        updateMarks()
        
        cursor = TimelineCursor(height: size.height)
        addChild(cursor)
        
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            cursor.position = CGPoint(x: toViewX.apply($0), y: cursor.position.y)
        }
        
        tracks = Stack(.vertical, padding: 0, childs: [])
        addChild(tracks)
        
        let trackSize = CGSize(width: size.width, height: ViewDefaults.trackHeight)
        
        tracksSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [unowned self] tl in
            tracks.diffUpdate(nodes: &trackNodes, with: tl.tracks) {
                TrackView(state: state, id: $0.id, size: trackSize, marked: tl.tracks.count % 2 == 0, toViewScale: toViewScale)
            }
        }
    }
    
    func inputDown(at point: CGPoint) {
        dragState = .cursor
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState! {
        case .cursor:
            state.cursor = TimeInterval(toViewX.inverseApply(point.x))
        default:
            break
        }
    }
    
    func inputUp(at point: CGPoint) {
        inputDragged(to: point)
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
            // TODO: Figure out offset x position
            state.timeline[id]?.insert(clip: OffsetClip(clip: clip, offset: 0))
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
