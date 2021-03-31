//
//  MiniCutViewController.swift
//  MiniCut
//
//  Created by Fredrik on 3/31/21.
//

import UIKit
import SpriteKit

class MiniCutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = view as? SKView {
            let scene = MiniCutScene()
            
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool { true }
}
