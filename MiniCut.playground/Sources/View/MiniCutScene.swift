import Foundation
import SpriteKit

private let backToStartIcon = SKTexture(imageNamed: "iconBackToStart.png")
private let backIcon = SKTexture(imageNamed: "iconBack.png")
private let playIcon = SKTexture(imageNamed: "iconPlay.png")
private let pauseIcon = SKTexture(imageNamed: "iconPause.png")
private let forwardIcon = SKTexture(imageNamed: "iconForward.png")
private let plusIcon = SKTexture(imageNamed: "iconPlus.png")

/// The application's primary view.
public final class MiniCutScene: SKScene, SKInputHandler {
    private var state = MiniCutState()
    
    private var dragNDrop: DragNDropController!
    private var textFieldSelection: TextFieldSelectionController!
    private var handledKeyEvent: Bool = false
    
    private var isPlayingSubscription: Subscription!
    private var timelineDnDSubscription: Subscription!
    
    public override func didMove(to view: SKView) {
        let initialFrame = view.frame.size
        
        dragNDrop = DragNDropController(parent: self)
        textFieldSelection = TextFieldSelectionController(parent: self)
        
        backgroundColor = ViewDefaults.background
        
        // Initialize the app's core views
        
        let title = Label("MiniCut", fontSize: ViewDefaults.titleFontSize, fontName: "Helvetica Light")
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
            Button(iconTexture: backToStartIcon) { [unowned self] _ in
                state.cursor = 0
            },
            Button(iconTexture: backIcon) { [unowned self] _ in
                state.cursor -= 10
            },
            playButton,
            Button(iconTexture: forwardIcon) { [unowned self] _ in
                state.cursor += 10
            },
            Button(iconTexture: plusIcon) { [unowned self] _ in
                state.timeline.tracks.append(Track(name: "Track \(state.timeline.tracks.count + 1)"))
            }
        ])

        let aspectRatio: CGFloat = 16 / 9
        let videoHeight = initialFrame.height / 2.5
        let videoWidth = videoHeight * aspectRatio
        let panelWidth = (initialFrame.width - videoWidth - ViewDefaults.padding) / 2
        let timelineHeight = initialFrame.height - videoHeight - toolbar.calculateAccumulatedFrame().height - title.calculateAccumulatedFrame().height - 4 * ViewDefaults.padding

        let timeline = TimelineView(
            state: state,
            textFieldSelection: textFieldSelection,
            size: CGSize(width: initialFrame.width, height: timelineHeight)
        )
        let content = Stack.vertical(useFixedPositions: true, [
            title,
            Stack.horizontal([
                LibraryView(state: state, dragNDrop: dragNDrop, size: CGSize(width: panelWidth, height: videoHeight)),
                VideoView(state: state, size: CGSize(width: videoWidth, height: videoHeight)),
                InspectorView(textFieldSelection: textFieldSelection, size: CGSize(width: panelWidth, height: videoHeight))
            ]),
            toolbar,
            timeline
        ])
        content.position = CGPoint(x: initialFrame.width / 2, y: (initialFrame.height / 2) - 2 * ViewDefaults.padding)
        addChild(content)
        
        timelineDnDSubscription = dragNDrop.register(target: timeline)
    }
    
    // SKNode conforms to NSSecureCoding, so any subclass going
    // through the decoding process must support secure coding
    @objc public static override var supportsSecureCoding: Bool { true }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func inputDown(at point: CGPoint) {
        if dragNDrop.handleInputDown(at: point) { return }
        if textFieldSelection.handleInputDown(at: point) { return }
    }
    
    func inputDragged(to point: CGPoint) {
        if dragNDrop.handleInputDragged(at: point) { return }
    }
    
    func inputUp(at point: CGPoint) {
        if dragNDrop.handleInputUp(at: point) { return }
    }
    
    func inputKeyDown(with keys: [KeyboardKey]) {
        if textFieldSelection.handleInputKeyDown(with: keys) {
            handledKeyEvent = true
        }
    }
    
    func inputKeyUp(with keys: [KeyboardKey]) {
        if !handledKeyEvent {
            let keySet = Set(keys)
            if keySet.contains(.char(" ")) {
                state.isPlaying = !state.isPlaying
            } else if keySet.contains(.backspace) || keySet.contains(.delete), let selection = state.selection {
                state.timeline[selection.trackId]?.remove(clipId: selection.clipId)
                state.selection = nil
            }
        }
        handledKeyEvent = false
    }
}
