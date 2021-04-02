import Foundation
import SpriteKit

/// A property inspector view for a single clip.
final class InspectorClipView: SKNode {
    private var state: MiniCutState!
    private var selectionSubscriptions: [Subscription] = []
    private var trackId: UUID!
    private var clipId: UUID!
    
    private var clip: OffsetClip? {
        get { state.timeline[trackId]?[clipId] }
        set { state.timeline[trackId]?[clipId] = newValue }
    }
    private var content: ClipContent? {
        get { clip?.clip.content }
        set { clip?.clip.content = newValue! }
    }
    
    convenience init(
        state: MiniCutState,
        textFieldSelection: TextFieldSelectionController,
        trackId: UUID,
        clipId: UUID,
        size: CGSize
    ) {
        self.init()
        self.state = state
        self.trackId = trackId
        self.clipId = clipId
        
        switch content {
        case .text(let text):
            addChild(Form(size: size, childs: [
                ("Text", { [unowned self] in
                    let textField = TextField(size: CGSize(width: $0, height: ViewDefaults.textFieldHeight), text: text.text) {
                        guard case .text(var newText) = content else { return }
                        newText.text = $0
                        content = .text(newText)
                    }
                    selectionSubscriptions.append(textFieldSelection.register(textField: textField))
                    return textField
                })
            ]))
        default:
            break
        }
    }
}