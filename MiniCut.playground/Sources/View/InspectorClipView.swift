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
                ("Text", { [weak self] in
                    let textField = TextField(size: CGSize(width: $0, height: ViewDefaults.textFieldHeight), text: text.text) {
                        guard case .text(var newText) = self?.content else { return }
                        newText.text = $0
                        self?.content = .text(newText)
                    }
                    self?.selectionSubscriptions.append(textFieldSelection.register(textField: textField))
                    return textField
                }),
                ("Size", { [weak self] in
                    Slider<CGFloat>(value: text.size, range: 1..<300, width: $0) {
                        guard case .text(var newText) = self?.content else { return }
                        newText.size = $0
                        self?.content = .text(newText)
                    }
                })
            ]
        case .audiovisual(_):
            props += [
                ("Volume", { [weak self] in
                    Slider<Double>(value: self?.clip?.clip.volume ?? 1, range: 0..<2, width: $0) {
                        self?.clip?.clip.volume = $0
                    }
                })
            ]
        default:
            break
        }
        
        if clip?.clip.category != .audio {
            props += [
                ("X", { [weak self] in
                    Slider<Double>(value: self?.clip?.clip.visualOffsetDx ?? 0, range: -1..<1, width: $0) {
                        self?.clip?.clip.visualOffsetDx = $0
                    }
                }),
                ("Y", { [weak self] in
                    Slider<Double>(value: self?.clip?.clip.visualOffsetDy ?? 0, range: -1..<1, width: $0) {
                        self?.clip?.clip.visualOffsetDy = $0
                    }
                }),
                ("Scale", { [weak self] in
                    Slider<Double>(value: self?.clip?.clip.visualScale ?? 1, range: 0..<4, width: $0) {
                        self?.clip?.clip.visualScale = $0
                    }
                }),
                ("Alpha", { [weak self] in
                    Slider<Double>(value: self?.clip?.clip.visualAlpha ?? 1, range: 0..<1, width: $0) {
                        self?.clip?.clip.visualAlpha = $0
                    }
                })
            ]
        }
        
        let form = Form(size: size, childs: props)
        form.position = CGPoint(x: -(size.width / 2), y: size.height / 2)
        addChild(form)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
