//
//  CharacterDetailViewController.swift
//  Wonderland
//
//  Created by James Bucanek on 9/6/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class CharacterDetailViewController: UIViewController {

	@IBOutlet var nameLabel: UILabel!
	@IBOutlet var imageView: UIImageView!
	@IBOutlet var descriptionView: UITextView!

	var characterInfo = [String: String]()

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		nameLabel?.text = characterInfo[nameKey]
		imageView?.image = UIImage(named: characterInfo[imageKey]!)
		descriptionView?.text = characterInfo[descriptionKey]
	}

}
