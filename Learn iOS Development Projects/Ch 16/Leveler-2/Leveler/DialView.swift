//
//  DialView.swift
//  Leveler
//
//  Created by James Bucanek on 7/22/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class DialView: UIView {

	// MARK: Constants
    
	let innerDialInset: CGFloat = (10.0/100.0)				// 10% inset (diameter)
	let dialColor = UIColor(hue: 208.0/360.0,				// 280° hue
					 saturation: 44.0/100.0,				// 44% saturatino
					 brightness: 90.0/100.0,				// 90% brightness
						  alpha: 50.0/100.0)				// 50% transparent

	let quadrantTickInset: CGFloat =		8.0/100.0		// 8% inset (radius)
	let quadrantFontSizeRatio: CGFloat =	72.0/670.0		// 72pt @ 670px
	let majorTickInset: CGFloat	=			5.0/100.0		// 5%
	let majorFontSizeRatio: CGFloat =		48.0/670.0		// 48pt @ 670px
	let minorTickInset: CGFloat =			2.5/100.0		// 2.5%
	let tickWidth: CGFloat =				4.0				// 2px width ticks
	let tickColor =							UIColor.whiteColor()

	let circleDegrees = 360
	let quadrantTickDegrees = 90	// 0       90         180  ...
	let majorTickDegrees = 30		//   30 60    120 150      ...
	let minorTickDegrees = 3		// ||||||||||||||||||||||| ...

	// MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        clearsContextBeforeDrawing = true
        opaque = false
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }

	// MARK: Drawing

	override func drawRect(rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()
		let bounds = self.bounds
		let radius = bounds.height/2.0

		//
		// Draw the "dial"
		//

		CGContextSaveGState(context)
		// Create a "doughnut" by filling a larger circle, and then filling
		//	an inset circle with transparent pixels.
		var dial = UIBezierPath(ovalInRect: bounds)
		// Fill the whole circle
		dialColor.setFill()
		dial.fill()
		// Erase the inner circle
		let innerBounds = CGRectInset(bounds, radius*innerDialInset, radius*innerDialInset)
		dial = UIBezierPath(ovalInRect: innerBounds)
		UIColor.clearColor().setFill()
		CGContextSetBlendMode(context, kCGBlendModeCopy)
		dial.fill()
		CGContextRestoreGState(context)

		//
		// Draw the ticks and labels around the dial
		//

		// Before the loop begins, offset all of the drawing by (radius,radius) so the
		//	logical origin (0,0) of the drawing context is now in the center of the view.
		CGContextTranslateCTM(context,radius,radius)
		// Note that the logical origin (0,0) of the context is now in the center
		//	of the view, so to draw a downward tick at the top center of the
		//	view, the coordinates are (0,-radius) to (0,-radius+tickHeight)
		let topCenter = CGPoint(x: 0.0, y: -radius)

		// Precalculate the transform matrix used to rotate the context
		let tickAngle = CGFloat(minorTickDegrees)*CGFloat(M_PI/180.0)
		let rotation = CGAffineTransformMakeRotation(tickAngle)

		tickColor.set()									// color for both stroke and text
		CGContextSetLineWidth(context,tickWidth)		// width of tick lines
		// Note: Use integer math for the angle loop to avoid rounding inaccuracies
		//		 inherent when using floating point numbers
		for var angle = 0; angle < circleDegrees; angle += minorTickDegrees {
			var tickLength: CGFloat = 0.0
			var labelSize: CGFloat?
			if angle%quadrantTickDegrees == 0 {
				// This is a quadrant tick
				tickLength = ceil(bounds.height*quadrantTickInset)
				labelSize = ceil(bounds.height*quadrantFontSizeRatio)
			} else if angle%majorTickDegrees == 0 {
				// This is a major tick
				tickLength = ceil(bounds.height*majorTickInset)
				labelSize = ceil(bounds.height*majorFontSizeRatio)
			} else {
				// This is a minor tick
				tickLength = ceil(bounds.height*minorTickInset)
			}

			// Draw the tick using the CGContextStrokeLineSegments() function
			let points: [CGPoint] = [ topCenter, CGPoint(x: topCenter.x, y: topCenter.y+tickLength) ]
			CGContextStrokeLineSegments(context,points,2);

			if let size = labelSize {
				// Use the endpoint of the tick (in points[1]) to position the text
				//	centered immediately below it.
				let labelText = "\(angle)"
				let labelAttrs = [ NSFontAttributeName: UIFont.systemFontOfSize(size),
								   NSForegroundColorAttributeName: tickColor ];
				let textSize = labelText.sizeWithAttributes(labelAttrs)
				var textOrigin = points[1]					// top of label is at end point of tick
				textOrigin.x -= floor(textSize.width/2.0)	// center label by moving it left width/2.0
				labelText.drawAtPoint(textOrigin, withAttributes:labelAttrs)
			}

			// Rotate the drawing coordinate system by minorTickDegrees. The next line/label drawn will
			//	be rotated (around the origin, which is now in the center) by this angle. Each time
			//	through the loop another rotation transform is applied, causing the ticks and
			//	labels to draw in a circle.
			CGContextConcatCTM(context,rotation);
		}
	}
}
