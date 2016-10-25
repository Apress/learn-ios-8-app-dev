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
                let shapeView = ShapeFactory().load(shape: shapeSelector, inViewController: self)
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
			}
		}
	}

	@IBAction func moveShape(gesture: UIPanGestureRecognizer) {
		if let shapeView = gesture.view as? ShapeView {
			let dragDelta = gesture.translationInView(shapeView.superview!)
			switch gesture.state {
				case .Began, .Changed:
					shapeView.transform = CGAffineTransformMakeTranslation(dragDelta.x, dragDelta.y)
				case .Ended:
					shapeView.transform = CGAffineTransformIdentity
					shapeView.frame = CGRectOffset(shapeView.frame, dragDelta.x, dragDelta.y)
				default:
					shapeView.transform = CGAffineTransformIdentity
			}
		}
	}

	@IBAction func resizeShape(gesture: UIPinchGestureRecognizer) {
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
				default:
					shapeView.transform = CGAffineTransformIdentity

			}
		}
	}

	@IBAction func changeColor(gesture: UITapGestureRecognizer) {
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

	@IBAction func sendShapeToBack(gesture: UITapGestureRecognizer) {
		if gesture.state == .Ended {
			view.sendSubviewToBack(gesture.view!)
		}
	}

}

