import Foundation
import AVFoundation
import SpriteKit

/// A view of the user's clip library.
final class LibraryClipsView: SKNode {
    private var librarySubscription: Subscription!
    private var dndSubscriptions: [Subscription] = []
    
    init(
        state: MiniCutState,
        dragNDrop: DragNDropController,
        size: CGSize,
        padding: CGFloat = ViewDefaults.padding
    ) {
        super.init()
        
        let clipsWrapper = SKNode()
        addChild(clipsWrapper)
        
        librarySubscription = state.libraryWillChange.subscribeFiring(state.library) { [unowned self] in
            let clips = Flow(size: CGSize(width: size.width - (padding * 2), height: size.height - (padding * 2)))
            clips.position = CGPoint(x: -(size.width / 2) + padding, y: (size.height / 2) - padding)
            dndSubscriptions = []
            
            for clip in $0.clips {
                let clip = LibraryClipView(clip: clip)
                clips.addChild(clip)
                dndSubscriptions.append(dragNDrop.register(source: clip))
            }
            
            clipsWrapper.removeAllChildren()
            clipsWrapper.addChild(clips)
        }
        
        let importButton = Button("Import Clips...", height: ViewDefaults.smallButtonSize, fontSize: ViewDefaults.smallButtonSize) { [unowned self] _ in
            runFilePicker { urls in
                state.library.clips += urls.map(Clip.init(url:))
            }
        }
        importButton.bottomCenterPosition = CGPoint(x: 0, y: -(size.height / 2) + padding)
        addChild(importButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
