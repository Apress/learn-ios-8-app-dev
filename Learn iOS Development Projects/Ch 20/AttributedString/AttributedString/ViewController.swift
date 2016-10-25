//
//  ViewController.swift
//  AttributedString
//
//  Created by James Bucanek on 10/23/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet var label: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()

		// Creating an attributed string piecemeal in a mutable string
		let fancyString = NSMutableAttributedString(string: "iOS ")
		let iOSAttrs = [ NSFontAttributeName:			 UIFont.italicSystemFontOfSize(80),
						 NSForegroundColorAttributeName: UIColor.redColor(),
						 NSKernAttributeName:			 NSNumber(integer: 4) ]
		fancyString.setAttributes(iOSAttrs, range: NSRange(location: 0, length: 3))

		// Creating an immutable attributed string with a uniform set of attributes
		let shadow = NSShadow()
		shadow.shadowOffset = CGSize(width: 5, height: 5)
		shadow.shadowBlurRadius = 3.5
		let appAttrs = [ NSFontAttributeName:			UIFont.boldSystemFontOfSize(78),
						 NSShadowAttributeName:			shadow ]
		let secondString = NSAttributedString(string: "App!", attributes: appAttrs)

		fancyString.appendAttributedString(secondString)
		
		label.attributedText = fancyString
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

