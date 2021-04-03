import Foundation
import AVFoundation
import SpriteKit

/// A clip with thumbnail in the user's library.
final class LibraryClipView: SKNode, DragSource {
    private var clip: Clip!
    private var size: CGSize!
    private var customSize: CGSize!
    
    var draggableValue: Any { clip! }
    
    init(clip: Clip, size: CGSize = ViewDefaults.thumbnailSize) {
        super.init()
        self.clip = clip
        self.size = size
        
        addChild(Stack.vertical([
            generateThumbnail(from: clip, size: size),
            Label(clip.name, fontSize: ViewDefaults.thumbnailLabelFontSize, fontColor: ViewDefaults.secondary)
        ]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
    
    func makeHoverNode() -> SKNode {
        let node = generateThumbnail(from: clip, size: size)
        node.alpha = 0.5
        return node
    }
}

