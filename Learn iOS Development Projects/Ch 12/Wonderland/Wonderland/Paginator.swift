//
//  Paginator.swift
//  Wonderland
//
//  Created by James Bucanek on 9/1/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class Paginator {

	// Public properties:
	//	bookText: String			text of the book
	//	font: UIFont				font to use for text
	//	fontAttrs: Dictionary		(readonly) dictionary of font attributes used to draw/layout text
	//	viewSize: CGSize			the size of the view; used to paginate the text
	//	lastKnownPage: Int			(readonly) last page number known to exist (after all previous pages were laid out)

	var bookText: NSString = "" {
		didSet {
			// for long strings, this is an expensive calculation
			charCount = bookText.length
			// recalculate everything
			resetPages()
		}
	}

	var font: UIFont /* initialized in init(font:) */ {
		didSet {
			// Whenever the font is changed, construct a new set of attributes
			attributes = nil
			resetPages()
		}
	}
	var fontAttrs: [String: AnyObject] {						// public read-only version of attributes
		if attributes == nil {
			// Lazily construct a set of drawing attributes from the current font
			let style = NSMutableParagraphStyle()
			style.lineBreakMode = .ByWordWrapping
			attributes = [
				NSFontAttributeName: font,
				NSParagraphStyleAttributeName: style
				]
			}
		return attributes!
	}
	var lastKnownPage: Int { return lastPageWithContent }		// public read-only version of lastPageWithContent
	var viewSize: CGSize = CGSize(width: 100, height: 100) {	// size of view used to paginate the text
		didSet(previousSize) {
			if viewSize != previousSize {
				// The target size of the view changed: flush the page data, which will recalculate every page
				resetPages()
			}
		}
	}

	init(font: UIFont) {
		self.font = font
	}

	private var charCount = 0								// updated when setting bookText, must equal bookText.length
	private var attributes: [String: AnyObject]? = nil		// lazy, private, precalculated, dictionary of font attributes
															//	used to draw the text. (OnePageView needs this repeatedly)
	private var ranges = [NSRange]()						// array of known text ranges for each page
	private var lastPageWithContent = 1

	func resetPages() {
		ranges = [NSRange]()		// empty array
		lastPageWithContent = 1
	}

	// MARK: Pagination

	func rangeOfTextForPage(page: Int) -> NSRange {
		// Return the range of text in bookData that fits on this page.
		// If the returned length is 0, there is no text on this page.

		if ranges.count >= page {
			// The range for this page has already been calculated; return the cached value
			return ranges[page-1]
		}

		// The text for this pages has never been determined.

		// Get the size of the area the text must fit in.
		var constraintSize = viewSize
		let targetHeight = constraintSize.height
		// Create a working "box" to layout the text in, just to measure its height
		constraintSize.height = 32000	// ∞, effectively

		// Find the location in the text where this page starts.
		// (hint: it's were the previous page ends.)
		var textRange = NSRange(location: 0,length: 0)
		if page != 1 {
			// Recursively calculate the range for the previous page, then get its end location
			textRange.location = NSMaxRange(rangeOfTextForPage(page-1))
		}
		// textRange location is now at the character index where the page starts

		// First pass: add paragraphs to the text until it overflows the target size
		textRange.length = charCount-textRange.location
		var firstParagraph = true
		var needsTrimming = false
		bookText.enumerateSubstringsInRange(textRange, options: .ByLines) {
			// Note: using .ByLines because the paragraphs are seperated by \r characters, which
			//		 enumerateSubstringsInRange(...) interprets as line seperators.
			(_, paraRange, _, stop) -> Void in
			if firstParagraph {
				// This is the first paragraph being added to the test: get just the paragraph
				textRange = paraRange
				firstParagraph = false
			} else {
				// This is an additional paragraph: extend the text range to encompass it
				textRange.length = NSMaxRange(paraRange)-textRange.location
			}
			// Calculate the amount of screen space the accumulated text occupies
			let testText = self.bookText.substringWithRange(textRange)
			let textBound = testText.boundingRectWithSize( constraintSize,
												  options: .UsesLineFragmentOrigin,
											   attributes: self.fontAttrs,
												  context: NSStringDrawingContext())
			if textBound.size.height > targetHeight {
				// The accumulated text now overflows the target view: stop appending paragraphs
				needsTrimming = true
				stop.memory = true
			}
		}

		if needsTrimming {
			// Second pass: shorten the text, one word at a time, until it fits again
			// This is done by enumerating, backwards, through the words in the textRange
			bookText.enumerateSubstringsInRange(textRange, options: .ByWords | .Reverse) {
				(_, _, enclosingRange, stop) -> Void in
				// Trim the text range so it ends at the enclosing range of the last word
				textRange.length = enclosingRange.location-textRange.location
				// Calculate the amount of screen space the trimmed text occupies now
				let testText = self.bookText.substringWithRange(textRange)
				let textBound = testText.boundingRectWithSize( constraintSize,
													  options: .UsesLineFragmentOrigin,
												   attributes: self.fontAttrs,
													  context: NSStringDrawingContext())
				if textBound.size.height <= targetHeight {
					// The trimmed text fits!
					stop.memory = true
				}
			}
		}

		if textRange.length != 0 {
			// This page is not empty: remember the last page number that's not empty
			lastPageWithContent = page
		}

		// Save the range and return it
		// Note: ranges.count must be one less than page to get to this point in the code
		ranges.append(textRange)
		return textRange
		}

	// MARK: Data Model

	func pageAvailable(page: Int) -> Bool {
		// Return true if the given page number contains text
		if page == 1 {
			// It is assumed that the first page must *always* be available
			return true
		}
		let textRange = rangeOfTextForPage(page)
		return textRange.length != 0
	}

	func textForPage(page: Int) -> String {
		// Return the text for the given page
		return bookText.substringWithRange(rangeOfTextForPage(page))
	}

}