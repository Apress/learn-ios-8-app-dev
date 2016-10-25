//
//  Squeezer.swift
//  Shorty
//
//  Created by James Bucanek on 10/29/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import Foundation


let GoDaddyAccountKey = "0123456789abcdef0123456789abcdef"    // change this to your x.co account key


public class Squeezer {
	
	public class func shortenURL(# longURL: NSURL, completion: ((NSURL?, NSError?) -> Void)) {
		// Asynchronously submit longURL to the x.co service for shortening.
		// When finished, the shortened URL (or the error that occurred) is passed to the completion handler.
		if let absoluteURL = longURL.absoluteString {
			// Encode the URL so it won't be confused as part of the request URL
			if let encodedURL = absoluteURL.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
				// Construct the request URL for the x.co service
				let urlString = "http://api.x.co/Squeeze.svc/text/\(GoDaddyAccountKey)?url=\(encodedURL)"
				
				// Send the request
				let request = NSURLRequest(URL: NSURL(string: urlString)!)
				NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue() ) {
					(_, shortURLData, error) in
					if error == nil && shortURLData != nil {
						// Received a response; turn it back into a URL (if the data is a valid URL string)
						var shortURL: NSURL?
						if let data = shortURLData {
							if let short = NSString(data: data, encoding: NSUTF8StringEncoding ) {
								shortURL = NSURL(string: short)
							}
						}
						// Pass the shorted URL to the completion handler
						completion(shortURL, nil)
					} else {
						// An NSURLConnection error occured; pass the failure to the completion handler
						completion(nil, error)
					}
				}
			}
		}
	}
}
