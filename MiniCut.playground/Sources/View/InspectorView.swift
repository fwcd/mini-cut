import Foundation
import SpriteKit

/// A property inspector view.
final class InspectorView: SKSpriteNode {
    private var selectionSubscription: Subscription!
    
    convenience init(state: MiniCutState, textFieldSelection: TextFieldSelectionController, size: CGSize) {
        self.init(color: ViewDefaults.quaternary, size: size)
        
        let header = Label("Inspector", fontSize: ViewDefaults.headerFontSize, fontColor: ViewDefaults.secondary)
        let headerFrame = header.calculateAccumulatedFrame()
        header.position = CGPoint(x: 0, y: (size.height / 2) - ViewDefaults.padding - (headerFrame.height / 2))
        addChild(header)
        
        let content = SKNode()
        let contentSize = CGSize(width: size.width, height: size.height - (2 * ViewDefaults.padding) - headerFrame.height)
        addChild(content)
        addChild(Slider(size: size) { _ in /* todo */ })
        
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
                    "Select a timeline clip",
                    fontSize: ViewDefaults.hintFontSize,
                    fontColor: ViewDefaults.tertiary
                ))
            }
        }
    }
}
