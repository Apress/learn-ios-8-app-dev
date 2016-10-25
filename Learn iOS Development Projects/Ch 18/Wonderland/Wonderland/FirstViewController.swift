//
//  FirstViewController.swift
//  Wonderland
//
//  Created by James Bucanek on 9/6/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController, UIAdaptivePresentationControllerDelegate/*presentation*/ {
                            
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
		if segue.identifier == "info" {
			// Make this object the presentation controller's delegate
            let presented = segue.destinationViewController as UIViewController
			let presentationController = presented.presentationController /*presentation*/
			presentationController?.delegate = self
		} else {
			super.prepareForSegue(segue, sender: sender)
		}
	}

	func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
//		return .None
		return .FullScreen
	}

	func presentationController(controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
		// This UIAdaptivePresentationControllerDelegate function is called whenever the presentation
		//	controller is about to present a non-full-screen view controller in a compact width
		//	environment (like an iPod or iPhone). It offers the delegate to opportunity to replace the
		//	interface with something different.
		let presentedVC = controller.presentedViewController
		let replacementController = UINavigationController(rootViewController: presentedVC)
		let navigationItem = presentedVC.navigationItem
		let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissInfo:")
		navigationItem.rightBarButtonItem = doneButton
		navigationItem.title = "Author"
		return replacementController
	}

	@IBAction func dismissInfo(sender: AnyObject) {
		dismissViewControllerAnimated(true, completion: nil)
	}

}

