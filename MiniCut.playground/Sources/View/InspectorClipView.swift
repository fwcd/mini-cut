import Foundation
import SpriteKit

/// A property inspector view for a single clip.
final class InspectorClipView: SKNode {
    private var state: MiniCutState!
    private var selectionSubscriptions: [Subscription] = []
    private var clipSubscription: Subscription?
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
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] _ in
            guard let self = self else { return }
            var props = [(String, (CGFloat) -> SKNode)]()
            
            switch self.content {
            case .text(let text):
                props += [
                    ("Text", {
                        let textField = TextField(size: CGSize(width: $0, height: ViewDefaults.textFieldHeight), text: text.text) { text in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                guard case .text(var newText) = self.content else { return }
                                newText.text = text
                                self.content = .text(newText)
                            }
                        }
                        self.selectionSubscriptions.append(textFieldSelection.register(textField: textField))
                        return textField
                    }),
                    ("Size", {
                        Slider<CGFloat>(value: text.size, range: 1..<300, width: $0) { size in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                guard case .text(var newText) = self.content else { return }
                                newText.size = size
                                self.content = .text(newText)
                            }
                        }
                    })
                ]
            case .audiovisual(_):
                props += [
                    ("Volume", {
                        Slider<Double>(value: self.clip?.clip.volume ?? 1, range: 0..<1, width: $0) { volume in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                self.clip?.clip.volume = volume
                            }
                        }
                    })
                ]
            default:
                break
            }
            
            if self.clip?.clip.category != .audio {
                props += [
                    ("X", {
                        Slider<Double>(value: self.clip?.clip.visualOffsetDx ?? 0, range: -1..<1, width: $0) { dx in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                self.clip?.clip.visualOffsetDx = dx
                            }
                        }
                    }),
                    ("Y", {
                        Slider<Double>(value: self.clip?.clip.visualOffsetDy ?? 0, range: -1..<1, width: $0) { dy in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                self.clip?.clip.visualOffsetDy = dy
                            }
                        }
                    }),
                    ("Scale", {
                        Slider<Double>(value: self.clip?.clip.visualScale ?? 1, range: 0..<4, width: $0) { scale in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                self.clip?.clip.visualScale = scale
                            }
                        }
                    }),
                    ("Alpha", {
                        Slider<Double>(value: self.clip?.clip.visualAlpha ?? 1, range: 0..<1, width: $0) { alpha in
                            state.timelineDidChange.silencing(self.clipSubscription) {
                                self.clip?.clip.visualAlpha = alpha
                            }
                        }
                    })
                ]
            }
            
            let form = Form(size: size, childs: props)
            form.position = CGPoint(x: -(size.width / 2), y: size.height / 2)
            self.removeAllChildren()
            self.addChild(form)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
