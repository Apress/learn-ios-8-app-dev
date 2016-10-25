// Playground - Tuples

import UIKit


// You create a tuple value by enclosing a list of values in parentheses,
//	optionally naming the members.
var iceCreamOrder = ("Vanilla", 1)
let wantToGet = (flavor: "Chocolate", scoops: 4)
// A tuple can be returned to assigned to any other tuple with the same type.
iceCreamOrder = wantToGet

// A function returning a tuple with named members.
func nextOrder() -> (flavor: String, scoops: Int) {
	// This is how you assemble a tuple from individual values.
	return ("Vanilla", 4)
}

// The tuple can be assigned to a single value. The value
//	then acts much like a struct; you use the member names
//	to access the individual values.
let order = nextOrder()
if order.scoops > 3 {
	println("\(order.scoops) scoops of \(order.flavor) in a dish.")
} else {
	println("\(order.flavor) cone")
}

// A tuple can be "decomposed" into individual values when assigned.
let (what,howMany) = nextOrder()
if howMany > 3 {
	println("\(howMany) scoops of \(what) in a dish.")
} else {
	println("\(what) cone")
}

// When you decompose a tuple, you can ignore some of the values
let (flavor2,_) = nextOrder()		// ignore the scoops value
if flavor2 == "Strawberry" { /* ... */ }

// A tuple type can omit the member names
func anonymousOrder() -> (String, Int) {
	return ("Chocolate", 2)
}

// To use a tuple with anonymous members, you must either decompose
//	the tuple or use a member's index.
let anon = anonymousOrder()
if anon.0 == "Chocolate" {
	println("\(anon.1) scoops of the good stuff.")
}

