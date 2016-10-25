// Playground - Classes
//
// How to declare classes in Swift
//

import Foundation
import UIKit


// Needed so the following class declaration will work
class SuperClassName {
}
protocol ProtocolName {
	func instanceFunction(firstParam: Int, secondParam: Int) -> Bool
}


//
// Basic class declaration
//

class ClassName: SuperClassName, ProtocolName {

	private var instanceVariable: Int = -1
	
	func instanceFunction(firstParam: Int, secondParam: Int) -> Bool {
		return firstParam >= secondParam
	}
}

//
// Stored Properties
//

class ClassStoringProperties {
	let constantProperty: String = "never changes"
	var variableProperty: Int = 1
}

class ShorterClassStoringProperties {
	let constantProperty = "never changes"		// type implied by value
	var variableProperty = 1					// type implied by value
	var uninitializedProperty: Int				// explicit type, no initializer
	
	init() {
		uninitializedProperty = 0				// must be set during initialization
	}
}

//
// Calculated Properties
//

class ClassCalculatingProperties {
	var height: Double = 0.0
	var width: Double = 0.0
	var area: Double {
		get {
			return height*width
		}
		set(newArea) {
			width = sqrt(newArea)
			height = width
		}
	}
}

// Use a computed property just like any other property
let calculatingObject = ClassCalculatingProperties()
calculatingObject.height = 9.0
calculatingObject.width = 5.0
let area = calculatingObject.area
calculatingObject.area = 9.0

//
// Stored Property Observers
//

class ObservantView: UIView {
	var text: String = "" {
		didSet(oldText) {
			// This code executes whenever the text property is set (view.text = "hello")
			if text != oldText {
				setNeedsDisplay()
			}
		}
	}
}

//
// Methods
//

class MethodicalClass {
	
	// This method takes no parameters and returns no value
	func poke() {
	}
	
	// This method takes one parameter and returns a Bool result
	func pokeUser(name: String) -> Bool {
		return true
	}
	
	// This method takes two parameter and returns a Bool result
	func pokeUser(name: String, message: String) -> Bool {
		return true
	}
	
}

// Examples of calling the above methods
let methodical = MethodicalClass()
methodical.poke()
let result1 = methodical.pokeUser("james")
let result2 = methodical.pokeUser("james", message: "Do you hear the ice cream truck?")


// Examples of external and local parameter names

// Functions outside a class or struct have no external names unless you give them one
func pokeUser(name: String, message: String) { }
pokeUser("james", "I swore I heard the ice cream truck!")

// You can declare an external name; use # to make the external and local names the same
func poke(user name: String, # message: String) { }
// Functions with external parameter names must be called using those names
poke(user: "james", message: "Now I want ice cream!!")

// An example with three paramters
func poke(user name: String, say message: String, important priority: Bool) -> Bool {
	if priority {
		//sendMessage(message, toPerson: name)
		return true
	}
	return false
}

poke(user: "james", say: "Wouldn't some ice cream be great?", important: true)


class ExternalNamesInAClass {
	// By deafult, the first parameter of a method does not have an external name
	//	and the rest of the parameters get one. If you don't specify an external
	//	name, Swift uses the local name.
	func pokeUser(name: String, message: String) { }
	// call: pokeUser("james", message: "Who wants ice cream?")
	
	// You can optionally give the first parameter an external name too
	func poke(user name: String, message: String) { }
	// call: poke(user: "james", message: "I'm going to get ice cream.")
	
	// You can also suppress the external names for parameters using _
	func poke(user name: String, _ message: String) { }
	// call: poke(user: "james", "What flavor do you want?")

	// For initialization functions, the default is that all parameters
	//	get an external name. If you omit it, Swift uses the local name.
	init(defaultUser: String) { }
	// use: let externalize = ExternalNamesInAClass(defaultUser: "james")
}

class DefaultParametersClass {
	func pokeUser(name: String, message: String = "Poke!", important: Bool = false ) {
	}
}

let defaulter = DefaultParametersClass()
defaulter.pokeUser("james")
defaulter.pokeUser("james", message: "Where's my ice cream?")
defaulter.pokeUser("james", important: true)
defaulter.pokeUser("james", message: "The ice cream is melting!", important: true)


//
// Inheritance
//

class BaseClass {
	var lastUserPoked: String = "james"
	func pokeUser(name: String) {
	}
}

class SubClass: BaseClass {
	override var lastUserPoked: String {
		get {
			return super.lastUserPoked
		}
		set {
			if newValue != lastUserPoked {
				println("caller is poking a new user")
			}
			super.lastUserPoked = newValue
		}
	}
	
	override func pokeUser(name: String) {
		super.pokeUser(name)
		println("someone poked \(name)")
	}
	
}


class ClassWithLimitedInheritance {
	final var trustFundName: String = "Daddy Warbucks"
	final func giveToCharity(amount: Double) {
		if amount > 2.00 {
			println("Too much!")
		}
	}
}

final class EndOfTheLine: ClassWithLimitedInheritance {
	// You cannot create a subclass of EndOfTheLine
}


//
// Initializers
//

class SimpleInitializerClass {
	var name: String
	init() {
		name = "james"
	}
}

class AutomaticInitializerClass {
	var name = "james"
	var superUser = true

	// class has implied:
	//		init() { name = "james"; superUser = true }
}

class IceCream {
	var flavor: String
	var scoops: Int = 1

	init() {
		flavor = "Vanilla"
	}

	init(flavor: String, scoops: Int = 2) {
		self.flavor = flavor
		self.scoops = scoops
		addCherry()				// safe to call addCherry()
	}
	
	func addCherry() {
	}
}

let plain = IceCream()
let yummy = IceCream(flavor: "Chocolate")
let monster = IceCream(flavor: "Raspberry", scoops: 3)


enum Weekday {
	case Sunday
	case Monday
	case Tuesday
	case Wednesday
	case Thursday
	case Friday
	case Saturday
}


class IceCreamSundae: IceCream {
	var topping: String
	var nuts: Bool = true

	init(flavor: String, topping: String = "Caramel syrup") {
		// Phase 1: initialize all stored property values
		self.topping = topping
		// Phase 2: call the superclass initializer
		super.init(flavor: flavor, scoops: 3)
		// Phase 3: perform any other initialization that might involve functions, computed properties, ...
		addCherry()				// safe to call addCherry()
	}
	convenience init(special dayOfWeek: Weekday) {
		switch dayOfWeek {
			case .Sunday:
				self.init(flavor: "Strawberry", topping: "Whipped Cream")
			case .Friday:
				self.init(flavor: "Chocolate", topping: "Chocolate syrup")
			default:
				self.init(flavor: "Vanilla")
		}
	}
	
	override func addCherry() {
	}
}

let sundaySundae = IceCreamSundae(special: .Sunday)


class BananaSplit: IceCreamSundae {
	override init(flavor: String = "Vanilla, Chocolate, Strawberry", topping: String = "Caramel syrup") {
		// Phase 1: initialize all stored property values
		// (there is no phase 1, this subclass has no properties)
		
		// Phase 2: call the superclass initializer
		super.init(flavor: flavor, topping: topping)
		
		// Phase 3: perform any other initialization
		scoops = 3	// Bannana split always has three scoops
	}
}

let split = BananaSplit(flavor: "Vanilla, Pineapple, Cherry")
let sundaySplit = BananaSplit(special: .Sunday)

