import Foundation
import SpriteKit

/// A property inspector view.
final class InspectorView: SKSpriteNode {
    private var selectionSubscription: Subscription!
    
    init(
        state: MiniCutState,
        textFieldSelection: TextFieldSelectionController,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding
    ) {
        super.init(texture: nil, color: ViewDefaults.quaternary, size: size)
        
        let header = Label("Inspector", fontSize: ViewDefaults.headerFontSize, fontColor: ViewDefaults.secondary)
        let headerFrame = header.calculateAccumulatedFrame()
        header.position = CGPoint(x: 0, y: (size.height / 2) - padding - (headerFrame.height / 2))
        addChild(header)
        
        let content = SKNode()
        let contentSize = CGSize(width: size.width, height: size.height - (2 * padding) - headerFrame.height)
        content.position = CGPoint(x: 0, y: -headerFrame.height - padding)
        addChild(content)
        
        selectionSubscription = state.selectionDidChange.subscribeFiring(state.selection) {
            content.removeAllChildren()
            if let selection = $0 {
                content.addChild(InspectorClipView(
                    state: state,
                    textFieldSelection: textFieldSelection,
                    trackId: selection.trackId,
                    clipId: selection.clipId,
                    size: contentSize
                ))
            } else {
                content.addChild(Label(
                    "Select a timeline clip to inspect it!",
                    fontSize: ViewDefaults.hintFontSize,
                    fontColor: ViewDefaults.hintFontColor
                ))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
