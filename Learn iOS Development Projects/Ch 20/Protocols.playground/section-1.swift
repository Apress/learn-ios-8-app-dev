// Playground - Protocols
//

import UIKit


// A protocol defines a specific set of features that a class,
//	struct, or other custom type can adopt. Once adopted,
//	your type can be used anywhere there's a reference to that
//	protocol type.

protocol Flavor {
	var flavor: String { get }
	func tastesLike(flavor otherFlavor: Flavor) -> Bool
}


class IceCream {
	var flavor: String = "Vanilla"
	var scoops: Int = 1
}

class Sundae: IceCream, Flavor {
	func tastesLike(flavor otherFlavor: Flavor) -> Bool {
		return flavor == otherFlavor.flavor
	}
}

class Tofu: Flavor {
	var flavor: String = "Plain"
	var weight: Double = 1.0
	
	func tastesLike(flavor _: Flavor) -> Bool {
		// Tofu doesn't taste like anything else
		return false
	}
}

var dessert: Flavor = Sundae()
var chicken = Tofu()

dessert.tastesLike(flavor: chicken)

