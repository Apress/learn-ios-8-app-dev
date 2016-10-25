//
//  OnePageViewController.swift
//  Wonderland
//
//  Created by James Bucanek on 9/2/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class OnePageViewController: UIViewController {

	@IBOutlet var textView: OnePageView!
	@IBOutlet var pageLabel: UILabel!
	
	var pageNumber = 1
	var paginator: Paginator? = nil

	func loadPageContent() {
		if let tv = textView {
			if let pager = paginator {
				pager.viewSize = tv.bounds.size
				if !pager.pageAvailable(pageNumber) {
					// If the requested page is not available, move to the last known page.
					// This handles the situation where the interface is resized (e.g.
					//	device rotation) and, after repaginating the book, the page
					//	number no longer exists.
					pageNumber = pager.lastKnownPage
				}
				tv.fontAttrs = pager.fontAttrs
				tv.text = pager.textForPage(pageNumber)
			}
		}
		pageLabel?.text = "Page \(pageNumber)"
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		loadPageContent()
	}

}
