//
//  ViewController.swift
//  Pigeon
//
//  Created by James Bucanek on 7/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import MapKit


enum PreferenceKey: String {
    case MapType = "HPMapType"
    case Heading = "HPFollowHeading"
    case SavedLocation = "HPLocation"
}


class ViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!
    var cloudStore: NSUbiquitousKeyValueStore?

	override func viewDidLoad() {
		super.viewDidLoad()

        cloudStore = NSUbiquitousKeyValueStore.defaultStore()
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver( self,
                  selector: "cloudStoreChanged:",
                      name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification,
                    object: cloudStore)
        cloudStore?.synchronize()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()

        // Restore the map type, tracking, and annotations from the user defaults
        mapView.mapType = MKMapType(rawValue: UInt(userDefaults.integerForKey(PreferenceKey.MapType.rawValue)))!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: userDefaults.integerForKey(PreferenceKey.Heading.rawValue))!
        restoreAnnotation()
	}

	// MARK: Map

	func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
		if mode == .None {
			mapView.userTrackingMode = .Follow
		}
	}
	
	// MARK: Map Annotation

	@IBAction func dropPin(sender: AnyObject!) {
		let alert = UIAlertController(title: "What's Here?",
			message: "Type a label for this location.",
			preferredStyle: .Alert)
		alert.addTextFieldWithConfigurationHandler(nil)
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		alert.addAction(cancelAction)
		let okAction = UIAlertAction(title: "Remember", style: .Default, handler: { (_) in
			if let textField = alert.textFields?[0] as? UITextField {
				var label = "Over Here!"
				if let text = textField.text {
					let trimmed = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
					if (trimmed as NSString).length != 0 {
						label = trimmed
					}
				}
				self.saveAnnotation(label: label)
			}
			})
		alert.addAction(okAction)
		presentViewController(alert, animated: true, completion: nil)
	}

	@IBAction func clearPin(sender: AnyObject!) {
		clearAnnotation()
	}

	var savedAnnotation: MKPointAnnotation?

	func saveAnnotation(# label: String) {
        // Drop a pin with the given label at the user's current location (if known)
		if let location = mapView.userLocation?.location {
			let annotation = MKPointAnnotation()
			annotation.title = label
			annotation.coordinate = location.coordinate
            setAnnotation(annotation)
            preserveAnnotation()
		}
	}

	func clearAnnotation() {
        // Discard the saved location
        setAnnotation(nil)
        preserveAnnotation()
	}
    
    func setAnnotation(annotation: MKPointAnnotation?) {
        // Set, update, or clear the saved location
        if savedAnnotation != annotation {
            if let oldAnnotation = savedAnnotation {
                mapView.removeAnnotation(oldAnnotation)
                clearOverlay()
            }
            savedAnnotation = annotation
            if annotation != nil {
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }

	func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
		if annotation === mapView.userLocation {
			return nil
		}

		let pinID = "Save"
		var pinView: MKPinAnnotationView!
		pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinID) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinID)
			pinView.canShowCallout = true
			pinView.animatesDrop = true
		}
		return pinView
	}
    
    // MARK: User Defaults
    
    func preserveAnnotation() {
        // Save the information about the current annotation
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let annotation = savedAnnotation {
            userDefaults.setObject(annotation.propertyState, forKey: PreferenceKey.SavedLocation.rawValue)
            cloudStore?.setDictionary(annotation.propertyState, forKey: PreferenceKey.SavedLocation.rawValue)
        } else {
            userDefaults.removeObjectForKey(PreferenceKey.SavedLocation.rawValue)
            cloudStore?.removeObjectForKey(PreferenceKey.SavedLocation.rawValue)
        }
    }
    
    func restoreAnnotation() {
        // Get the information about the saved annotation from the user defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let state = userDefaults.dictionaryForKey(PreferenceKey.SavedLocation.rawValue) {
            // There was a saved annotation.
            // Turn it into a real annotation object and either add it to the map,
            //	or replace the one that's there.
            let restoreAnnotation = MKPointAnnotation()
            restoreAnnotation.propertyState = state
            setAnnotation(restoreAnnotation)
        } else {
            setAnnotation(nil)
        }
    }

    func cloudStoreChanged(notification: NSNotification) {
        // One or more values in the cloud changed.
        
        // Update the annotations in the local user defaults to match
        //	what's in the cloud (keeping the two synchronized).
        let localStore = NSUserDefaults.standardUserDefaults()
        if let cloudInfo = cloudStore?.dictionaryForKey(PreferenceKey.SavedLocation.rawValue) {
            localStore.setObject(cloudInfo, forKey: PreferenceKey.SavedLocation.rawValue)
        } else {
            localStore.removeObjectForKey(PreferenceKey.SavedLocation.rawValue)
        }
        // Restore the annotation from the values that are now in the local user defaults,
        //  indirectly updating its location from the cloud.
        restoreAnnotation()
    }

	// MARK: Map Overlay

	var returnOverlay: MKPolyline?

	func clearOverlay() {
		if let overlay = returnOverlay {
			mapView.removeOverlay(overlay)
			returnOverlay = nil
		}
	}

	func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
		clearOverlay()
		if let saved = savedAnnotation {
			if let user = userLocation {
				var coords = [ user.coordinate, saved.coordinate ]
				returnOverlay = MKPolyline(coordinates: &coords, count: 2)
				mapView.addOverlay(returnOverlay)
			}
		}
	}

	func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
		if overlay === returnOverlay {
			let renderer = MKPolylineRenderer(overlay: returnOverlay)
			renderer.strokeColor = UIColor(red: 0.4, green: 1.0, blue: 0.4, alpha: 0.7)
			renderer.lineCap = kCGLineCapRound
			renderer.lineWidth = 16.0
			renderer.lineDashPattern = [ 38.0, 22.0 ]
			return renderer
		}
		return nil
	}
}

