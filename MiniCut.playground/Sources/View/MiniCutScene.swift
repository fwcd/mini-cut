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
        
        let button = Button("Hello") {
            print("Clicked!")
        }
        button.position = CGPoint(x: 100, y: 100)
        addChild(button)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
