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

    var colorModel: Color? {
        willSet(newModel) {
            // Whenever the data model for this color view is set or changed, stop observing the previous
            //  model (if any), and start observing the new model (if any).
            if newModel !== colorModel {
                if let previousModel = colorModel {
                    previousModel.removeObserver(self, forKeyPath: "color")
                }
                newModel?.addObserver(self, forKeyPath: "color", options: .allZeros, context: nil)
            }
        }
    }

	var brightness: Float = 0
	var hsImage: UIImage?
    
    deinit {
        colorModel = nil    // stop observing the data model, while we still can
    }

	// MARK: Drawing

	override func drawRect(rect: CGRect) {
        if let color = colorModel {
            let bounds = self.bounds
            if hsImage != nil && ( brightness != color.brightness || bounds.size != hsImage!.size ) {
                // Something is different than what's in the cached hsImage.
                // Discard the image, which will cause the next block of code to create a new one.
                hsImage = nil
                }
            
            if hsImage == nil {
                // Create a hue/saturation field with the current brightness in an off-screen image buffer
                brightness = color.brightness		// remember the brightness of hsImage
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
            
            hsImage!.drawInRect(bounds)
            
            let circleRect = CGRect(x: bounds.maxX*CGFloat(color.hue/360)-radius,
                                    y: bounds.maxY*CGFloat(color.saturation/100)-radius,
                                width: radius*2.0,
                               height: radius*2.0)
            let circle = UIBezierPath(ovalInRect: circleRect)
            color.color.setFill()
            circle.fill()
            circle.lineWidth = 3.0
            UIColor.blackColor().setStroke()
            circle.stroke()
        }
        /* else {
            there is no colorModel, don't draw anything
        } */
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

    // MARK: Key-Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if keyPath == "color" {
            // Note: we don't really need to test the keyPath, as "color" is the only observed property
            setNeedsDisplay()
        }
    }

}
