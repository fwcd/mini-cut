import Foundation
import SpriteKit

/// A simple UI control that lets the user select a numeric value from a range.
public class Slider: SKNode, SKInputHandler {
    private var knob: SKShapeNode!
    
    private var knobInactiveBgColor: Color!
    private var knobActiveBgColor: Color!
    private var padding: CGFloat!
    private var action: ((CGFloat) -> Void)?
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    public convenience init(
        size: CGSize,
        trackThickness: CGFloat = ViewDefaults.sliderTrackThickness,
        trackBgColor: Color = ViewDefaults.inactiveBgColor,
        knobRadius: CGFloat = ViewDefaults.sliderKnobRadius,
        knobInactiveBgColor: Color = ViewDefaults.knobInactiveBgColor,
        knobActiveBgColor: Color = ViewDefaults.knobActiveBgColor,
        sliderKnobRadius
        action: ((CGFloat) -> Void)? = nil
    ) {
        self.init()
        self.knobInactiveBgColor = knobInactiveBgColor
        self.knobActiveBgColor = knobActiveBgColor
        self.padding = padding
        self.action = action
        
        let track = SKSpriteNode(color: trackBgColor, size: CGSize(width: size.width, height: trackThickness))
        addChild(track)
        
        knob = SKShapeNode(circleOfRadius: knobRadius)
        knob.lineWidth = 0
        knob.fillColor = knobInactiveBgColor
        addChild(knob)
    }
    
    private func active(at point: CGPoint) -> Bool {
        parent.map { contains(convert(point, to: $0)) } ?? false
    }
    
    public func inputDown(at point: CGPoint) {
        knob.fillColor = knobActiveBgColor
    }
    
    public func inputDragged(to point: CGPoint) {
        knob.fillColor = active(at: point) ? knobActiveBgColor : knobInactiveBgColor
    }
    
    public func inputUp(at point: CGPoint) {
        knob.fillColor = knobInactiveBgColor
        if active(at: point) {
//            action?(self)
            // TODO
        }
    }
}
