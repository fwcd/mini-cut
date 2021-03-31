import Foundation
import SpriteKit

public final class MiniCutScene: SKScene {
    private var state = MiniCutState()
    
    public override func didMove(to view: SKView) {
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
                SKSpriteNode(color: .blue, size: CGSize(width: 25, height: 50)),
                Stack.vertical([
                    Button("123"),
                    SKSpriteNode(color: .red, size: CGSize(width: 25, height: 80))
                ])
            ])
        ])
        buttons.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        addChild(buttons)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
