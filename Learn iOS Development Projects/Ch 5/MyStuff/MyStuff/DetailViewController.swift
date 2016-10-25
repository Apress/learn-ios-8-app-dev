//
//  DetailViewController.swift
//  MyStuff
//
//  Created by James Bucanek on 8/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
                            
	@IBOutlet var nameField: UITextField!
	@IBOutlet var locationField: UITextField!

	var detailItem: MyWhatsit? {
		didSet {
		    // Update the view.
		    self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let detail = detailItem {
			if nameField != nil {
				nameField.text = detail.name
				locationField.text = detail.location
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	@IBAction func changedDetail(sender: AnyObject!) {
		if sender === nameField {
			detailItem?.name = nameField.text
		} else if sender === locationField {
			detailItem?.location = locationField.text
		}
	}
}

