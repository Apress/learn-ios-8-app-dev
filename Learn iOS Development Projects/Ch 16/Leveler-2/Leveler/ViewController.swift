//
//  ViewController.swift
//  Leveler
//
//  Created by James Bucanek on 7/23/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

	let handImageName = "hand"

	@IBOutlet var angleLabel: UILabel!
	var dialView: DialView!
	var needleView: UIImageView!

	lazy var motionManager = CMMotionManager()
	let accelerometerPollingInterval: NSTimeInterval = 1.0/15.0			// 15 times a second

	var animator: UIDynamicAnimator!
	let springAnchorDistance: CGFloat = 4.0
	let springDamping: CGFloat = 0.7
	let springFrequency: CGFloat = 0.5
	var springBehavior: UIAttachmentBehavior?

	// MARK: View Management

	override func viewDidLoad() {
		super.viewDidLoad()

		// Programmatically create the dial and needle image views
		dialView = DialView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
		view.addSubview(dialView)
		needleView = UIImageView(image: UIImage(named: handImageName))
		needleView.contentMode = .ScaleAspectFit
		view.insertSubview(needleView, aboveSubview: dialView)

		adaptInterface()
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)

		// Position the dial views the first time this interface is displayed
		positionDialViews()
		attachDialBehaviors()

		// Configure the motion manager to report accelerometer changes
		motionManager.accelerometerUpdateInterval = accelerometerPollingInterval
		// Tell the motion manager to begin collecting accelerometer data
		motionManager.startAccelerometerUpdates()
		// Start a timer to periodically poll the accelerometer
		NSTimer.scheduledTimerWithTimeInterval( accelerometerPollingInterval,
										target: self,
									  selector: "updateAccelerometerTime:",
									  userInfo: nil,
									   repeats: true)
	}

	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
		// The view controller is being resize or rotated.
		// Animate the dial views so they move seamlessly to their new position.
		// Note: this works because positionDialViews() only sets animatable properties of
		//		 dialView and needleView, specifically the transform, frame, and center.
		animator?.removeAllBehaviors()
		coordinator.animateAlongsideTransition( { (context) in self.positionDialViews() },
									completion: { (context) in self.attachDialBehaviors() })
	}

	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.All.rawValue)
	}

	func adaptInterface() {
		if let label = angleLabel {
			var fontSize: CGFloat = 90.0	// big font for iPads and such
			if traitCollection.horizontalSizeClass == .Compact {
				// For compact displays, reduce the size of the label's font from 90.0 to 60.0 pt
				fontSize = 60.0
			}
			label.font = UIFont.systemFontOfSize(fontSize)
		}
	}

	func positionDialViews() {
		// Position the dial so its center is at the center of
		//	the bottom edge of the view, and its top edge is
		//  below the angle label.
		let viewBounds = view.bounds
		let labelFrame = angleLabel.frame
		let topEdge = ceil(labelFrame.maxY+labelFrame.height/3.0)
		// The dialView height/width is twice the size that appears in the view
		//  becuase half of it is always below screen.
		let dialRadius = viewBounds.maxY-topEdge
		let dialHeight = dialRadius*2.0
		// (Remember that the transform property MUST be set back to the identity transform
		//	before making changes to the frame property)
		dialView.transform = CGAffineTransformIdentity
		dialView.frame = CGRect(x: 0.0, y: 0.0, width: dialHeight, height: dialHeight)
		dialView.center = CGPoint(x: viewBounds.midX, y: viewBounds.maxY)
		dialView.setNeedsDisplay()

		// Scale the needle so it's the same height as the dial and
		//	position it at the bottom, horizontally centered.
        if let needleSize = needleView.image?.size {
            let needleScale = dialRadius/needleSize.height
            var needleFrame = CGRect(x: 0.0,
                y: 0.0,
                width: needleSize.width*needleScale,
                height: needleSize.height*needleScale)
            needleFrame.origin.x = viewBounds.midX-needleFrame.width/2.0
            needleFrame.origin.y = viewBounds.maxY-needleFrame.height
            needleView.frame = CGRectIntegral(needleFrame)
        }
	}

	func attachDialBehaviors() {
		// Lazily create or reset the dynamic animator
		if animator != nil {
			animator.removeAllBehaviors()
		} else {
			animator = UIDynamicAnimator(referenceView: view)
		}

		// Create two attachment behaviors
		// (1) Pin the center of the dial at its current center, preventing it from moving
		let dialCenter = dialView.center
		let pinBehavior = UIAttachmentBehavior(item: dialView, attachedToAnchor: dialCenter)
		animator.addBehavior(pinBehavior)
		// (2) Create a "springy" attachment at the top-center point of the view
		let dialRect = dialView.frame
		let topCenter = CGPoint(x: dialRect.midX, y: dialRect.minY)
		let topOffset = UIOffset(horizontal: 0.0, vertical: topCenter.y-dialCenter.y)
		springBehavior = UIAttachmentBehavior(item: dialView,
								  offsetFromCenter: topOffset,
								  attachedToAnchor: topCenter)
		springBehavior!.damping = springDamping
		springBehavior!.frequency = springFrequency
		animator.addBehavior(springBehavior)

		// Extra credit: add some resistence to the dial
		let drag = UIDynamicItemBehavior(items: [dialView])!
		drag.angularResistance = 2.0
		animator.addBehavior(drag)
	}

	// MARK: Periodic Motion Updates

	func updateAccelerometerTime(timer: NSTimer) {
		if let data = motionManager.accelerometerData {
			let acceleration = data.acceleration
			let rotation = atan2(-acceleration.x,-acceleration.y)
			rotateDialView(rotation)
		}
	}
	
	func rotateDialView(rotation: Double) {
		// Rotate the dial by the angle of "up"
		if let spring = springBehavior {
			// Calculate the distance of the spring attachment point from the center of dialView
			let center = dialView.center
			let radius = dialView.frame.height/2.0 + springAnchorDistance
			// Combine with rotation to find the new attachment point
			let anchorPoint = CGPoint(x: center.x+CGFloat(sin(rotation))*radius,
									  y: center.y-CGFloat(cos(rotation))*radius )
			// Move the attachment point; the dynamic animator will do the rest
			spring.anchorPoint = anchorPoint
		}

		// Update the label
		// Convert radians to degrees, then fix the range so it's always positive
		var degrees = Int(round(-rotation*180.0/M_PI))
		if degrees < 0 {
			degrees += 360
		}
		angleLabel.text = "\(degrees)°"
	}

}

