import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

/// A view of the composited video.
final class VideoView: SKNode {
    private var state: MiniCutState!
    private var isPlayingSubscription: Subscription!
    private var cursorSubscription: Subscription!
    private var updateStartSubscription: Subscription!
    
    private var size: CGSize!
    private var crop: SKCropNode!
    
    private var startDate: Date?
    private var startCursor: TimeInterval?
    
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
        
        updateStartSubscription = state.cursorWillChange.subscribeFiring(state.cursor) { [unowned self] in
            startDate = Date()
            startCursor = $0
        }
        cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) {
            player.seek(to: CMTime(seconds: $0, preferredTimescale: 1_000))
        }
        isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) { [unowned self] in
            if $0 {
                startDate = Date()
                startCursor = state.cursor
                
                run(.repeatForever(.sequence([
                    .run {
                        state.cursorWillChange.silencing([cursorSubscription, updateStartSubscription]) {
                            state.cursor = startCursor! - startDate!.timeIntervalSinceNow
                        }
                    },
                    .wait(forDuration: cursorStride)
                ])), withKey: cursorActionKey)
                
                player.play()
            } else {
                removeAction(forKey: cursorActionKey)
                
                player.pause()
            }
        }
    }
}
