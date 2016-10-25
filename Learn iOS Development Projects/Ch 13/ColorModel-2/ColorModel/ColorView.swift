//
//  ColorView.swift
//  ColorModel
//
//  Created by James Bucanek on 7/6/14.
//  Copyright (c) 2014 James Bucanek. All rights reserved.
//

import UIKit


class ColorView : UIView {

	let radius: CGFloat = 20.0				// radius of "loupe"

	var colorModel: Color?

	var hsImage: UIImage?
    var brightness: Float = 0

	// MARK: Drawing
    
	override func drawRect(rect: CGRect) {
        drawColorChoice(bounds: self.bounds)
	}

    func colorChoiceImage(# size: CGSize) -> UIImage {
        // Draw the color choice into an off-screen graphics context and return it as a new UIImage.
        // |size| is the overall size of the new image. The h/s color field is
        //  inset by the radius of the "loupe" so the loupe is never clipped.
        
        // Create an off-screen graphics context (plain, nothing special)
        UIGraphicsBeginImageContext(size)
        // Get a reference to the new context
        let context = UIGraphicsGetCurrentContext()
        // Define a rectangle the exact size of the context
        var bounds = CGRect(origin: CGPointZero, size: size)
        // Fill the context with transparent pixels
        UIColor.clearColor().set()
        CGContextFillRect(context, bounds)
        // Draw the h/s field and the loupe, inset by the radius of the loupe
        bounds.inset(dx: radius, dy: radius)
        drawColorChoice(bounds: bounds)
        // Convert the off-screen context into an image object
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // Cleanup
        UIGraphicsEndImageContext()
        return image
    }

    func drawColorChoice(# bounds: CGRect) {
        if let color = colorModel {
            // Get the h/s field image and draw it
            let image = hsImage(size: bounds.size, brightness: color.brightness)
            image.drawInRect(bounds)
            // Define a circle path centered at the current hue and saturation
            // This is the "loupe"
            let circleRect = CGRect(x: bounds.minX+bounds.width*CGFloat(color.hue/360)-radius,
                                    y: bounds.minY+bounds.height*CGFloat(color.saturation/100)-radius,
                                width: radius*2.0,
                               height: radius*2.0)
            let circle = UIBezierPath(ovalInRect: circleRect)
            // Fill the loupe with the current color
            color.color.setFill()
            circle.fill()
            // Draw a 3 point thick circle around the color, in black
            circle.lineWidth = 3.0
            UIColor.blackColor().setStroke()
            circle.stroke()
        }
        /* else {
        there is no colorModel, don't draw anything
        } */
    }
    
    func hsImage(# size: CGSize, brightness: Float) -> UIImage {
        if hsImage != nil && ( brightness != self.brightness || size != hsImage!.size ) {
            // Something is different than what's in the cached hsImage.
            // Discard the image, which will cause the next block of code to create a new one.
            hsImage = nil
        }
        
        if hsImage == nil {
            // Create a hue/saturation field with the current brightness in an off-screen image buffer
            self.brightness = brightness		// remember the brightness of hsImage
            UIGraphicsBeginImageContextWithOptions(bounds.size, true/*opaque*/, 1.0)
            let imageContext = UIGraphicsGetCurrentContext()
            for y in 0..<Int(bounds.height) {
                for x in 0..<Int(bounds.width) {
                    // Create the color with the H+S+B for the given pixel
                    let uiColor = UIColor(hue: CGFloat(x)/bounds.width,
                                   saturation: CGFloat(y)/bounds.height,
                                   brightness: CGFloat(brightness/100.0),
                                        alpha: 1.0)
                    // Fill one point with the computed color
                    uiColor.set()
                    CGContextFillRect(imageContext,CGRect(x: x, y: y, width: 1, height: 1))
                }
            }
            hsImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return hsImage!
    }

	// MARK: Touch events

	override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
		changeColorTo(touch: touches.anyObject() as? UITouch)
	}

	override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
		changeColorTo(touch: touches.anyObject() as? UITouch)
	}

	override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
		changeColorTo(touch: touches.anyObject() as? UITouch)
	}

	func changeColorTo(# touch: UITouch? ) {
		if let contact = touch {
			changeColorTo(point: contact.locationInView(self))
		}
	}

	func changeColorTo(# point: CGPoint ) {
		// Change the color model to the color displayed at the given view coordinate
        if let color = colorModel {
			let bounds = self.bounds
			if bounds.contains(point) {
				color.hue = Float((point.x-bounds.minX)/bounds.width*360)
				color.saturation = Float((point.y-bounds.minY)/bounds.height*100)
			}
		}
	}

}
