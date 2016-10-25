//
//  MasterViewController.swift
//  MyStuff
//
//  Created by James Bucanek on 8/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

	var detailViewController: DetailViewController? = nil
	var things: [MyWhatsit] = [
		MyWhatsit(name: "Gort",						location: "den"),
		MyWhatsit(name: "Disappearing TARDIS mug",	location: "kitchen"),
		MyWhatsit(name: "Robot USB drive",			location: "office"),
		MyWhatsit(name: "Sad Robot USB hub",		location: "office"),
		MyWhatsit(name: "Solar Powered Bunny",		location: "office")
		]

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
		    self.clearsSelectionOnViewWillAppear = false
		    self.preferredContentSize = CGSize(width: 320, height: 600)
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		self.navigationItem.leftBarButtonItem = self.editButtonItem()

		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		self.navigationItem.rightBarButtonItem = addButton
		if let split = self.splitViewController {
		    let controllers = split.viewControllers
		    self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
		}

		let center = NSNotificationCenter.defaultCenter()
		center.addObserver( self,
				  selector: "whatsitDidChange:",
					  name: WhatsitDidChangeNotification,
					object: nil)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	var itemNumber = 0
	func insertNewObject(sender: AnyObject) {
		let newThing = MyWhatsit(name: "My Item \(++itemNumber)")
		things.insert(newThing, atIndex: 0)
		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
		//things.append(newThing)
		//let indexPath = NSIndexPath(forRow: things.count-1, inSection: 0)
		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow() {
                let thing = things[indexPath.row]
                let controller = (segue.destinationViewController as UINavigationController).topViewController as DetailViewController
                controller.detailItem = thing
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return things.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
		let thing = things[indexPath.row] as MyWhatsit
		cell.textLabel?.text = thing.name
		cell.detailTextLabel?.text = thing.location
		cell.imageView?.image = thing.viewImage
		return cell
	}

	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}

	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			things.removeAtIndex(indexPath.row)
		    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
		    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}

	// MARK: Data Model

	func whatsitDidChange(notification: NSNotification) {
		// Received whenever a MyWhatsit object is edited.
		// Find the object in this table (if it is in this table)
		if let changedThing = notification.object as? MyWhatsit {
			for (index,thing) in enumerate(things) {
				if thing === changedThing {
					let path = NSIndexPath(forItem: index, inSection: 0)
					tableView.reloadRowsAtIndexPaths([path], withRowAnimation: .None)
				}
			}
		}
	}

}

