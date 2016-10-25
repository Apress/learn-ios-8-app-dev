//
//  MyWhatsit.swift
//  MyStuff
//
//  Created by James Bucanek on 8/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


let WhatsitDidChangeNotification = "MyWhatsitDidChange"


class MyWhatsit: NSObject, NSCoding {

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
        get {
            if image_private == nil {
                image_private = imageStorage?.imageForKey(imageKey)
            }
            return image_private
        }
        set {
            image_private = newValue
            imageKey = imageStorage?.keyForImage(newValue, existingKey: imageKey)
            postDidChangeNotification()
        }
	}
    private var image_private: UIImage?

    var viewImage: UIImage {
		return image ?? UIImage(named: "camera")!
	}
    
    var imageStorage: ImageStorage?
    var imageKey: String?
    
    // MARK: Lifecycle

	init( name: String, location: String = "" ) {
		self.name = name;
		self.location = location
	}
    
    // MARK: NSCoding
    
    let nameKey = "name"
    let locationKey = "location"
    let imageKeyKey = "image.key"
    
    required init(coder decoder: NSCoder) {
        name = decoder.decodeObjectForKey(nameKey) as String
        location = decoder.decodeObjectForKey(locationKey) as String
        imageKey = decoder.decodeObjectForKey(imageKeyKey) as? String
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(name, forKey: nameKey)
        coder.encodeObject(location, forKey: locationKey)
        coder.encodeObject(imageKey, forKey: imageKeyKey)
    }
    
    // MARK: Notification

	func postDidChangeNotification() {
		let center = NSNotificationCenter.defaultCenter()
		center.postNotificationName(WhatsitDidChangeNotification, object: self)
	}
    
    // MARK: Persistent Storage
    
    func willRemoveFromStorage() {
        // Called when this item is about to be removed from persistant storage
        imageStorage?.keyForImage(nil, existingKey: imageKey)   // delete the stored copy
        imageKey = nil                                          // imageKey is now useless
    }
	
}


class SubWhatever: MyWhatsit {
    
    // An example of subclassing a class that adopts NSCoding
    
    var someProperty: Int = 1
    
    required init(coder decoder: NSCoder) {
        // Call the superclass's decoder
        super.init(coder: decoder)
        // subclass decoding goes here
        someProperty = decoder.decodeIntegerForKey("someKey")
    }
    
    override func encodeWithCoder(coder: NSCoder) {
        // Call the superclass's encoder
        super.encodeWithCoder(coder)
        // subclass encoding goes here
        coder.encodeInteger(someProperty, forKey: "someKey")
    }
    
}