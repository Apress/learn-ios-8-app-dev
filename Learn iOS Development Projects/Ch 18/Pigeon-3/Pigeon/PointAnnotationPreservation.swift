//
//  PointAnnotationPreservation.swift
//  Pigeon
//
//  Created by James Bucanek on 9/30/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import MapKit

enum LocationKey: String {
    case Latitude = "lat"
    case Longitude = "long"
    case Title = "title'"
}


extension MKPointAnnotation {
    
    var propertyState: [NSObject: AnyObject] {
        get {
            // Return the annotation point's map coordinate and title from as a dictionary
            //  of property list objects, suitable for use with user defaults.
            return [ LocationKey.Latitude.rawValue: NSNumber(double: coordinate.latitude),
                     LocationKey.Longitude.rawValue: NSNumber(double: coordinate.longitude),
                     LocationKey.Title.rawValue: title ]
        }
        set {
            // Set the annotation's map coordinate and title from values in the dictionary.
            let lat = (newValue[LocationKey.Latitude.rawValue] as NSNumber).doubleValue
            let long = (newValue[LocationKey.Longitude.rawValue] as NSNumber).doubleValue
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            title = newValue[LocationKey.Title.rawValue] as NSString
        }
    }
}
