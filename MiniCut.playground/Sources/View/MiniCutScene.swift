import Foundation
import SpriteKit

private let backIcon = SKTexture(imageNamed: "iconBack.png")
private let playIcon = SKTexture(imageNamed: "iconPlay.png")
private let pauseIcon = SKTexture(imageNamed: "iconPause.png")
private let forwardIcon = SKTexture(imageNamed: "iconForward.png")

/// The application's primary view.
public final class MiniCutScene: SKScene {
    private var state = MiniCutState()
    
    public override func didMove(to view: SKView) {
        backgroundColor = ViewDefaults.background
        
        // The core views of the app are initialized here
        
        let title = Label("MiniCut", fontSize: 36, fontName: "Helvetica Light")
        let toolbar = Stack.horizontal([
            Button(iconTexture: backIcon),
            Button(iconTexture: playIcon) { [unowned self] button in
                let newPlaying = !state.isPlaying
                if newPlaying {
                    (button.label as! SKSpriteNode).texture = pauseIcon
                } else {
                    (button.label as! SKSpriteNode).texture = playIcon
                }
                state.isPlaying = newPlaying
            },
            Button(iconTexture: forwardIcon)
        ])
        
        let aspectRatio: CGFloat = 16 / 9
        let videoHeight = view.frame.height / 2.5
        let videoWidth = videoHeight * aspectRatio
        let panelWidth = (view.frame.width - videoWidth - ViewDefaults.padding) / 2
        let timelineHeight = view.frame.height - videoHeight - toolbar.calculateAccumulatedFrame().height - title.calculateAccumulatedFrame().height - 4 * ViewDefaults.padding
        
        let content = Stack.vertical([
            title,
            Stack.horizontal([
                LibraryView(size: CGSize(width: panelWidth, height: videoHeight)),
                VideoView(size: CGSize(width: videoWidth, height: videoHeight)),
                InspectorView(size: CGSize(width: panelWidth, height: videoHeight))
            ]),
            toolbar,
            TimelineView(size: CGSize(width: view.frame.width, height: timelineHeight))
        ])
        content.position = CGPoint(x: view.frame.midX, y: view.frame.midY - 2 * ViewDefaults.padding)
        addChild(content)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
