import Foundation
import SpriteKit

/// A visual representation of a project's timeline.
final class TimelineView: SKNode, SKInputHandler, DropTarget {
    private var state: MiniCutState!
    private var cursorSubscription: Subscription!
    
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
            .then(InverseTranslation(offset: size.width / 2))
            .erase()
    }
    
    private var size: CGSize!
    private var background: SKSpriteNode!
    private var marks: SKNode!
    private var cursor: TimelineCursor!
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
        
        cursor = TimelineCursor(height: size.height)
        addChild(cursor)
        
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            cursor.position = CGPoint(x: toViewX.apply($0), y: cursor.position.y)
        }
        
        updateMarks()
        
        // TODO: Real tracks
        
        let tracks = Stack(.vertical, padding: 0, childs: [])
        for (i, track) in [Track(name: "First"), Track(name: "Second"), Track(name: "Third")].enumerated() {
            let trackSize = CGSize(width: size.width, height: 36)
            tracks.addChild(TrackView(track: track, size: trackSize, marked: i % 2 == 0))
        }
        addChild(tracks)
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
    
    func onHover(value: Any) {
        background.color = ViewDefaults.activeBgColor
    }
    
    func onUnHover(value: Any) {
        background.color = ViewDefaults.transparent
    }
    
    func onDrop(value: Any) {
        // TODO
    }
    
    private func updateMarks() {
        for i in stride(from: 0, to: Int(toViewScale.inverseApply(size.width)), by: markStride) {
            let mark = TimelineMark(height: size.height)
            mark.position = CGPoint(x: toViewX.apply(TimeInterval(i)), y: 0)
            marks.addChild(mark)
        }
    }
}
