//
//  ViewController.swift
//  Shapely
//
//  Created by James Bucanek on 7/18/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	let colors = [ UIColor.redColor(), UIColor.greenColor(),
		UIColor.blueColor(), UIColor.yellowColor(),
		UIColor.purpleColor(), UIColor.orangeColor(),
		UIColor.grayColor(), UIColor.whiteColor() ]

	@IBAction func addShape(sender: AnyObject!) {
		if let button = sender as? UIButton {
            if let shapeSelector = ShapeSelector(rawValue: button.tag) {
				let shapeView = ShapeView(shape: shapeSelector)
				shapeView.color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
				view.addSubview(shapeView)

				// Pick a random position for the new shape
				var shapeFrame = shapeView.frame
				let safeRect = CGRectInset(view.bounds, shapeFrame.width, shapeFrame.height)
				var randomCenter = safeRect.origin
				randomCenter.x += CGFloat(arc4random_uniform(UInt32(safeRect.width)))
				randomCenter.y += CGFloat(arc4random_uniform(UInt32(safeRect.height)))
				// Animate the position change so the shape appears to "spring" from the button
				shapeView.center = button.center
				shapeView.transform = CGAffineTransformMakeScale(0.4, 0.4)
				UIView.animateWithDuration(0.5) {
					shapeView.center = randomCenter
					shapeView.transform = CGAffineTransformIdentity
				}

				let pan = UIPanGestureRecognizer(target: self, action: "moveShape:")
				pan.maximumNumberOfTouches = 1
				shapeView.addGestureRecognizer(pan)

				let pinch = UIPinchGestureRecognizer(target: self, action: "resizeShape:")
				shapeView.addGestureRecognizer(pinch)

				let dblTap = UITapGestureRecognizer(target: self, action: "changeColor:")
				dblTap.numberOfTapsRequired = 2
				shapeView.addGestureRecognizer(dblTap)

				let trplTap = UITapGestureRecognizer(target: self, action: "sendShapeToBack:")
				trplTap.numberOfTapsRequired = 3
				shapeView.addGestureRecognizer(trplTap)

				dblTap.requireGestureRecognizerToFail(trplTap)
			}
		}
	}

	func moveShape(gesture: UIPanGestureRecognizer) {
		if let shapeView = gesture.view as? ShapeView {
			let dragDelta = gesture.translationInView(shapeView.superview!)
			switch gesture.state {
			case .Began, .Changed:
				shapeView.transform = CGAffineTransformMakeTranslation(dragDelta.x, dragDelta.y)
			case .Ended:
				shapeView.transform = CGAffineTransformIdentity
				shapeView.frame = CGRectOffset(shapeView.frame, dragDelta.x, dragDelta.y)
				corralShape(shapeView)
			default:
				shapeView.transform = CGAffineTransformIdentity
			}
		}
	}

	func resizeShape(gesture: UIPinchGestureRecognizer) {
		if let shapeView = gesture.view as? ShapeView {
			let pinchScale = gesture.scale
			switch gesture.state {
			case .Began, .Changed:
				shapeView.transform = CGAffineTransformMakeScale(pinchScale, pinchScale)
			case .Ended:
				shapeView.transform = CGAffineTransformIdentity
				var frame = shapeView.frame
				let xDelta = frame.width*pinchScale-frame.width
				let yDelta = frame.height*pinchScale-frame.height
				frame.size.width += xDelta
				frame.size.height += yDelta
				frame.origin.x -= xDelta/2
				frame.origin.y -= yDelta/2
				shapeView.frame = frame
				shapeView.setNeedsDisplay()
				corralShape(shapeView)
			default:
				shapeView.transform = CGAffineTransformIdentity

			}
		}
	}

	func changeColor(gesture: UITapGestureRecognizer) {
		if gesture.state == .Ended {
			if let shapeView = gesture.view as? ShapeView {
				let currentColor = shapeView.color
				var newColor: UIColor!
				do {
					newColor = colors[Int(arc4random_uniform(UInt32(colors.count)))]
				} while currentColor == newColor
				shapeView.color = newColor
			}
		}
	}

	func sendShapeToBack(gesture: UITapGestureRecognizer) {
		if gesture.state == .Ended {
			view.sendSubviewToBack(gesture.view!)
		}
	}

	func corralShape(shapeView: ShapeView) {
		// Keep the shape on the screen

		// Create a rect that defines the area shapes should be kept inside.
		// That method assumes that
		//  (a) the shape creation buttons are at the top of the view
		//  (b) the origin of the view is (0,0)
		//  (c) the root view contains shapeView
		//  (all pretty safe bets, but it doesn't hurt to document them)

		// Get the bounds of the superview and the current frame of the shape
		//  (which are both in the coordiante system of the superview)
		var corralRect = view.bounds
		var shapeFrame = shapeView.frame
		// Move the top edge down so it's below the bottom edge of the
		//  first button
		if let anyNewShapeButton = view.viewWithTag(ShapeSelector.Square.rawValue) {
			let buttonBottom = anyNewShapeButton.frame.maxY
			var buttonArea = CGRect()	// (not used, just needed because |slice| param can't be nil)
			CGRectDivide(corralRect,&buttonArea,&corralRect,buttonBottom,.MinYEdge)
		}

		// See if the shape view is already inside the allowed area
		if !CGRectContainsRect(corralRect,shapeFrame) {
			// The shapeFrame is not completely contained in corralRect, which
			//  means that some portion of it has been moved outside the edge
			//  of the screen, or it's too big, or both.

			// Calculate a new frame for the view that keeps it on the screen

			// Step one: resize the shape so it fits in the allowed area
			if shapeFrame.width>corralRect.width || shapeFrame.height>corralRect.height {
				// Either the heigth or width of the shape is bigger than allowed.
				// Calculate a resizing factor that will shrink it to fit.
				// This statement calculates scaling factors that, when multiplied
				//  with the shape's size, will scale it down so it's not larger
				//  then correlRect.
				// Hint: The min function chooses the smaller of its two parameters.
				let scale = min(min(corralRect.width/shapeFrame.width,1.0),
					min(corralRect.height/shapeFrame.height,1.0))
				// Based on the scaling factor, calculate the fraction of the view that
				//  will be trimmed off its height & width. Use this in the inset function.
				// (This makes the rect proportionally smaller without changing its center.)
				let trimFraction = (1.0-scale)/2.0
				shapeFrame = CGRectInset(shapeFrame,shapeFrame.size.width*trimFraction,
					shapeFrame.size.height*trimFraction)
			}

			// Step two: move the shape so it's inside the allowed area
			// Note: shapeRect can't, by definition, be larger than corralRect at
			//       this point, so the shape can be either above or below the area,
			//       but not both, and it could be to the left or right the area,
			//       but not both.
			var deltaX: CGFloat = 0.0
			var deltaY: CGFloat = 0.0
			if shapeFrame.minX < corralRect.minX {
				deltaX = corralRect.minX-shapeFrame.minX
			} else if shapeFrame.maxX > corralRect.maxX {
				deltaX = corralRect.maxX-shapeFrame.maxX
			}
			if shapeFrame.minY < corralRect.minY {
				deltaY = corralRect.minY-shapeFrame.minY
			} else if shapeFrame.maxY > corralRect.maxY {
				deltaY = corralRect.maxY-shapeFrame.maxY
			}
			shapeFrame.offset(dx: deltaX, dy: deltaY)

			// Last step: Animation the shape from where the user dropped it
			//  to where it ought to be.
			UIView.animateWithDuration(0.4) {
				shapeView.frame = shapeFrame
			}
		}

	}

}

