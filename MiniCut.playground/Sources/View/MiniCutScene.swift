import Foundation
import SpriteKit

/// The application's primary view.
public final class MiniCutScene: SKScene {
    private var state = MiniCutState()
    
    public override func didMove(to view: SKView) {
        let content = Stack.vertical([
            Button("Test"),
            TimelineView(size: CGSize(width: view.frame.width, height: view.frame.height / 2))
        ])
        content.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        addChild(content)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
