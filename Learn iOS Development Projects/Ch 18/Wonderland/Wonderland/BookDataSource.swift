//
//  BookDataSource.swift
//  Wonderland
//
//  Created by James Bucanek on 9/2/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class BookDataSource: NSObject, UIPageViewControllerDataSource {

	let paginator = Paginator(font: UIFont(name: "Times New Roman", size: 18.0)!)

	func load(# page: Int, pageViewController: UIPageViewController) -> OnePageViewController? {
		if page < 1 || !paginator.pageAvailable(page) {
			return nil;
		}
		let controller = pageViewController.storyboard?.instantiateViewControllerWithIdentifier("OnePage") as OnePageViewController
		controller.paginator = paginator
		controller.pageNumber = page
		return controller
	}

	func pageViewController(bookViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		if let pageController = viewController as? OnePageViewController {
			let pageNumberAfter = pageController.pageNumber + 1
			return load(page: pageNumberAfter, pageViewController: bookViewController)
		}
		return nil
	}

	func pageViewController(bookViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		if let pageController = viewController as? OnePageViewController {
			let pageNumberBefore = pageController.pageNumber - 1
			return load(page: pageNumberBefore, pageViewController: bookViewController)
		}
		return nil
	}

}
