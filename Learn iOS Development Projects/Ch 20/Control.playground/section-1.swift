// Playground - Control Statements
//

import UIKit



//
// if
//

var condition = true
var otherCondition = false


// if
if condition {
	// Executed if condition is true
}

// if/else
if condition {
	// Executed if condition is true
} else {
	// Executed if condition is false
}

// Nested if, else, and else if
if condition {
	if otherCondition {
		// Exeucted if both condition and otherCondition are true
	} else {
		// Executed if condition is true and otherCondition is false
	}
} else if otherCondition {
	// Executed if condition is false and otherCondition is true
} else {
	// Executed if both condition and otherCondition are false
}


//
// while
//

while condition {
	condition = false
}

do {
	otherCondition = false
} while otherCondition


//
// for
//

// for (traditional)
for condition = true; condition; condition = false {
}

for var i=0; i<100; i++ {
	// perform 100 times, with i=0 through i=99
}

// for-in (range)
for i in 0..<100 {
	// perform 100 times, with i=0 through i=99
	condition = true
}

for i in 0...100 {
	// perform 101 times, with i=0 through i=100
	condition = true
}

// for (array)
let notes = [ "do", "re", "mi", "fa", "sol", "la", "ti" ]
for note in notes {
	println(note)
}

// for (dictionary)
let doReMi = [ "doe": "a deer, a female deer",
			   "ray": "a drop of golden sun",
			   "me":  "a name, I call myself",
			   "far": "a long long way to run",
			   "sew": "a needle pulling thread",
			   "la":  "a note to follow so",
			   "tea": "I drink with jam and bread" ]
for note in doReMi {
	// note is a (key,value) tuple
	println("\(note.0): \(note.1)")
}

for (noteName,meaning) in doReMi {
	// decomposed tuple into noteName (the key) and meaning (the value)
	println("\(noteName): \(meaning)")
}

// for (string)
for character in "When you know the notes to sing, you can sing most anything" {
	// Loop executes 59 times, once for each character in the string
}


//
// switch
//

// switch (comparision)
let number = 9
switch number {
	case 1:
		println("The lonest number")
	case 2:
		println("Enough to tango")
	case 3, 5, 7:
		println("\(number) is prime")
	case 4, 6, 8:
		println("\(number) is even")
	case 13:
		println("Considered unlucky")
	default:
		println("\(number) is a number I'm not familiar with")
}

// switch (range matching)
let testScore = 91
switch testScore {
	case 94...100:
		println("Outstanding!")
	case 86...93:
		println("Very respectable")
	case 75...85:
		println("Pretty good")
	case 60...74:
		println("OK")
	default:
		println("Fail")
}

let passingScore = 55
switch testScore {
	// case conditions can employ variables, expressions, and functions
	// cases are evaluated in order
	// case conditions can overlap; the first one to match is executed
	case 94...100:
		println("Outstanding!")
	case (100+passingScore)/2...100:
		println("Very respectable")
	case passingScore...100:
		println("OK")
	default:
		println("Fail")
}

// switch (tuple)
var sandwich = ("pastrami", "swiss")
var name = ""
switch sandwich {
	case ("tuna", "cheddar"):
		name = "Tuna melt"
	case ("ground beef", "cheddar"):
		name = "Cheeseburger"
	case ("ground beef", _):
		name = "Hamburger"
	case ("steak", "cheddar"):
		name = "Cheesesteak"
	case ("ham", "american"):
		name = "Ham & Cheese"
	case ("ham", "gruyère"):
		name = "Croque-monsieur"
	case ("ham", "swiss"):
		name = "Cuban"
	default:
		name = "\(sandwich.0) with \(sandwich.1)"
}

// switch (tuple decomposed)
sandwich = ("ground beef", "blue cheese")
switch sandwich {
	case ("tuna", "cheddar"):
		name = "Tuna melt"
	case ("ground beef", let cheese):
		name = "Hamburger with \(cheese)"
	default:
		name = "Today's Speical"
}

// switch (while clause)
let calendar = NSCalendar.currentCalendar()
let when = calendar.components(.HourCalendarUnit | .WeekdayCalendarUnit, fromDate: NSDate())
var special = ""
switch when.weekday {
	case 1, 7 where when.hour<13:		// weekend (Sunday or Saturday) before 1 PM
		special = "Eggs Benedict"
	case 1, 7:							// weekend, the rest of the day
		special = "Cobb Salad"
	case 2 where when.hour<8:			// Monday, before 8 AM
		special = "Ham with Red-eye Gravy"
	case 3, 5 where when.hour<10:		// Tuesday or Thursday, before 10 AM
		special = "Fried Egg Sandwich"
	case 4:								// Wednesday, all day
		special = "Ruben"
	case 5, 6:							// Thursday (after 10 AM) or anytime Friday
		special = "Egg Salad Sandwich"
	default:							// any other time
		special = "Cheeseburger"
}



// Making a struct or class Equatable makes it elegable for use in a switch statement
struct ABC: Equatable {
	var one: Int
	var two: Bool
	var three: String
}
// This is the global function you must implement to make ABC Equatable
func ==(l: ABC, r: ABC) -> Bool {
	return l.one==r.one && l.two==r.two && l.three==r.three
}

var test = ABC(one: 1, two: true, three: "three")
switch test {
	case ABC(one: 1, two: true, three: "three"):
		println("It's a match!")
	case ABC(one: 2, two: false, three: "four"):
		println("Somethign else")
	default:
		break
}


