//
//  MapOptionsViewController.swift
//  Pigeon
//
//  Created by James Bucanek on 7/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import MapKit


class OptionsViewController: UIViewController {

	var mapView: MKMapView!
	@IBOutlet var mapStyleControl: UISegmentedControl!
	@IBOutlet var headingControl: UISegmentedControl!

	// MARK: View Management

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		if let mapView = (presentingViewController as? ViewController)?.mapView {
			mapStyleControl.selectedSegmentIndex = Int(mapView.mapType.rawValue)
			headingControl.selectedSegmentIndex = mapView.userTrackingMode.rawValue-1
		}
	}

	// MARK: Actions

	@IBAction func changeMapStyle(sender: UISegmentedControl!) {
        if let selectedMapType = MKMapType(rawValue:UInt(sender.selectedSegmentIndex)) {
			if let mapView = (presentingViewController as? ViewController)?.mapView {
				mapView.mapType = selectedMapType
			}
		}
	}

	@IBAction func changeHeading(sender: UISegmentedControl!) {
        if let selectedTrackingMode = MKUserTrackingMode(rawValue:sender.selectedSegmentIndex+1) {
			if let mapView = (presentingViewController as? ViewController)?.mapView {
				mapView.userTrackingMode = selectedTrackingMode
			}
		}
	}

	@IBAction func dismiss(gesture: UIGestureRecognizer) {
		presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
}
