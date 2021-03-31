import Foundation
import SpriteKit

/// The application's primary view.
public final class MiniCutScene: SKScene {
    private var state = MiniCutState()
    
    public override func didMove(to view: SKView) {
        // The core views of the app are initialized here
        
        let toolbar = Stack.horizontal([
            // TODO
            Button("Play"),
            Button("Skip")
        ])
        
        let aspectRatio: CGFloat = 16 / 9
        let videoHeight = view.frame.height / 2
        let videoWidth = videoHeight * aspectRatio
        let panelWidth = (view.frame.width - videoWidth) / 2 - ViewDefaults.padding
        let timelineHeight = view.frame.height - videoHeight - toolbar.calculateAccumulatedFrame().height - ViewDefaults.padding
        
        let content = Stack.vertical([
            Stack.horizontal([
                LibraryView(size: CGSize(width: panelWidth, height: videoHeight)),
                VideoView(size: CGSize(width: videoWidth, height: videoHeight)),
                InspectorView(size: CGSize(width: panelWidth, height: videoHeight))
            ]),
            toolbar,
            TimelineView(size: CGSize(width: view.frame.width, height: timelineHeight))
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
