//
//  MiniCutViewController.swift
//  MiniCutDesktop
//
//  Created by Fredrik on 4/2/21.
//

import Cocoa
import SpriteKit

class MiniCutViewController: NSViewController {
    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = skView {
            let scene = MiniCutScene()
                
            let camera = SKCameraNode()
            camera.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
            camera.setScale(view.frame.width)
            scene.addChild(camera)
            scene.camera = camera
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

