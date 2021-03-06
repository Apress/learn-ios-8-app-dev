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
	@IBOutlet var hueSlider: UISlider!
    @IBOutlet var hueLabel: UILabel!
	@IBOutlet var saturationSlider: UISlider!
    @IBOutlet var saturationLabel: UILabel!
	@IBOutlet var brightnessSlider: UISlider!
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
        
        // Set an initial color value
        colorModel.hue = 60
        colorModel.saturation = 50
        colorModel.brightness = 100
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
                hueSlider.value = colorModel.hue;
            case "saturation":
                saturationLabel.text = "\(Int(colorModel.saturation))%"
                saturationSlider.value = colorModel.saturation
            case "brightness":
                brightnessLabel.text = "\(Int(colorModel.brightness))%"
                brightnessSlider.value = colorModel.brightness
            case "color":
                colorView.setNeedsDisplay()
                webLabel.text = "#\(colorModel.rgbCode)"
            default:
                break	/* unknown change; consider adding an assert to ensure this never happens */
        }
    }

    // MARK: Sharing
    
    @IBAction func share(sender: AnyObject!) {
        let shareMessage = "I wrote an iOS app to share a color! RGB=#\(colorModel.rgbCode)"
        let itemsToShare = [shareMessage]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        if let popover = activityViewController.popoverPresentationController {
            popover.barButtonItem = sender as UIBarButtonItem
        }
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
}

