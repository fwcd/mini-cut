import Foundation
import SpriteKit

/// A view of available static clips for use in the project.
final class LibraryStaticClipsView: SKNode {
    private var dndSubscriptions: [Subscription] = []
    
    init(
        clips: [Clip],
        dragNDrop: DragNDropController,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding
    ) {
        super.init()
        
        let clipsNode = Flow(size: CGSize(width: size.width - (padding * 2), height: size.height - (padding * 2)))
        clipsNode.position = CGPoint(x: -(size.width / 2) + padding, y: (size.height / 2) - padding)
        
        for clip in clips {
            let clipNode = LibraryClipView(clip: clip)
            clipsNode.addChild(clipNode)
            dndSubscriptions.append(dragNDrop.register(source: clipNode))
        }
        
        addChild(clipsNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
