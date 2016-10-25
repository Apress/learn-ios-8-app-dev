//
//  Color.swift
//  ColorModel
//
//  Created by James Bucanek on 9/14/14.
//  Copyright (c) 2014 James Bucanek. All rights reserved.
//

import UIKit

class Color: NSObject {
    
    dynamic var hue: Float = 0.0            // Hue angle (degress, 0..360)
    dynamic var saturation: Float = 0.0		// Saturation (percent, 0..100)
    dynamic var brightness: Float = 0.0		// Brightness (percent, 0..100)
    
    var color: UIColor {
        // Returns a UIColor object equivelent to this color
        return UIColor(hue: CGFloat(hue/360),
                saturation: CGFloat(saturation/100),
                brightness: CGFloat(brightness/100),
                     alpha: 1.0)
    }
    
    class func keyPathsForValuesAffectingColor() -> NSSet {
        return NSSet(array: ["hue", "saturation", "brightness"])
    }
    
}
