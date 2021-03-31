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
        
        let buttons = Stack.vertical([
            Button("Test"),
            Stack.horizontal([
                Button("This is a looooooooooooong button"),
                Button("This one not so much")
            ]),
            Button("Test"),
            Stack.horizontal([
                Button("Hello") { print("Hello") },
                Button("World") { print("World") },
                SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 25)),
                Stack.vertical([
                    Button("123"),
                    SKSpriteNode(color: .red, size: CGSize(width: 25, height: 25))
                ])
            ])
        ])
        buttons.position = CGPoint(x: 200, y: 300)
        addChild(buttons)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
