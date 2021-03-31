import Foundation
import SpriteKit

/// A visual representation of a project's timeline.
final class TimelineView: SKNode, SKInputHandler {
    private var state: MiniCutState!
    
    /// How zoomed-in the clips and marks on the timeline shall appear.
    var zoomLevel: CGFloat! {
        didSet { updateMarks() }
    }
    /// How frequently (actually rarely) a time mark shall be rendered. In seconds.
    var markStride: Int! {
        didSet { updateMarks() }
    }
    private var toViewX: AnyBijection<CGFloat, CGFloat> {
        (Scaling(factor: zoomLevel) - (size.width / 2))
            .erase()
    }
    
    private var size: CGSize!
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
    
    convenience init(state: MiniCutState, size: CGSize, zoomLevel: CGFloat = 10.0, markStride: Int = 10) {
        self.init()
        
        self.state = state
        self.size = size
        self.zoomLevel = zoomLevel
        self.markStride = markStride
        dragState = .inactive
        
        marks = SKNode()
        addChild(marks)
        
        cursor = TimelineCursor(height: size.height)
        addChild(cursor)
        
        updateMarks()
    }
    
    func inputDown(at point: CGPoint) {
        dragState = .cursor
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState! {
        case .cursor:
            state.cursor = TimeInterval(toViewX.inverseApply(point.x))
            print(state.cursor)
            // TODO: Bounds check, go through model first?
            cursor.position = CGPoint(x: point.x, y: cursor.position.y)
        default:
            break
        }
    }
    
    func inputUp(at point: CGPoint) {
        dragState = .inactive
    }
    
    private func updateMarks() {
        for i in stride(from: 0, to: Int(toViewX.inverseApply(size.width)), by: markStride) {
            let mark = TimelineMark(height: size.height)
            mark.position = CGPoint(x: toViewX.apply(CGFloat(i)) - (size.width / 2), y: 0)
            marks.addChild(mark)
        }
    }
}
