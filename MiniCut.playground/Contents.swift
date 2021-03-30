//: A SpriteKit based Playground

import PlaygroundSupport
import SpriteKit

// Load the SKScene from 'GameScene.sks'
let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 640, height: 480))

if let scene = MiniCutScene(fileNamed: "MiniCutScene") {
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    
    // Present the scene
    sceneView.presentScene(scene)
} else {
    fatalError("Could not find scene file!")
}

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
