//
//  BookViewController.swift
//  Wonderland
//
//  Created by James Bucanek on 9/2/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class BookViewController: UIPageViewController/*, UIPageViewControllerDelegate*/ {

	let bookSource = BookDataSource()	// *important* keep a strong reference to the data source

	override func viewDidLoad() {
		super.viewDidLoad()

		// Load the data source with the text of the book
		if let textURL = NSBundle.mainBundle().URLForResource("Alice", withExtension: "txt") {
			bookSource.paginator.bookText = NSString(contentsOfURL: textURL, encoding: NSUTF8StringEncoding, error: nil) ?? ""
		}

		// Make it the data source for this page view controller
		dataSource = bookSource

		// Set up the page view controller(s)
		let firstPage = bookSource.load(page: 1, pageViewController: self)!	/* page 1 controller always exists */
		setViewControllers([firstPage], direction: .Forward, animated: false, completion: nil)
	}
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Adapt the interface to the current display traits
        adaptViewsToTraitCollection(traitCollection)
    }

	override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		// The interface is about to transition to a new display environment
		super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
		adaptViewsToTraitCollection(newCollection)
	}

	func adaptViewsToTraitCollection(traits: UITraitCollection) {
		// Adapt the properties of content to present nicely in the given environment
		let compactWidth = ( traitCollection.horizontalSizeClass == .Compact )

		var fontSize: CGFloat = 18.0		// font size for regular width displays
		if compactWidth {
			// The device is horizontally compact; reduce the size of the book font
			fontSize = 14.0					// font size for compact width displays
		} /* else { device size is regular } */

		// Adjust the size of the book font
		let paginator = bookSource.paginator
		let currentFont = paginator.font
		if currentFont.pointSize != fontSize {
			// Font size needs to be changed: create a new font, based on the same family, with the new size
			paginator.font = currentFont.fontWithSize(fontSize)
		}
	}

    // MARK: State Preservation
    
    let pageStateKey = "pageNumber"
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        // Preserve the page number of the current view controller
        let currentViewController = viewControllers[0] as OnePageViewController
        coder.encodeInteger(currentViewController.pageNumber, forKey: pageStateKey)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        // Get the saved page number
        let page = coder.decodeIntegerForKey(pageStateKey)
        if page != 0 {
            let currentViewController = viewControllers[0] as OnePageViewController
            // Change the page number of the book view controller.
            // The view controller hasn't appeared yet, so it hasn't
            //	loaded the text it's going to display. The page number
            //	can be set/changed anytime before that happens.
            currentViewController.pageNumber = page;
        }
    }
    
}

