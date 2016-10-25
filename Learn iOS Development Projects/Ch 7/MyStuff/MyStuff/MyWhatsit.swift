//
//  MyWhatsit.swift
//  MyStuff
//
//  Created by James Bucanek on 8/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


let WhatsitDidChangeNotification = "MyWhatsitDidChange"

class MyWhatsit {

	var name: String {
		didSet {
			postDidChangeNotification()
		}
	}
	var location: String {
		didSet {
			postDidChangeNotification()
		}
	}
	var image: UIImage? {
		didSet {
			postDidChangeNotification()
		}
	}
	var viewImage: UIImage {
		return image ?? UIImage(named: "camera")!
	}

	init( name: String, location: String = "" ) {
		self.name = name;
		self.location = location
	}

	func postDidChangeNotification() {
		let center = NSNotificationCenter.defaultCenter()
		center.postNotificationName(WhatsitDidChangeNotification, object: self)
	}
	
}