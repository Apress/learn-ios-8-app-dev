//
//  ResizableScene.swift
//  SpaceSalad1
//
//  Created by James Bucanek on 7/14/14.
//  Copyright (c) 2014 James Bucanek. All rights reserved.
//

import SpriteKit


//
// A simple extention to SKScene that adjusts the positions the first level of child nodes
//	whenever the scene is resized.
//
// It assumes there is a single node named "background" that should be resized to exactly fit the scene.
//	The background node is expected to have its anchor point (origin) at {0.0,0.0}.
//
// All remaining nodes have their positions translated (from the old size to the new size) so they
//	retain the same proportional distribution in the new scene, without being resized. Becuase the
//	node's position coordinate is translated, anchor points play a significant role in alignment.
//

class ResizableScene: SKScene {

	let backgroundNodeName = "background"

	override func didChangeSize(oldSize: CGSize) {
		let newSize = size
		if newSize != oldSize {
			// The scene changed size: scale the contents to fit

			// Resize the background to fit the scene
			if let background = childNodeWithName(backgroundNodeName) as? SKSpriteNode {
				background.position = CGPointZero
				background.size = newSize
			}

			// Adjust the position (without scaling) of the remaining nodes
			let transform = CGAffineTransformMakeScale(newSize.width/oldSize.width, newSize.height/oldSize.height)
			enumerateChildNodesWithName("*") { (node,stop) in
				// Note: logically, the background node should be excluded from this repositioning transformation.
				//		 But the anchor point and origin of the background is always {0,0}, so it doesn't matter
				//		 how it's scaled, it's still going to be at {0,0}
				node.position = CGPointApplyAffineTransform(node.position, transform)
				}
		}
	}

}