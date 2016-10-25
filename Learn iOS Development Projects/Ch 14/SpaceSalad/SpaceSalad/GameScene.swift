//
//  GameScene.swift
//  SpaceSalad
//
//  Created by James Bucanek on 10/10/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import SpriteKit


enum GamePlane: CGFloat {
	case Background = 0
	case Clock
	case Dish
	case Vegetable
	case Beaker
	case Score
}

enum CollisionCategory: UInt32 {
	case Dish =				0b00000001
	case Floaters =			0b00000010
	case Beaker =			0b00000100
	case EverythingElse =	0b00001000
}


func BoundsOfSprite( sprite: SKSpriteNode ) -> CGRect {
	// Return the frame of the sprite, which accounts for all scaling, in the sprite's coordinate system
	// Note: This is a trivial implementation that probably won't work if the spite is rotated.
	var bounds = sprite.frame				// get the current frame, which includes all transforms
	let anchor = sprite.anchorPoint		// position in unit coordinates
	bounds.origin.x = 0.0 - bounds.width*anchor.x
	bounds.origin.y = 0.0 - bounds.height*anchor.y
	return bounds
}


class GameScene: ResizableScene, SKPhysicsContactDelegate {

	override func didMoveToView(view: SKView) {
		// Set up the scene
		
		// Fit the scene inside the new view
		scaleMode = .AspectFill
		size = view.frame.size

		physicsWorld.contactDelegate = self			// scene handles its own contact events
		
		//
		// Add the computed physics boundries to the scene
		//
		
		let backgroundNode = childNodeWithName(backgroundNodeName) as? SKSpriteNode
		
		// If the interface is horizontally constrained (iPhone/iPod), make all of the play elements half sized
		let scale = CGFloat( view.traitCollection.horizontalSizeClass == .Compact ? 0.5 : 1.0 )
		enumerateChildNodesWithName("*") { (node,stop) in
			if node !== backgroundNode {
				node.xScale = scale
				node.yScale = scale
			}
		}

		// Create an edge boundry that encompases the entire scene (i.e. the walls)
		if let background = backgroundNode {
			// use the background's frame to calculate a perimeter edge boundry for the scene
			let body = SKPhysicsBody(edgeLoopFromRect: background.frame)
			body.categoryBitMask = CollisionCategory.EverythingElse.rawValue
			physicsBody = body
		}

		// Add a static edge boundry to the form the sides and bottom of the beaker
		if let beaker = childNodeWithName("beaker") as? SKSpriteNode {
			if beaker.physicsBody == nil {
				// Get the frame of the node and then translate it to the node's local coordinates (equivelent of bounds)
				//				let bounds = beaker.bounds
				let bounds = BoundsOfSprite(beaker)
				// Create a path, in the beaker's local coordinate system, that approximates a cup
				let side = CGFloat(8.0)
				let base = CGFloat(6.0)
				let beakerEdgePath = CGPathCreateMutable()
				CGPathMoveToPoint(beakerEdgePath, nil, bounds.minX, bounds.minY)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.minX, bounds.maxY)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.minX+side, bounds.maxY)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.minX+side, bounds.minY+base)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.maxX-side, bounds.minY+base)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.maxX-side, bounds.maxY)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.maxX, bounds.maxY)
				CGPathAddLineToPoint(beakerEdgePath, nil, bounds.maxX, bounds.minY)
				let body = SKPhysicsBody(edgeLoopFromPath: beakerEdgePath)
				body.categoryBitMask = CollisionCategory.Beaker.rawValue
				beaker.physicsBody = body
			}
		}
		
		// Create a rough approximation of a concave body and attach it to the dish
		if let dish = childNodeWithName("dish") as? SKSpriteNode {
			// Create the physics body on an unscaled dish object (the body will get scaled along with the sprite)
			let scale = dish.xScale
			dish.xScale = 1.0
			dish.yScale = 1.0
			let bounds = BoundsOfSprite(dish)
			let minX = bounds.minX
			let maxX = bounds.maxX
			let midY = bounds.midY
			let minY = bounds.minY
			let width = bounds.width
			let bottomThickness = CGFloat(10.0)
			let curveInterpolationPoints = 4
			let dishEdgePath = CGPathCreateMutable()
			CGPathMoveToPoint(dishEdgePath, nil, minX, minY)
			for p in 0...curveInterpolationPoints {
				let x = minX+CGFloat(p)*width/CGFloat(curveInterpolationPoints)
				let relX = x/(width/2)
				let y = (midY-minY-bottomThickness)*(relX*relX)+minY+bottomThickness
				CGPathAddLineToPoint(dishEdgePath, nil, x, y)
			}
			CGPathAddLineToPoint(dishEdgePath, nil, maxX, minY)
			CGPathCloseSubpath(dishEdgePath)
			let body = SKPhysicsBody(polygonFromPath: dishEdgePath)
			body.usesPreciseCollisionDetection = true
			body.categoryBitMask = CollisionCategory.Dish.rawValue
			body.contactTestBitMask = CollisionCategory.Beaker.rawValue
			dish.physicsBody = body
			dish.xScale = scale
			dish.yScale = scale
		}

		enumerateChildNodesWithName("veg") { (node,stop) in
			func randomForce( # min: CGFloat, # max: CGFloat ) -> CGFloat {
				return CGFloat(arc4random()) * (max-min) / CGFloat(UInt32.max) + min
			}
			if let body = node.physicsBody {
				body.categoryBitMask = CollisionCategory.Floaters.rawValue
				body.linearDamping = 0.01
				body.restitution = 0.1
				body.applyForce(CGVector(dx: randomForce(min: -50.0, max: 50.0),
										 dy: randomForce(min: -40.0, max: 40.0)))
				body.applyAngularImpulse(randomForce(min: -0.01, max: 0.01))
			}
		}
		
		// Sprite Kit applies additional optimizations to improve rendering performance
		view.ignoresSiblingOrder = true
		
		// Game is ready to run
		startGame()
	}
	
	// MARK: Drag handling
	
	let dragProximityMinimum = CGFloat(60.0)		// initial touch points have to be within this distance of the dish sprite
	
	var dragNode: SKSpriteNode?		// handy reference to the dish sprite being dragged (nil == not being dragged)
	var leftDrag: SKNode?			// left drag anchor node and joint
	var leftJoint: SKPhysicsJointSpring?
	var rightDrag: SKNode?			// right drag anchor node and joint
	var rightJoint: SKPhysicsJointSpring?
	
	func dragPoints(dish: SKSpriteNode) -> (leftPoint: CGPoint, rightPoint: CGPoint) {
		// Return the drag points of the dish (left and right) in the scene's coordinate system.
		// This logic assumes that the anchor point of the dish sprite is at its center.
		let dishSize = dish.size
		let width = dishSize.width/dish.xScale
		let rightThumbPoint = dish.convertPoint(CGPoint(x: -width/2, y: 0.0), toNode: self)
		let leftThumbPoint = dish.convertPoint(CGPoint(x: width/2, y: 0.0), toNode: self)
		return (leftThumbPoint,rightThumbPoint)
	}
	
	func attachDragNodes(dish: SKSpriteNode) {
		// Create two (invisible) nodes, positioned at the thumb points of the "dish" node
		//  and attach static physics bodies to them.
		let thumbs = dragPoints(dish)
		func newDragNode( position: CGPoint ) -> SKNode {
			// In debug mode create visible drag nodes, else invisible drag nodes
			var newNode: SKNode = ( debugAids ? SKSpriteNode(color: UIColor.redColor(), size: CGSize(width: 8, height: 8))
				: SKNode() )
			if debugAids {
				newNode.zPosition = GamePlane.Vegetable.rawValue
			}
			newNode.position = position
			let body = SKPhysicsBody(circleOfRadius: 4.0)
			body.dynamic = false
			newNode.physicsBody = body
			addChild(newNode)
			return newNode
		}
		leftDrag = newDragNode(thumbs.leftPoint)
		rightDrag = newDragNode(thumbs.rightPoint)
		
		// Connect the drag nodes to the drag points on the dish
		leftJoint = SKPhysicsJointSpring.jointWithBodyA( dish.physicsBody,
												  bodyB: leftDrag!.physicsBody,
												anchorA: thumbs.leftPoint,
												anchorB: thumbs.leftPoint)
		leftJoint!.damping = 4.0
		leftJoint!.frequency = 20.0
		physicsWorld.addJoint(leftJoint!)
		rightJoint = SKPhysicsJointSpring.jointWithBodyA( dish.physicsBody,
												   bodyB: rightDrag!.physicsBody,
												 anchorA: thumbs.rightPoint,
												 anchorB: thumbs.rightPoint)
		rightJoint!.damping = 3.0
		rightJoint!.frequency = 20.0
		physicsWorld.addJoint(rightJoint!)
	}
	
	func moveDragNodes(# touchPoints: [CGPoint], dish: SKSpriteNode) {
		// Match the touch points to the drag points based on proximity
		assert(touchPoints.count==2,"Expected exactly 2 touch points")
		var leftLoc = touchPoints[0]
		var rightLoc = touchPoints[1]
		let thumbs = dragPoints(dish)
		if hypot(leftLoc.x-thumbs.leftPoint.x,leftLoc.y-thumbs.leftPoint.y) + hypot(rightLoc.x-thumbs.rightPoint.x,rightLoc.y-thumbs.rightPoint.y) >
			hypot(rightLoc.x-thumbs.leftPoint.x,rightLoc.y-thumbs.leftPoint.y) + hypot(leftLoc.x-thumbs.rightPoint.x,leftLoc.y-thumbs.rightPoint.y) {
				// The distance from the first touch to the left anchor point plus the second point to the right anchor point
				//	is greater than it is the other way around. Thus, it's a better fit if the second touch point
				//	is paired with the left anchor point on the dish.
				let swapLoc = rightLoc
				rightLoc = leftLoc
				leftLoc = swapLoc
		}
		// Move the drag nodes: the physics engine will handle the rest
		leftDrag!.position = leftLoc
		rightDrag!.position = rightLoc
	}
	
	func releaseDragNodes() {
		// Stop dragging the dish around by removing the drag nodes and joints
		if let dish = dragNode {
			physicsWorld.removeJoint(rightJoint!)
			physicsWorld.removeJoint(leftJoint!)
			leftDrag!.removeFromParent()
			rightDrag!.removeFromParent()
			rightJoint = nil
			leftJoint = nil
			rightDrag = nil
			leftDrag = nil
			dragNode = nil
		}
	}
	
	// MARK: Touch events
	
	func points(# touches: NSSet, inNode node: SKNode) -> [CGPoint] {
		// Convert a set of touch objects into an array of CGPoints with the locations those touches
		//  in the coordinate system of the given node.
		return (touches.allObjects as [UITouch]).map() { (touch) in touch.locationInNode(node) }
	}
	
	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		// A touch has begun
		// The game is looking for two touches; when it gets that, it creates
		//	two nodes with static physics bodies, and connects them (via spring
		//	joints) to the edges of the lab dish node. These two connections
		//	"drag" the dish around, as they move
		
		// The drag begins when two touch points are present
		if touches.count == 2 && !gameOver {
			if dragNode == nil {
				dragNode = childNodeWithName("dish") as? SKSpriteNode
				if let dish = dragNode {
					let hitRect = dish.frame.rectByInsetting(dx: -dragProximityMinimum, dy: -dragProximityMinimum)
					for point in points(touches: touches, inNode: self) {
						if !hitRect.contains(point) {
							// one of the touch points is not inside the hit rect: cancel the start of the drag and exit
							dragNode = nil;
							return
						}
					}
					// Start dragging the dish around
					attachDragNodes(dish)
					// Set the initial positions of the two drag nodes based on the current touch locations
					moveDragNodes(touchPoints: points(touches: touches, inNode: self), dish: dish)
				}
			}
			
		}
		
	}
	
	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		if touches.count == 2 {
			if let dish = dragNode {
				moveDragNodes(touchPoints: points(touches: touches, inNode: self), dish: dish)
			}
		}
	}
	
	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		// A finger has detached from the interface: stop dragging the dish around
		releaseDragNodes()
	}
	
	override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
		// same as 'ended'
		touchesEnded(touches, withEvent: event)
	}
	
	// MARK: Contacts
	
	func didBeginContact(contact: SKPhysicsContact!) {
		// There's only one contact: the dish touching the beaker
		// See if the vegetables are all inside, and end the game if they are
		let outcome = score()
		if outcome.won {
			endGame(outcome.score)
		}
	}
	
	// MARK: Game Management
	
	let gameDuration = 100.0
	var timeRemaining = 0.0
	var gameOver = false

	func score() -> (score: Int, won: Bool) {
		// Enumerate through the vegetables and determine if they're inside the beaker or not.
		// Return the weighted score for all of the captured vegetables and 'won: true' if all of them have been captured.
		var capturedCount = 0
		var missing = false
		let beakerFrame = childNodeWithName("beaker")!.frame
		enumerateChildNodesWithName("veg") { (node,stop) in
			if beakerFrame.contains(node.position) {
				++capturedCount
			} else {
				missing = true
			}
		}
		// Calculate a score based on the number of captured vegetables.
		// Each veg counts as 60 points + 1 extra point for each full second remaining
		return (capturedCount*(Int(timeRemaining)+60),!missing)
	}
	
	func startGame( ) {
		gameOver = false
		timeRemaining = gameDuration
		
		// Start the "timer" by attaching a repeating action to the label node
		if let label = childNodeWithName("timer") as? SKLabelNode {
			//countdown.text = ""
			let wait = SKAction.waitForDuration(0.1)
			let decrement = SKAction.runBlock({
				self.timeRemaining -= 0.1
				if self.timeRemaining < 0.0 {
					// The game ran out of time: end it with the current score
					label.text = "End"
					self.endGame(self.score().score)
				}
				else {
					label.text = NSString(format: "%.1f", self.timeRemaining)
				}
			})
			let sequence = SKAction.sequence([wait,decrement])
			let forever = SKAction.repeatActionForever(sequence)
			label.runAction(forever)
		}
	}
	
	func endGame( score: Int ) {
		gameOver = true
		
		// Record the score
		recordScore(score)
		
		// Release the dish (if the user is still dragging it)
		releaseDragNodes()
		
		// Stop the "timer"
		childNodeWithName("timer")?.removeAllActions()
		
		// Create a "Score" label
		let score = SKLabelNode(text: "Score: \(score)")
		score.fontName = "Helvetica"
		score.fontColor = SKColor.greenColor()
		score.fontSize = CGFloat( view!.traitCollection.horizontalSizeClass == .Compact ? 54.0 : 120.0 )
		let sceneRect = CGRect(origin: CGPointZero, size: frame.size)
		score.position = CGPoint(x: sceneRect.midX, y: sceneRect.height*0.1)
		score.zPosition = GamePlane.Score.rawValue
		score.xScale = 0.2
		score.yScale = 0.2
		addChild(score)
		
		// Create a sequence of actions that animate the score, pause, and then seque back to the welcome scene
		let push = SKAction.moveToY(sceneRect.height*0.8, duration: 1.0)	// push the score up
		push.timingMode = .EaseOut
		let grow = SKAction.scaleTo(1.0, duration: 1.2)						// zoom from 0.2 to 1.0
		grow.timingMode = .EaseIn
		let appear = SKAction.fadeInWithDuration(0.8)						// fade in
		let drama = SKAction.group([push,grow,appear])						// concurrent set of actions
		let delay = SKAction.waitForDuration(4.5)
		let exit = SKAction.runBlock({
			// Present the "Welcome" scene with a transition
			if let scene = WelcomeScene.unarchiveFromFile("WelcomeScene") as? WelcomeScene {
				let doors = SKTransition.doorsCloseVerticalWithDuration(0.5)
				self.view!.presentScene(scene, transition: doors)
				}
			})
		score.runAction(SKAction.sequence([drama,delay,exit]))
	}
	
	func recordScore( score: Int ) {
		// Keep the last and highest score in the local user defaults collection
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setInteger(score, forKey: GameScoreKey.LatestScore.rawValue)
		if score > GameViewController.highestScore() {
			userDefaults.setInteger(score, forKey: GameScoreKey.HighestScore.rawValue)
		}
	}

}
