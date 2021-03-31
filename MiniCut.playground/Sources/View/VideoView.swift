import Foundation
import AVFoundation
import SpriteKit

/// A view of the composited video.
final class VideoView: SKNode {
    private var state: MiniCutState!
    private var isPlayingSubscription: Subscription?
    private var cursorSubscription: Subscription?
    
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
        let url = Bundle.main.url(forResource: "bigBuckBunny", withExtension: "mp4")!
        let player = AVPlayer(url: url)
        let video = SKVideoNode(avPlayer: player)
        video.size = size
        video.zPosition = 100
        crop.addChild(video)
        
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) {
            if $0 {
                player.play()
            } else {
                player.pause()
            }
        }
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) {
            player.seek(to: CMTime(seconds: $0, preferredTimescale: 1_000_000))
        }
    }
}
