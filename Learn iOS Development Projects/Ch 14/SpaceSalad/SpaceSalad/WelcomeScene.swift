//
//  WelcomeScene.swift
//  SpaceSalad1
//
//  Created by James Bucanek on 7/14/14.
//  Copyright (c) 2014 James Bucanek. All rights reserved.
//

import SpriteKit


class WelcomeScene: ResizableScene {

	override func didMoveToView(view: SKView) {
		// Set up the scene

		// Fit the scene inside the new view
		scaleMode = .AspectFill
		size = view.frame.size

		// Fill the labels with the latest scores
		if let latest = childNodeWithName("latest") as? SKLabelNode {
			latest.text = "\(GameViewController.latestScore())"
		}
		if let highest = childNodeWithName("highest") as? SKLabelNode {
			highest.text = "\(GameViewController.highestScore())"
		}
	}

	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		// User touched somewhere in the Welcome scene: start the game
		if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
			// Present the scene with a transition
			let doors = SKTransition.doorsOpenVerticalWithDuration(1.0)
			view!.presentScene(scene, transition: doors)
		}
	}

}
