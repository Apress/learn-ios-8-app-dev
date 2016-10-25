//
//  ViewController.swift
//  Shorty
//
//  Created by James Bucanek on 7/17/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate,
										NSURLConnectionDelegate,
										NSURLConnectionDataDelegate {

	@IBOutlet var urlField: UITextField!
	@IBOutlet var webView: UIWebView!
	@IBOutlet var shortenButton: UIBarButtonItem!
	@IBOutlet var shortLabel: UIBarButtonItem!
	@IBOutlet var clipboardButton: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: Web page loading

	@IBAction func loadLocation( AnyObject ) {
		var urlText = urlField.text

		// If the user omitted the http:// or https:// at the beginning of the URL,
		//  supply it for them.
		if !urlText.hasPrefix("http:") && !urlText.hasPrefix("https:") {
			// urlText does NOT start with either http: or https:
			if !urlText.hasPrefix("//") {
				// urlText does not start with //
				urlText = "//" + urlText            // insert "//" at beginning of URL
			}
			urlText = "http:" + urlText             // insert "http:" at beginning of URL
		}

		// Convert the string into a URL object
		if let url = NSURL(string: urlText) {
			// Convert URL object into an URL Request object, and submit that to the web view
			webView.loadRequest(NSURLRequest(URL: url))
		}
	}
	
	func webViewDidStartLoad( UIWebView ) {
		// Disable the shorten URL button so the user can't tap it while the page is loading
		shortenButton.enabled = false
	}

	func webViewDidFinishLoad( UIWebView ) {
		// Once the page loads, reenable the button and update the URL location field
		shortenButton.enabled = true
		urlField.text = webView.request?.URL.absoluteString
	}

	func webView( webView: UIWebView, didFailLoadWithError error: NSError! ) {
		// An error occurred while loading the page: tell the user about it.
		var message = "That page could not be loaded. " + error.localizedDescription
		let alert = UIAlertController(title: "Could not load URL",
									message: message,
							 preferredStyle: .Alert )
		let okAction = UIAlertAction(title: "That's Sad", style: .Default, handler: nil)
		alert.addAction(okAction)
		presentViewController(alert, animated: true, completion: nil)
	}
	
	// MARK: URL Shortening

	let GoDaddyAccountKey = "0123456789abcdef0123456789abcdef"    // change this to your x.co account key
	var shortenURLConnection: NSURLConnection?
	var shortURLData: NSMutableData?

	@IBAction func shortenURL( AnyObject ) {
		// Get the URL of the current page and encoded it so it can be passed as a parameter.
		if let toShorten = webView.request?.URL.absoluteString {
			let encodedURL = toShorten.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)

			// Construct the request URL for the x.co service
			let urlString = "http://api.x.co/Squeeze.svc/text/\(GoDaddyAccountKey)?url=\(encodedURL)"
			// Prepare a buffer to hold the response
			shortURLData = NSMutableData()
			// Send the request.
			let request = NSURLRequest(URL: NSURL(string:urlString)!)
			shortenURLConnection = NSURLConnection(request:request, delegate:self)

			// Disable (debounce) the shorten button so it can't be tapped again until the request is finished
			shortenButton.enabled = false
		}
	}

	func connection( connection: NSURLConnection!, didFailWithError error: NSError! ) {
		// The request failed
		shortLabel.title = "failed"
		clipboardButton.enabled = false
		shortenButton.enabled = true
	}

	func connection( connection: NSURLConnection!, didReceiveData data: NSData! ) {
		// The next block of data was recevied from the server
		shortURLData?.appendData(data)
	}

	func connectionDidFinishLoading( connection: NSURLConnection! ) {
		// The request finished successfully
		if let data = shortURLData {
			let shortURLString = NSString(data: data, encoding: NSUTF8StringEncoding )
			shortLabel.title = shortURLString
			clipboardButton.enabled = true
		}
	}

	// MARK: Clipboard

	@IBAction func clipboardURL( AnyObject ) {
		let shortURLString = shortLabel.title!	// get the shortened URL, stored in the toolbar button title
		let shortURL = NSURL(string: shortURLString)
		UIPasteboard.generalPasteboard().URL = shortURL
	}

}

