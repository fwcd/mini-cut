import Foundation
import AVFoundation
import SpriteKit

/// A clip with thumbnail in the user's library.
final class LibraryClipView: SKNode, DragSource {
    private let clip: Clip
    private let size: CGSize
    
    var draggableValue: Any { clip }
    
    init(clip: Clip, size: CGSize = ViewDefaults.thumbnailSize) {
        self.clip = clip
        self.size = size
        
        super.init()
        
        addChild(Stack.vertical([
            generateThumbnail(from: clip, size: size),
            Label(clip.name.truncated(to: 15), fontSize: ViewDefaults.thumbnailLabelFontSize, fontColor: ViewDefaults.secondary)
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

