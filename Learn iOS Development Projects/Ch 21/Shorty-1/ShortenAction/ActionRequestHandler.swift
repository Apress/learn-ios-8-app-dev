//
//  ActionRequestHandler.swift
//  ShortenAction
//
//  Created by James Bucanek on 10/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    
	func beginRequestWithExtensionContext(context: NSExtensionContext) {
		// Do not call super in an Action extension with no user interface
		self.extensionContext = context
		
		// Find the item containing the results from the JavaScript preprocessing.
		for item in context.inputItems as [NSExtensionItem] {
			if let attachments = item.attachments as? [NSItemProvider] {
				for itemProvider in attachments {
					let urlType = String(kUTTypeURL)
					if itemProvider.hasItemConformingToTypeIdentifier(urlType) {
						itemProvider.loadItemForTypeIdentifier(urlType, options: nil) { (item,error) in
							dispatch_async(dispatch_get_main_queue()) {
								if let url = item as? NSURL {
									self.actionWithURL(url)
								}
							}
						}
					}
				}
			}
		}
		
	}

	func actionWithURL(url: NSURL) {
		// Shorten the URL using the x.co service.
		Squeezer.shortenURL(longURL: url) { (shortURL, error) in
			if error == nil {
				if let url = shortURL {
					// Successfully shortened the URL!
					UIPasteboard.generalPasteboard().URL = url		// Put the URL on the clipboard
				}
				// Report back to the host app and let it know the extension has finished.
				self.extensionContext?.completeRequestReturningItems(nil, completionHandler: nil)
			} else {
				// There was an error
				// Tell the host app that the extension won't be doing its thing and why
				self.extensionContext?.cancelRequestWithError(error!)
			}
		}
	}

}
