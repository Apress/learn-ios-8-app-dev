//
//  ShapeView.swift
//  Shapely
//
//  Created by James Bucanek on 7/18/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


enum ShapeSelector: Int {
	case Square = 1
	case Rectangle
	case Circle
	case Oval
	case Triangle
	case Star
}

class ShapeView: UIView {

	let shape: ShapeSelector
	let initialSize = CGSize(width: 100.0, height: 100.0)
	let alternateHeight = CGFloat(100.0/2)
	let strokeWidth = CGFloat(8.0)

	var color: UIColor = UIColor.whiteColor() {
		didSet {
			setNeedsDisplay()
		}
	}
	
	var path: UIBezierPath {
		// Calculate the rect that will contain the points of the Bezier curve.
		// In Core Graphics, the "ink" of the line draws on either side of the
		//	logical line of the curve. So the actual pixels drawn will extend
		//	1/2 the width of the lineWidth on either side.
		var rect = bounds
		rect.inset(dx: strokeWidth/2.0, dy: strokeWidth/2.0)

		// Based on the shape selector, create the bezier path that will draw that
		//	shape inside |rect| and store it in |shapePath|.
		var shapePath: UIBezierPath!
		switch shape {
			case .Square, .Rectangle:
				// The only difference between a square and a rectangle is the
				//	aspect ratio of the view, which is set by bounds.
				shapePath = UIBezierPath(rect: rect)
			case .Circle, .Oval:
				// The only difference between a circle and an oval is the
				//	aspect ratio of the view, which is set by bounds.
				shapePath = UIBezierPath(ovalInRect: rect)
			case .Triangle:
				// Create a bezier path from the center top of the view, to
				//	the lower right corner, and then the lower left corner.
				// Note: This is not an equilateral triangle. If you wanted
				//		 that, you'd have to shorten the height so it was
				//		 sqrt(3)/2 the length of the base, and then you'd
				//		 probably want to vertically center the points.
				shapePath = UIBezierPath()
				shapePath.moveToPoint(CGPoint(x: rect.midX, y: rect.minY))
				shapePath.addLineToPoint(CGPoint(x: rect.maxX, y: rect.maxY))
				shapePath.addLineToPoint(CGPoint(x: rect.minX, y: rect.maxY))
				shapePath.closePath()
			case .Star:
				// Create a star shaped path. Begin at the "top" with a point
				//	centered at the top of the view. Using a loop, calculate
				//	the next ten points of the star.
				// Note: Remember that the origin (0,0) of the Core Graphics coordinate
				//		 system is in the upper left corner. This means the Y
				//		 axis is inverted from the Cartesian coordinates used
				//		 by trigonometric functions. So angles that increase (+)
				//		 are moving clockwise in Core Graphics coordinates
				//		 (rather than counter-clockwise, in Cartesian coordinates).
				shapePath = UIBezierPath()
				let armRotation = CGFloat(M_PI)*2.0/5.0		// 72° or 1/5 of a circle
				var angle = armRotation
				let distance = rect.width*0.38
				// Note: This "magic number" (0.38) is the approximate ratio of the
				//		 length of a single line segment in a golden star to its width.
				//		 Go ahead, do the math, I'll wait.
				var point = CGPoint(x: rect.midX, y: rect.minY)
				shapePath.moveToPoint(point)
				for _ in 1...5 {
					// Calculate the next inner point from the coordinates
					//	of the last outer point (peak) of the star.
					//	|angle| contains the direction from the last point
					//	to the next inner point. Move the point along
					//	that angle for the given distance.
					point.x += CGFloat(cos(Double(angle)))*distance
					point.y += CGFloat(sin(Double(angle)))*distance
					// Add the line segment to this inner point to the path.
					shapePath.addLineToPoint(point)
					// Rotate the direction of travel -72°. The direction is
					//	now pointed towards the next outer point.
					angle -= armRotation
					// Move to the next outer point and add a line segment.
					point.x += CGFloat(cos(Double(angle)))*distance
					point.y += CGFloat(sin(Double(angle)))*distance
					shapePath.addLineToPoint(point)
					// Rotate the angle of travel +144°. The angle is now
					//	pointed towards the next inner point.
					angle += armRotation*2
					// Loop around, adding the next two points.
				}
				// Close the path, connecting the last point to the first point.
				// For line shapes like the star, this is only important because it
				//	turns the first and last points into a  "joint" instead of two
				//	line "caps". This affects how the stroke is drawn around that point.
				shapePath.closePath()
		}
		// Set the common path properties
		shapePath.lineWidth = strokeWidth
		shapePath.lineJoinStyle = kCGLineJoinRound
		return shapePath
	}

	init(shape: ShapeSelector, origin: CGPoint = CGPointZero) {
		// Assign the (immutable) shape selector first
		self.shape = shape

		// Calculate the initial frame of the view
		var frame = CGRect(origin: origin, size: initialSize)
		if shape == .Rectangle || shape == .Oval {
			frame.size.height = alternateHeight
		}

		// Initialize the UIView superclass with the frame
		super.init(frame: frame)

		// Set the UIView properties appropriate for this view
		opaque = false
		backgroundColor = nil
		clearsContextBeforeDrawing = true
	}

	required init(coder decoder: NSCoder) {
		shape = .Square
		//shape = ( ShapeSelector.fromRaw(decoder.decodeIntegerForKey("shape")) ?? .Square )
		super.init(coder: decoder)
	}

	override func drawRect(rect: CGRect) {
		let shapePath = path
		UIColor.blackColor().colorWithAlphaComponent(0.4).setFill()
		shapePath.fill()
		color.setStroke()
		shapePath.stroke()
	}

}
