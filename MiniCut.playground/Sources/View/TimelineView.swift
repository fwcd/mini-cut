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
    
    convenience init(size: CGSize, zoomLevel: CGFloat = 10.0, markStride: Int = 10) {
        self.init()
        
        self.size = size
        self.zoomLevel = zoomLevel
        self.markStride = markStride
        
        marks = SKNode()
        addChild(marks)
        
        update()
    }
    
    private func update() {
        for i in stride(from: 0, to: Int(toViewX.inverseApply(size.width)), by: markStride) {
            let mark = SKSpriteNode(color: .red, size: CGSize(width: 1, height: size.height))
            mark.position = CGPoint(x: toViewX.apply(CGFloat(i)) - (size.width / 2), y: 0)
            marks.addChild(mark)
        }
    }
}
