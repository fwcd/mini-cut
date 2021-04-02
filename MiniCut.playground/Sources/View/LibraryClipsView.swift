import Foundation
import SpriteKit

/// A view of the user's clip library.
final class LibraryClipsView: SKNode {
    private var librarySubscription: Subscription!
    
    convenience init(
        state: MiniCutState,
        dragNDrop: DragNDropController,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding
    ) {
        self.init()
        
        librarySubscription = state.libraryWillChange.subscribeFiring(state.library) { [unowned self] in
            let clips = Flow(size: CGSize(width: size.width - (padding * 2), height: size.height - (padding * 2)))
            clips.position = CGPoint(x: -(size.width / 2) + padding, y: (size.height / 2) - padding)
            dragNDrop.clearSources()
            
            for clip in $0.clips {
                let clip = LibraryClipView(clip: clip)
                clips.addChild(clip)
                dragNDrop.register(source: clip)
            }
            
            removeAllChildren()
            addChild(clips)
        }
    }
}
