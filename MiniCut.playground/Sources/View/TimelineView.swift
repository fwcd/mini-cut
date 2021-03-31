import Foundation
import SpriteKit

/// A visual representation of a project's timeline.
final class TimelineView: SKNode {
    /// How zoomed-in the clips and marks on the timeline shall appear.
    var zoomLevel: CGFloat! {
        didSet { update() }
    }
    
    /// How frequently (actually rarely) a time mark shall be rendered. In seconds.
    var markStride: Int! {
        didSet { update() }
    }
    
    private var toViewX: Scaling<CGFloat> { Scaling(factor: zoomLevel) }
    
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
    
    convenience init(size: CGSize, zoomLevel: CGFloat = 10.0, markStride: Int = 10) {
        self.init()
        
        self.size = size
        self.zoomLevel = zoomLevel
        self.markStride = markStride
        dragState = .inactive
        
        marks = SKNode()
        addChild(marks)
        
        cursor = TimelineCursor(height: size.height)
        addChild(cursor)
        
        update()
    }
    
    override func mouseDown(with event: NSEvent) {
        dragState = .cursor
    }
    
    override func mouseDragged(with event: NSEvent) {
        switch dragState! {
        case .cursor:
            // TODO: Bounds check, go through model first?
            cursor.position = CGPoint(x: event.location(in: self).x, y: cursor.position.y)
        default:
            break
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        dragState = .inactive
    }
    
    private func update() {
        for i in stride(from: 0, to: Int(toViewX.inverseApply(size.width)), by: markStride) {
            let mark = TimelineMark(height: size.height)
            mark.position = CGPoint(x: toViewX.apply(CGFloat(i)) - (size.width / 2), y: 0)
            marks.addChild(mark)
        }
        
        // TODO: Cursor
    }
}
