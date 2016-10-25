//
//  DetailViewController.swift
//  MyStuff
//
//  Created by James Bucanek on 8/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit
import MobileCoreServices

class DetailViewController: UIViewController, UIImagePickerControllerDelegate,
											  UINavigationControllerDelegate {

	@IBOutlet var nameField: UITextField!
	@IBOutlet var locationField: UITextField!
	@IBOutlet var imageView: UIImageView!

	var detailItem: MyWhatsit? {
		didSet {
		    // Update the view.
		    self.configureView()
		}
	}

	func configureView() {
		// Update the user interface for the detail item.
		if let detail = detailItem {
			if nameField != nil {
				nameField.text = detail.name
				locationField.text = detail.location
				imageView.image = detail.viewImage
			}
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.configureView()
	}

	@IBAction func changedDetail(sender: AnyObject!) {
		if sender === nameField {
			detailItem?.name = nameField.text
		} else if sender === locationField {
			detailItem?.location = locationField.text
		}
	}

	@IBAction func choosePicture(_: AnyObject!) {
		if detailItem == nil {
			return
		}
		dismissKeyboard(self)

		let hasPhotos = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
		let hasCamera = UIImagePickerController.isSourceTypeAvailable(.Camera)
		switch (hasPhotos,hasCamera) {
			case (true,true):
				let alert = UIAlertController(title: nil,
					message: nil,
					preferredStyle: .ActionSheet)
				alert.addAction(UIAlertAction(title: "Take a Picture",
											  style: .Default,
											handler: { (_) in
												self.presentImagePicker(.Camera)
												}))
				alert.addAction(UIAlertAction(title: "Choose a Photo",
											  style: .Default,
											handler: { (_) in
												self.presentImagePicker(.PhotoLibrary)
												}))
				alert.addAction(UIAlertAction(title: "Cancel",
											  style: .Cancel,
											handler: nil))
				if let popover = alert.popoverPresentationController {
					popover.sourceView = imageView
					popover.sourceRect = imageView.bounds
					popover.permittedArrowDirections = ( .Up | .Down )
				}
				presentViewController(alert, animated: true, completion: nil)
			case (true,false):
				presentImagePicker(.PhotoLibrary)
			case (false,true):
				presentImagePicker(.Camera)
			default: /* (false,false) */
				break;
		}
	}

	func presentImagePicker(source: UIImagePickerControllerSourceType) {
		let picker = UIImagePickerController()
		picker.sourceType = source
		picker.mediaTypes = [kUTTypeImage as NSString]
		picker.delegate = self
		if source == .PhotoLibrary {
			picker.modalPresentationStyle = .Popover
		}
		if let popover = picker.popoverPresentationController {
			popover.sourceView = imageView
			popover.sourceRect = imageView.bounds
		}
		presentViewController(picker, animated: true, completion: nil)
	}

	let maxImageDimension: CGFloat = 640.0

	func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
		// Get the image the user took or choose.
		var image: UIImage! = info[UIImagePickerControllerEditedImage] as? UIImage
		if image == nil {
			image = info[UIImagePickerControllerOriginalImage] as UIImage
		}
		// The media picker always include an original image, so |image| will always contain a value
		//	at this point in the code.

		if picker.sourceType == .Camera {
			// The image came from taking a new picture.
			// Most users expect that any pictures they take are added to the their camera roll.
			UIImageWriteToSavedPhotosAlbum(image,nil,nil,nil)
		}

		// Convert the UIKit image to a Core Graphic image
		let cgImage = image.CGImage
		// Construct a square rect that's centered in the image
		let height = Int(CGImageGetHeight(cgImage))
		let width = Int(CGImageGetWidth(cgImage))
		var crop = CGRect(x: 0, y: 0, width: width, height: height)
		if height > width {
			crop.size.height = crop.size.width
			crop.origin.y = CGFloat((height-width)/2)
		} else {
			crop.size.width = crop.size.height
			crop.origin.x = CGFloat((width-height)/2)
		}
		// Extract the square rect from the center of the image as a new image
		let croppedImage = CGImageCreateWithImageInRect(cgImage, crop)
		// Convert the cropped Core Graphics image back into a UIKit image
		//	scaling it so the image is not more than maxImageDimension high/wide.
		let maxImageDimension: CGFloat = 640.0
		image = UIImage(CGImage: croppedImage,
			scale: max(crop.height/maxImageDimension,1.0),
			orientation: image.imageOrientation)
		// Store the newly cropped image in the MyWhatsit object
		detailItem?.image = image
		// Also update the image view so the new image appears immediately
		imageView.image = image
		// Dismiss the photo picker
		dismissViewControllerAnimated(true, completion: nil)
	}

	func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
		// User didn't pick or take a photo; dismiss the photo picker and do nothing
		dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func dismissKeyboard(_: AnyObject!) {
		view.endEditing(false)
	}
}

