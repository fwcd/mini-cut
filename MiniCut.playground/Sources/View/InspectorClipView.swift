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
    
    init(
        state: MiniCutState,
        textFieldSelection: TextFieldSelectionController,
        trackId: UUID,
        clipId: UUID,
        size: CGSize
    ) {
        super.init()
        self.state = state
        self.trackId = trackId
        self.clipId = clipId
        
        var props = [(String, (CGFloat) -> SKNode)]()
        
        switch content {
        case .text(let text):
            props += [
                ("Text", { [unowned self] in
                    let textField = TextField(size: CGSize(width: $0, height: ViewDefaults.textFieldHeight), text: text.text) {
                        guard case .text(var newText) = content else { return }
                        newText.text = $0
                        content = .text(newText)
                    }
                    selectionSubscriptions.append(textFieldSelection.register(textField: textField))
                    return textField
                }),
                ("Size", { [unowned self] in
                    Slider<CGFloat>(value: text.size, range: 1..<300, width: $0) {
                        guard case .text(var newText) = content else { return }
                        newText.size = $0
                        content = .text(newText)
                    }
                })
            ]
        default:
            break
        }
        
        props += [
            ("X", { [unowned self] in
                Slider<Double>(value: clip?.clip.visualOffsetDx ?? 0, range: -1..<1, width: $0) {
                    clip?.clip.visualOffsetDx = $0
                }
            }),
            ("Y", { [unowned self] in
                Slider<Double>(value: clip?.clip.visualOffsetDy ?? 0, range: -1..<1, width: $0) {
                    clip?.clip.visualOffsetDy = $0
                }
            }),
            ("Scale", { [unowned self] in
                Slider<Double>(value: clip?.clip.visualScale ?? 1, range: 0..<4, width: $0) {
                    clip?.clip.visualScale = $0
                }
            })
        ]
        
        let form = Form(size: size, childs: props)
        form.position = CGPoint(x: -(size.width / 2), y: size.height / 2)
        addChild(form)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
