//
//  ViewController.swift
//  ColorModel
//
//  Created by James Bucanek on 9/14/14.
//  Copyright (c) 2014 James Bucanek. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var colorModel = Color()
    
    @IBOutlet var colorView: ColorView!
    @IBOutlet var hueLabel: UILabel!
    @IBOutlet var saturationLabel: UILabel!
    @IBOutlet var brightnessLabel: UILabel!
    @IBOutlet var webLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe property changes to our data model
        colorModel.addObserver(self, forKeyPath: "hue",         options: .allZeros, context: nil)
        colorModel.addObserver(self, forKeyPath: "saturation",  options: .allZeros, context: nil)
        colorModel.addObserver(self, forKeyPath: "brightness",  options: .allZeros, context: nil)
        colorModel.addObserver(self, forKeyPath: "color",       options: .allZeros, context: nil)

        // Connect the ColorView to the data model
        colorView.colorModel = colorModel
    }

    @IBAction func changeHue(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.hue = slider.value
        }
    }
    
    @IBAction func changeSaturation(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.saturation = slider.value
        }
    }
    
    @IBAction func changeBrightness(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.brightness = slider.value
        }
    }
    
    // MARK: Key-Value Observing
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        switch keyPath {
            case "hue":
                hueLabel.text = "\(Int(colorModel.hue))°"
//                hueSlider.value = colorModel.hue;
            case "saturation":
                saturationLabel.text = "\(Int(colorModel.saturation))%"
//                saturationSlider.value = colorModel.saturation
            case "brightness":
                brightnessLabel.text = "\(Int(colorModel.brightness))%"
//                brightnessSlider.value = colorModel.brightness
            case "color":
                colorView.setNeedsDisplay()
                var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
                colorModel.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                webLabel.text = NSString(format: "#%02X%02X%02X",CInt(red*255),CInt(green*255),CInt(blue*255))
            default:
                break	/* unknown change; consider adding an assert to ensure this never happens */
        }
    }

}

