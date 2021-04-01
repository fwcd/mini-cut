import SpriteKit

extension SKNode {
    /// Performs an efficient update of the given nodes that only adds/removes
    /// what has changed between the nodes and the model items.
    func diffUpdate<N, I>(nodes: inout [I.ID: N], with items: [I], using factory: (I) -> N) where N: SKNode, I: Identifiable {
        let itemDict = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
        let nodeIds = Set(nodes.keys)
        let itemIds = Set(itemDict.keys)
        let removedIds = nodeIds.subtracting(itemIds)
        let addedIds = itemIds.subtracting(nodeIds)
        
        for id in removedIds {
            nodes[id]!.removeFromParent()
            nodes[id] = nil
        }
        
        for id in addedIds {
            let node = factory(itemDict[id]!)
            nodes[id] = node
            addChild(node)
        }
    }
    
    func move(dx: CGFloat, dy: CGFloat) {
        position = CGPoint(x: position.x + dx, y: position.y + dy)
    }
    
    /// The top-left position of the accumulated frame in the parent's coordinate space.
    var topLeftPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.minX, y: frame.maxY)
        }
        set {
            let oldValue = topLeftPosition
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
        }
    }
    /// The top-center position of the accumulated frame in the parent's coordinate space.
    var topCenterPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.midX, y: frame.maxY)
        }
        set {
            let oldValue = topLeftPosition
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
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
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
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
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
        }
    }
    /// The bottom-center position of the accumulated frame in the parent's coordinate space.
    var bottomCenterPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.midX, y: frame.minY)
        }
        set {
            let oldValue = topLeftPosition
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
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
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
        }
    }
    /// The center-left position of the accumulated frame in the parent's coordinate space.
    var centerLeftPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.minX, y: frame.midY)
        }
        set {
            let oldValue = centerPosition
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
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
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
        }
    }
    /// The center-right position of the accumulated frame in the parent's coordinate space.
    var centerRightPosition: CGPoint {
        get {
            let frame = calculateAccumulatedFrame()
            return CGPoint(x: frame.maxX, y: frame.midY)
        }
        set {
            let oldValue = centerPosition
            move(dx: newValue.x - oldValue.x, dy: newValue.y - oldValue.y)
        }
    }
}
