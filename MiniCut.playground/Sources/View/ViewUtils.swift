import SpriteKit

extension SKNode {
    /// The top-left position of the accumulated frame in the parent's coordinate space.
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
    /// The top-right position of the accumulated frame in the parent's coordinate space.
    var topRightPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.maxX, y: frame.maxY)
        }
        set {
            let oldValue = topLeftPosition
            let dx = newValue.x - oldValue.x
            let dy = newValue.y - oldValue.y
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
    /// The bottom-left position of the accumulated frame in the parent's coordinate space.
    var bottomLeftPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.minX, y: frame.minY)
        }
        set {
            let oldValue = bottomLeftPosition
            let dx = newValue.x - oldValue.x
            let dy = newValue.y - oldValue.y
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
    /// The bottom-right position of the accumulated frame in the parent's coordinate space.
    var bottomRightPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.maxX, y: frame.minY)
        }
        set {
            let oldValue = bottomLeftPosition
            let dx = newValue.x - oldValue.x
            let dy = newValue.y - oldValue.y
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
    /// The center position of the accumulated frame in the parent's coordinate space.
    var centerPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.midX, y: frame.midY)
        }
        set {
            let oldValue = centerPosition
            let dx = newValue.x - oldValue.x
            let dy = newValue.y - oldValue.y
            position = CGPoint(x: position.x + dx, y: position.y + dy)
        }
    }
}
