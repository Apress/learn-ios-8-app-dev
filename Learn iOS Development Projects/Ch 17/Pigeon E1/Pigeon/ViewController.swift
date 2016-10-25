//
//  ViewController.swift
//  Pigeon
//
//  Created by James Bucanek on 7/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, MKMapViewDelegate {

	@IBOutlet var mapView: MKMapView!

	override func viewDidLoad() {
		super.viewDidLoad()

		mapView.userTrackingMode = .Follow
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
		if let location = mapView.userLocation?.location {
			clearAnnotation()
			let annotation = MKPointAnnotation()
			annotation.title = label
			annotation.coordinate = location.coordinate
			mapView.addAnnotation(annotation)
			mapView.selectAnnotation(annotation, animated: true)
			savedAnnotation = annotation
		}
	}

	func clearAnnotation() {
		if let annotation = savedAnnotation {
			mapView.removeAnnotation(annotation)
			savedAnnotation = nil
		}
		clearOverlay()
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

