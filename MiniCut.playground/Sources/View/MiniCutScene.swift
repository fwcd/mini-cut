import Foundation
import SpriteKit

private let backIcon = SKTexture(imageNamed: "iconBack.png")
private let playIcon = SKTexture(imageNamed: "iconPlay.png")
private let pauseIcon = SKTexture(imageNamed: "iconPause.png")
private let forwardIcon = SKTexture(imageNamed: "iconForward.png")

/// The application's primary view.
public final class MiniCutScene: SKScene {
    private var state = MiniCutState()
    private var isPlayingSubscription: Subscription?
    
    public override func didMove(to view: SKView) {
        let initialFrame = view.frame.size
        
        backgroundColor = ViewDefaults.background
        
        // The core views of the app are initialized here
        
        let title = Label("MiniCut", fontSize: 36, fontName: "Helvetica Light")
        let playButton = Button(iconTexture: playIcon) { [unowned self] _ in
            state.isPlaying = !state.isPlaying
        }
        
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) {
            if $0 {
                (playButton.label as! SKSpriteNode).texture = pauseIcon
            } else {
                (playButton.label as! SKSpriteNode).texture = playIcon
            }
        }
        
        let toolbar = Stack.horizontal([
            Button(iconTexture: backIcon),
            playButton,
            Button(iconTexture: forwardIcon)
        ])

        let aspectRatio: CGFloat = 16 / 9
        let videoHeight = initialFrame.height / 2.5
        let videoWidth = videoHeight * aspectRatio
        let panelWidth = (initialFrame.width - videoWidth - ViewDefaults.padding) / 2
        let timelineHeight = initialFrame.height - videoHeight - toolbar.calculateAccumulatedFrame().height - title.calculateAccumulatedFrame().height - 4 * ViewDefaults.padding

        let content = Stack.vertical([
            title,
            Stack.horizontal([
                LibraryView(size: CGSize(width: panelWidth, height: videoHeight)),
                VideoView(state: state, size: CGSize(width: videoWidth, height: videoHeight)),
                InspectorView(size: CGSize(width: panelWidth, height: videoHeight))
            ]),
            toolbar,
            TimelineView(state: state, size: CGSize(width: initialFrame.width, height: timelineHeight))
        ])
        content.position = CGPoint(x: initialFrame.width / 2, y: (initialFrame.height / 2) - 2 * ViewDefaults.padding)
        addChild(content)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
