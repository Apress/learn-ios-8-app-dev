//
//  ViewController.swift
//  EightBall
//
//  Created by James Bucanek on 7/16/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
	@IBOutlet var answerView: UITextView!

	let answers = [ "\rYES", "\rNO", "\rMAYBE",
					"I\rDON'T\rKNOW", "TRY\rAGAIN\rSOON", "READ\rTHE\rMANUAL" ]

	override func viewDidAppear(animated: Bool) {
		UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
		NSNotificationCenter.defaultCenter().addObserver( self,
			selector: "orientationChanged:",
			name: UIDeviceOrientationDidChangeNotification,
			object: nil)
	}

	override func viewDidDisappear(animated: Bool) {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
	}

	// Magic fortune

	func fadeFortune() {
		// Fade out (alpha 1 -> 0) over the next 3/4 seconds
		UIView.animateWithDuration(0.75) {
			self.answerView.alpha = 0.0
		}
//		(this is the same code, but using a slightly different Swift syntax)
//		UIView.animateWithDuration( 0.75, animations: { () in
//			self.answerView.alpha = 0.0
//			})
	}

	func newFortune() {
		let randomIndex = Int(arc4random_uniform(UInt32(answers.count)))
		answerView.text = answers[randomIndex];
		answerView.layoutSubviews()

		// Fade in (alpha 0 -> 1) slowly over the next two seconds
		UIView.animateWithDuration(2.0) {
			self.answerView.alpha = 1.0
		}
	}

	// Orientation changes

	func orientationChanged( notification: NSNotification? ) {
		if UIDevice.currentDevice().orientation == .FaceUp {
			newFortune()
		}
		else {
			fadeFortune()
		}
	}
}

