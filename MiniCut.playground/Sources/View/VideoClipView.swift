import Foundation
import AVFoundation
import SpriteKit

private let cursorActionKey = "cursorAction"
private let cursorStride: TimeInterval = 0.1

/// A view of a single clip's video.
final class VideoClipView: SKNode {
    private var state: MiniCutState!
    private var clipSubscription: Subscription!
    private var isPlayingSubscription: Subscription!
    private(set) var cursorSubscription: Subscription!
    
    private var player: AVPlayer!
    
    convenience init(state: MiniCutState, trackId: UUID, id: UUID, size: CGSize) {
        self.init()
        self.state = state
        
        print("[DEBUG] Creating VideoClipView")
        
        clipSubscription = state.timelineDidChange.subscribeFiring(state.timeline) { [weak self] in
            guard let clip = $0[trackId]?[id] else { return }
            
            switch clip.clip.content {
            case .video(let content):
                let player = AVPlayer(playerItem: AVPlayerItem(asset: content.asset))
                let video = SKVideoNode(avPlayer: player)
                video.size = size
                self?.player = player
                self?.addChild(video)
                
                self?.cursorSubscription = state.cursorWillChange.subscribeFiring(state.cursor) {
                    let relative = $0 - clip.offset
                    self?.player.seek(to: CMTime(seconds: relative, preferredTimescale: 1000))
                }
                
                self?.isPlayingSubscription = state.isPlayingWillChange.subscribeFiring(state.isPlaying) {
                    if $0 {
                        video.play()
                    } else {
                        video.pause()
                    }
                }
            default:
                // TODO: Deal with other clip types
                break
            }
        }
    }
    
    deinit {
        print("[DEBUG] Dropping VideoClipView")
        player?.replaceCurrentItem(with: nil)
    }
}
