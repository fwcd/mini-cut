import SpriteKit

extension SKNode {
    var topLeftPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.minX, y: frame.maxY)
        }
        set {
            let oldValue = topLeftPosition
            let dx = newValue.x - oldValue.x
            let dy = newValue.y - oldValue.y
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
}
