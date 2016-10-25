//
//  OnePageView.swift
//  Wonderland
//
//  Created by James Bucanek on 9/2/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class OnePageView: UIView {

	var text: NSString = "" { didSet { setNeedsDisplay() } }
	var fontAttrs: [String: AnyObject]! = nil

	override func drawRect(rect: CGRect) {
		super.drawRect(rect)
		text.drawInRect(bounds, withAttributes: fontAttrs)
	}
}
