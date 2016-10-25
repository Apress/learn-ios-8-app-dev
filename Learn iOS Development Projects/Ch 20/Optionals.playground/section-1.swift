// Playground - Optionals

import UIKit
import CoreLocation


//
// Optionals
//


var sometimesAnObject: NSDate? = NSDate()
var sometimesAString: String? = nil
var sometimesAnInt: Int?
var sometimesAnAnswer: Bool?


// nil test
if sometimesAnObject != nil {
	// The variable sometimesAnObject has an object, we checked
	println("The date is \(sometimesAnObject!)")	// assume it's valid
} else {
	// The variable sometimesAnObject contains nothing.
	// Any attempt to use it will cause a program failure.
	println("I better not use sometimesAnObject")
}

// optional binding
if let date = sometimesAnObject {
	// date is always an object here; you don't have to check or assume
	println("The date is \(date)")
} else {
	// What to do when sometimesAnObject isn't an object
//	println("The date is \(date)") <- invalid: date is not defined in this block
}

// relieve an optional of its value by setting it to nil
sometimesAnObject = nil


//
// Optionals carry
//

var dictionary = [String:String]()
let key = "key"
let value = dictionary[key]			// value's type is String?
if let existingValue = value {
	println("The value for key \"\(key)\" is \(existingValue).")
} else {
	println("There is no value for key \"\(key)\".")
}


//
// Optional chaining
//

class Mouse {
	func recitePoem() { }
}
class Hatter {
	var doorMouse: Mouse?
	func changePlaces() { }
}
class Cat {
	var quote: String { return "Most everyone's mad here." }
	var directions: String?
	var friend: Hatter?
	func disappear() { println("I'm not all here myself.") }
}
var cheshire: Cat?


// Safely perform a method
cheshire?.disappear()

// Same code, the long way
if cheshire != nil {
	cheshire!.disappear()
}

// Safely obtain a proprety of an optional object
let words = cheshire?.quote
// Note that the quote property is not optional, but words is optional (String?) because
//	it was obtained through chaining.
if words != nil {
	// The cat is here, and had something to say
}

let whereToGo = cheshire?.directions
// cheshire is optional and directions is optional, but whereToGo is still just String?

if cheshire?.friend?.doorMouse?.recitePoem() != nil {
	// The cheshire cat has a friend with a doormouse that recited a poem.
}

cheshire?.directions = "Return to the Tulgey woods."


//
// Forced Optionals
//

var dinah: Cat!

// Never use a forced optional unless you have either (a) tested it to make sure it
//	is not nil or (b) are pretty sure it's not nil and are willing to bet your app on it.
//dinah.disappear() // <-- Bad, bad, bad

// You can still treat dinah as an optional, you just aren't required to.
dinah?.disappear()
if let cat = dinah {
}

var dangerWillRobinson: String!


//
// Failable Initialiers
//

// A failable initializer returns an optional.
// It may fail to create the object and result in a nil value.
let noSuchImage = UIImage(named: "SevenImpossibleImages")


func locationForPointOfInterest(name: String) -> CLLocationCoordinate2D? {
	// Look up the longitude and latitude of a known location.
	return nil	// I guess I don't know any interesting places
}

class PointOfInterest {
	let name: String
	let location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
	
	init?(placeName name: String) {
		self.name = name
		if let loc = locationForPointOfInterest(name) {
			// This point of interest exists: finish initializing the object
			self.location = loc		// update location with the actual location
		} else {
			// The place could not be found: fail
			return nil
		}
	}
}

let castle = PointOfInterest(placeName: "Mystery Castle")


