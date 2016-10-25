// Playground - Enumerations
//

import UIKit


// Create an enumeration by listing the values you want defined.
enum Weekday {
	case Sunday
	case Monday
	case Tuesday
	case Wednesday
	case Thursday
	case Friday
	case Saturday
}

// An enumeration's value is NameOfEnumeration.nameOfValue
var dueDay = Weekday.Thursday

// When assigning to a variable or parameter that already
//	has an enum type, you can omit the enum name from the value.
dueDay = .Friday


// An enum can be made compatible with another type.
// In this example, the enum values can be converted to and from
//	an Int value, called it raw value.
var nextWeekDayNumber: Int = 0
enum WeekdayNumber: Int {
	case Sunday = 0
	case Monday
	case Tuesday
	case Wednesday
	case Thursday
	case Friday
	case Saturday
	// Enums can have computed properties and member functions
	var range: NSRange { return NSRange(location: 0, length: 7) }
	func dayOfJulienDate(date: NSTimeInterval) -> WeekdayNumber {
		return WeekdayNumber(rawValue: Int(date) % 7 + 2)!
	}
	// A member function or property accesses its value using self
	var weekend: Bool { return self == .Sunday || self == .Saturday }
	var weekday: Bool { return !weekend }
	init(random: Bool) {
		if random {
			// Pick a day at random
			nextWeekDayNumber = Int(arc4random_uniform(7))
		}
		self = WeekdayNumber(rawValue: nextWeekDayNumber)!
		// post increment to the next day
		nextWeekDayNumber++
		if nextWeekDayNumber > WeekdayNumber.Saturday.rawValue {
			nextWeekDayNumber = WeekdayNumber.Sunday.rawValue
		}
	}
}

// An enum value with a raw value can be converted to that raw
//	value using its rawValue property.
let dayNumber: Int = WeekdayNumber.Wednesday.rawValue

// You can also create new enum values from raw values, as follows
let dayFromNumber = WeekdayNumber(rawValue: 3)	// <-- .Wednesday


// Enum values can also be non-numeric, in which case you must
//	assign every raw value individually.
enum WeekdayName: String {
	case Sunday = "Sunday"
	case Monday = "Monday"
	case Tuesday = "Tuesday"
	case Wednesday = "Wednesday"
	case Thursday = "Thursday"
	case Friday = "Friday"
	case Saturday = "Saturday"
}

let reportDay: WeekdayName = .Monday
println("Reports are due on \(reportDay.rawValue)")


// Enumerations can have other values associated with a specific enumeration value.
// Each associated value is a tuple of values stored alongside the
//	enumeration value. The associated values are only valid and
//	accessible for the given enumeration value.

enum Sadness {
	case Sad
	case ReallySad
	case SuperSad
}

enum WeekdayChild {
	case Sunday
	case Monday
	case Tuesday(sadness: Sadness)
	case Wednesday
	case Thursday(distanceRemaining: Double)
	case Friday(friends: Int, charities: Int)
	case Saturday(workHours: Float)
}

let graceful = WeekdayChild.Monday
let woeful = WeekdayChild.Tuesday(sadness: .ReallySad)
let traveler = WeekdayChild.Thursday(distanceRemaining: 100.0)
let social = WeekdayChild.Friday(friends: 23, charities: 4)
let worker = WeekdayChild.Saturday(workHours: 90.5)

var child = traveler

switch child {
	case .Sunday, .Monday, .Wednesday:
		break
	case .Tuesday(let mood):
		if mood == .ReallySad {
			println("Tuesday's child is really sad.")
		}
	case .Thursday(let miles):
		println("Thursday's child has \(miles) miles to go.")
	case .Friday(let friendCount, _):
		println("Friday's child has \(friendCount) friends.")
	case .Saturday(let hours):
		println("Saturday's child is working \(hours) hours this week.")
}


// Enumerations can have properties, functions, and initializers.
let today = WeekdayNumber(random: true)
if today.weekday {
	// Set alarm clock to 6:30
} else {
	// Turn alarm clock off
}

