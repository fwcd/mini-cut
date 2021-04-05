import Foundation
import SpriteKit

/// The application's primary view.
public final class MiniCutScene: SKScene, SKInputHandler {
    private var state = MiniCutState()
    
    private var dragNDrop: DragNDropController!
    private var textFieldSelection: TextFieldSelectionController!
    private var handledKeyEvent: Bool = false
    
    private var isPlayingSubscription: Subscription!
    private var timelineDnDSubscription: Subscription!
    
    private var timeline: TimelineView!
    private var video: VideoView!
    
    private var dragState: DragState = .inactive
    
    private enum DragState {
        case video
        case dragNDrop
        case inactive
    }
    
    public override func didMove(to view: SKView) {
        let initialFrame = view.frame.size
        
        dragNDrop = DragNDropController(parent: self)
        textFieldSelection = TextFieldSelectionController(parent: self)
        
        backgroundColor = ViewDefaults.background
        
        // Initialize the app's core views
        
        let title = Label("MiniCut", fontSize: ViewDefaults.titleFontSize, fontName: "Helvetica Light")
        let playButton = Button(iconTexture: IconTextures.play) { [unowned self] _ in
            state.isPlaying = !state.isPlaying
        }
        
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) {
            (playButton.label as! SKSpriteNode).texture = $0 ? IconTextures.pause : IconTextures.play
        }
        
        let toolbar = Bordered(
            .horizontal,
            length: initialFrame.width,
            leading: [
                Button(iconTexture: IconTextures.plus) { [unowned self] _ in
                    state.timeline.tracks.append(Track(name: "Track \(state.timeline.tracks.count + 1)"))
                },
                Button(iconTexture: IconTextures.trash) { [unowned self] _ in
                    if !state.timeline.tracks.isEmpty {
                        state.timeline.tracks.removeLast()
                    }
                },
                Button(iconTexture: IconTextures.scissors) { [unowned self] _ in
                    state.cut()
                }
            ],
            centered: [
                Button(iconTexture: IconTextures.backToStart) { [unowned self] _ in
                    state.cursor = 0
                    state.timelineOffset = 0
                },
                Button(iconTexture: IconTextures.back) { [unowned self] _ in
                    state.cursor -= 10
                },
                playButton,
                Button(iconTexture: IconTextures.forward) { [unowned self] _ in
                    state.cursor += 10
                },
                Button(iconTexture: IconTextures.skipToEnd) { [unowned self] _ in
                    let end = state.timeline.maxOffset
                    state.cursor = end
                    state.timelineOffset = end
                }
            ],
            trailing: [
                Slider<Double>(value: state.timelineZoom, range: 1..<40, width: 100) { [unowned self] in
                    state.timelineZoom = $0
                }
            ]
        )

        let aspectRatio: CGFloat = 16 / 9
        let videoHeight = initialFrame.height / 2.5
        let videoWidth = videoHeight * aspectRatio
        let panelWidth = (initialFrame.width - videoWidth - ViewDefaults.padding) / 2
        let timelineHeight = initialFrame.height - videoHeight - toolbar.calculateAccumulatedFrame().height - title.calculateAccumulatedFrame().height - 4 * ViewDefaults.padding

        timeline = TimelineView(
            state: state,
            textFieldSelection: textFieldSelection,
            size: CGSize(width: initialFrame.width, height: timelineHeight)
        )
        video = VideoView(state: state, size: CGSize(width: videoWidth, height: videoHeight))
        let content = Stack.vertical(useFixedPositions: true, [
            title,
            Stack.horizontal([
                LibraryView(state: state, dragNDrop: dragNDrop, size: CGSize(width: panelWidth, height: videoHeight)),
                video,
                InspectorView(state: state, textFieldSelection: textFieldSelection, size: CGSize(width: panelWidth, height: videoHeight))
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
        if dragNDrop.handleInputDown(at: point) {
            dragState = .dragNDrop
        } else if textFieldSelection.handleInputDown(at: point) {
            dragState = .inactive
        } else if video.frame.contains(convert(point, to: video.parent!)) {
            video.inputDown(at: convert(point, to: video))
            dragState = .video
        } else {
            dragState = .inactive
        }
    }
    
    func inputDragged(to point: CGPoint) {
        switch dragState {
        case .dragNDrop:
            dragNDrop.handleInputDragged(at: point)
        case .video:
            video.inputDragged(to: convert(point, to: video))
        default:
            break
        }
    }
    
    func inputUp(at point: CGPoint) {
        switch dragState {
        case .dragNDrop:
            dragNDrop.handleInputUp(at: point)
        case .video:
            video.inputUp(at: convert(point, to: video))
        default:
            break
        }
    }
    
    func inputScrolled(deltaX: CGFloat, deltaY: CGFloat, deltaZ: CGFloat) {
        // This event has to be manually forwarded
        timeline.inputScrolled(deltaX: deltaX, deltaY: deltaY, deltaZ: deltaZ)
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
