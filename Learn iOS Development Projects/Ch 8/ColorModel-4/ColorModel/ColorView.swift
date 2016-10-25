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

	var brightness: Float = 0
	var hsImage: UIImage?

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

}
