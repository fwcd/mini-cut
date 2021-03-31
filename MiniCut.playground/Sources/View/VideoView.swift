import Foundation
import SpriteKit

/// A view of the composited video.
final class VideoView: SKNode {
    private var crop: SKCropNode!
    
    convenience init(size: CGSize) {
        self.init()
        
//        crop = SKCropNode()
//        crop.maskNode = SKSpriteNode(color: .white, size: size)
//        addChild(crop)
        
        // TODO: Remove this sample and implement an actual composited video preview
        let video = SKVideoNode(fileNamed: "buck2.mp4")
        video.size = size
        video.position = CGPoint(x: 0, y: 0)
        video.zPosition = 100
        addChild(video)
        video.play()
    }
}
