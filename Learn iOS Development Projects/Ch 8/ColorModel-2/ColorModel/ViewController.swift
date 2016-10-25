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
    
    @IBOutlet var colorView: UIView!
    @IBOutlet var hueLabel: UILabel!
    @IBOutlet var saturationLabel: UILabel!
    @IBOutlet var brightnessLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func changeHue(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.hue = slider.value
            colorView.backgroundColor = colorModel.color
            hueLabel.text = NSString(format: "%.0f°", colorModel.hue)
        }
    }
    
    @IBAction func changeSaturation(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.saturation = slider.value
            colorView.backgroundColor = colorModel.color
            saturationLabel.text = NSString(format: "%.0f%%", colorModel.saturation)
        }
    }
    
    @IBAction func changeBrightness(sender: AnyObject!) {
        if let slider = sender as? UISlider {
            colorModel.brightness = slider.value
            colorView.backgroundColor = colorModel.color
            brightnessLabel.text = NSString(format: "%.0f%%", colorModel.brightness)
        }
    }

}

