//
//  GameViewController.swift
//  SpaceSalad
//
//  Created by James Bucanek on 10/10/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as SKNode
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

let debugAids = false

enum GameScoreKey: String {
	case LatestScore = "latest"
	case HighestScore = "highest"
}


class GameViewController: UIViewController {

	class func latestScore() -> Int {
		return NSUserDefaults.standardUserDefaults().integerForKey(GameScoreKey.LatestScore.rawValue)
	}
	
	class func highestScore() -> Int {
		return NSUserDefaults.standardUserDefaults().integerForKey(GameScoreKey.HighestScore.rawValue)
	}

	
    override func viewDidLoad() {
        super.viewDidLoad()

        if let scene = WelcomeScene.unarchiveFromFile("WelcomeScene") as? WelcomeScene {
            let skView = self.view as SKView
            skView.presentScene(scene)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
