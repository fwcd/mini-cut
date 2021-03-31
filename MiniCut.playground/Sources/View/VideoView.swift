import Foundation
import SpriteKit

/// A view of the composited video.
final class VideoView: SKNode {
    private var state: MiniCutState!
    private var isPlayingSubscription: Subscription?
    
    private var size: CGSize!
    private var crop: SKCropNode!
    
    convenience init(state: MiniCutState, size: CGSize) {
        self.init()
        self.state = state
        self.size = size
        
        crop = SKCropNode()
        crop.maskNode = SKSpriteNode(color: .white, size: size)
        addChild(crop)
        
        // TODO: Remove this sample and implement an actual composited video preview
        let video = SKVideoNode(fileNamed: "bigBuckBunny.mp4")
        video.size = size
        video.zPosition = 100
        crop.addChild(video)
        
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring { [unowned state] in
            if state.isPlaying {
                video.play()
            } else {
                video.pause()
            }
        }
    }
}
