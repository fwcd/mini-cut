import Foundation
import SpriteKit

public class DemoNode: SKShapeNode {
    public override convenience init() {
        self.init(rect: CGRect(x: 0, y: 0, width: 100, height: 100))
    }
}
