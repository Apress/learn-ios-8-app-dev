// Playground - Casting
//

import UIKit


class IceCream {
	var flavor: String = "Vanilla"
	var scoops: Int = 1
}

class IceCreamSundae: IceCream {
	var topping: String = "Chocolate syrup"
	var nuts: Bool = true
	func addCherry() {
	}
}

class IceCreamSandwich: IceCream {
	var cookie = "Chocolate chip"
}

class BananaSplit: IceCreamSundae {
	var fruit: String = "Banana"
	func split() { }
}


let cone = IceCream()
let sundae = IceCreamSundae()
let sandwich = IceCreamSandwich()
let split = BananaSplit()

let mysteryDessert1: IceCream = cone
let mysteryDessert2: IceCream = sundae
let mysteryDessert3: IceCream = split


// Testing a type
mysteryDessert1 is BananaSplit
mysteryDessert2 is BananaSplit
mysteryDessert3 is BananaSplit

mysteryDessert1 is IceCreamSundae
mysteryDessert2 is IceCreamSundae
mysteryDessert3 is IceCreamSundae


//
// Downcasting
//


// Optional downcasting: preferred
if let mySundae = mysteryDessert2 as? IceCreamSundae {
	mySundae.nuts = true
}

// Shorter
(mysteryDessert2 as? IceCreamSundae)?.nuts = true


// Forced downcasting; only do this if you're absolutely
//	sure the object is that subtype, else bad things blah blah blah

let string = "I want ice cream."
let screaming = (string as NSString).uppercaseString

if mysteryDessert2 is IceCreamSundae {
	let mySundae = mysteryDessert2 as IceCreamSundae
	mySundae.nuts = true
}


//
// Downcasting collections
//
UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary) as [String]

let event = UIEvent()
event.allTouches()?.allObjects as? [UITouch]
event.allTouches()?.anyObject() as? UITouch


class SafeClass: NSObject {    @NSCopying var fancyTitle: NSAttributedString?}
