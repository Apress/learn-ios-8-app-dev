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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func changeHue(sender: AnyObject!) {
        if let slider = sender as? UISlider {
        colorModel.hue = slider.value
        colorView.backgroundColor = colorModel.color
        }
    }
    
    @IBAction func changeSaturation(sender: AnyObject!) {
        if let slider = sender as? UISlider {
        colorModel.saturation = slider.value
        colorView.backgroundColor = colorModel.color
        }
    }
    
    @IBAction func changeBrightness(sender: AnyObject!) {
        if let slider = sender as? UISlider {
        colorModel.brightness = slider.value
        colorView.backgroundColor = colorModel.color
        }
    }

}

