//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

let width = 640
let height = 480

// Create and initialize the scene
let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: width, height: height))
let scene = MiniCutScene(size: CGSize(width: width, height: height))
scene.scaleMode = .aspectFill
sceneView.presentScene(scene)

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
