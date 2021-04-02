import Foundation
import SpriteKit

/// A simple UI control that lets the user select a numeric value from a range.
public class Slider: SKNode, SKInputHandler {
    private var size: CGSize!
    private var knob: SKShapeNode!
    
    private var knobInactiveBgColor: Color!
    private var knobActiveBgColor: Color!
    private var action: ((Double) -> Void)?
    
    private var toViewX: AnyBijection<Double, CGFloat>!
    
    public override var isUserInteractionEnabled: Bool {
        get { true }
        set { /* ignore */ }
    }
    
    public convenience init(
        range: Range<Double>,
        size: CGSize,
        trackThickness: CGFloat = ViewDefaults.sliderTrackThickness,
        trackBgColor: Color = ViewDefaults.inactiveBgColor,
        knobRadius: CGFloat = ViewDefaults.sliderKnobRadius,
        knobInactiveBgColor: Color = ViewDefaults.knobInactiveBgColor,
        knobActiveBgColor: Color = ViewDefaults.knobActiveBgColor,
        sliderKnobRadius
        action: ((Double) -> Void)? = nil
    ) {
        self.init()
        self.size = size
        self.knobInactiveBgColor = knobInactiveBgColor
        self.knobActiveBgColor = knobActiveBgColor
        self.action = action
        
        toViewX = InverseTranslation(offset: range.lowerBound)
            .then(InverseScaling(divisor: range.upperBound - range.lowerBound))
            .then(AnyBijection(CGFloat.init(_:), Double.init(_:)))
            .then(Scaling(factor: size.width))
            .then(InverseTranslation(offset: size.width / 2))
            .erase()
        
        let track = SKSpriteNode(color: trackBgColor, size: CGSize(width: size.width, height: trackThickness))
        addChild(track)
        
        knob = SKShapeNode(circleOfRadius: knobRadius)
        knob.lineWidth = 0
        knob.fillColor = knobInactiveBgColor
        addChild(knob)
    }
    
    public func inputDown(at point: CGPoint) {
        knob.fillColor = knobActiveBgColor
    }
    
    public func inputDragged(to point: CGPoint) {
        let newX = max(min(point.x, size.width / 2), -(size.width / 2))
        knob.position = CGPoint(x: newX, y: 0)
        action?(toViewX.inverseApply(newX))
    }
    
    public func inputUp(at point: CGPoint) {
        inputDragged(to: point)
        knob.fillColor = knobInactiveBgColor
    }
}
