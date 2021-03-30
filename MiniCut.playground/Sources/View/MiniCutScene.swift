import Foundation
import SpriteKit

public class MiniCutScene: SKScene {
    private var spinnyNode: SKShapeNode!
    
    public override func didMove(to view: SKView) {
        // Create shape node to use during mouse interaction
        let w: CGFloat = 50.0
        
        spinnyNode = SKShapeNode(rectOf: CGSize(width: w, height: w), cornerRadius: w * 0.3)
        spinnyNode.lineWidth = 2.5
        
        let fadeAndRemove = SKAction.sequence([.wait(forDuration: 0.5),
                                               .fadeOut(withDuration: 0.5),
                                               .removeFromParent()])
        spinnyNode.run(.repeatForever(.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
        spinnyNode.run(fadeAndRemove)
    }
    
    @objc public static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get { true }
    }
    
    public func touchDown(atPoint pos : CGPoint) {
        guard let n = spinnyNode.copy() as? SKShapeNode else { return }
        
        n.position = pos
        n.strokeColor = SKColor.green
        addChild(n)
    }
    
    public func touchMoved(toPoint pos : CGPoint) {
        guard let n = self.spinnyNode.copy() as? SKShapeNode else { return }
        
        n.position = pos
        n.strokeColor = SKColor.blue
        addChild(n)
    }
    
    public func touchUp(atPoint pos : CGPoint) {
        guard let n = spinnyNode.copy() as? SKShapeNode else { return }
        
        n.position = pos
        n.strokeColor = SKColor.red
        addChild(n)
    }
    
    public override func mouseDown(with event: NSEvent) {
        touchDown(atPoint: event.location(in: self))
    }
    
    public override func mouseDragged(with event: NSEvent) {
        touchMoved(toPoint: event.location(in: self))
    }
    
    public override func mouseUp(with event: NSEvent) {
        touchUp(atPoint: event.location(in: self))
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
