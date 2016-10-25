// Playground - Control Statements
//

import UIKit


// Exercise: Rewriting the switch statement using a tuple and ranges

let calendar = NSCalendar.currentCalendar()
let when = calendar.components(.HourCalendarUnit | .WeekdayCalendarUnit, fromDate: NSDate())
var special = ""

switch (when.weekday,when.hour) {
	case (1,0...12), (7,0...12):		// weekend (Sunday or Saturday) before 1 PM
		special = "Eggs Benedict"
	case (1,_), (7,_):					// weekend, the rest of the day
		special = "Cobb Salad"
	case (2,0..<8):						// Monday, before 8 AM
		special = "Ham with Red-eye Gravy"
	case (3,0..<10), (5,0..<10):		// Tuesday or Thursday, before 10 AM
		special = "Fried Egg Sandwich"
	case (4,_):							// Wednesday, all day
		special = "Ruben"
	case (5,_), (6,_):					// Thursday (after 10 AM) or anytime Friday
		special = "Egg Salad Sandwich"
	default:							// any other time
		special = "Cheeseburger"
}

