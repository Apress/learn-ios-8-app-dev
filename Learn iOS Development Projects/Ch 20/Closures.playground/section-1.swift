// Playground - Closures
//

import UIKit
import SpriteKit


// A closure captures references to every variable outside
//	its scope when the closure is created.


// This function creates and returns a closure
func inScope(number: Int) -> ((Int) -> Int) {
	return { (multiplier: Int) -> Int in
		// This closure refers to two variables:
		// number is a variable belonging to inScope() and is outside
		//		the scope of this closure. The closure will "close over"
		//		this variable, capturing it.
		// multipler is a parameter of the closure. The code that
		//		ultimately invokes this closure will supply its value.
		return number * multiplier
		}
}

// These statement create two closures and stores them in variables
let times5 = inScope(5)
let times3 = inScope(3)

// These statement executes the previously created closures
// Even though the inScope() function has returned, the value of
//	its 'number' parameter were captured by the closure and are
//	still valid.
times5(7)
times3(7)



// A closure's reference to an external variable is just that: a reference.
// If the variable still exists, the code inside and outside the closure
//	both refer to same variable. Change one, and you change the other.

var multiplier =  3
let sharedVariable = { (number: Int) -> Int in
	return number * multiplier
}

sharedVariable(4)	// 4 * multiplier = 12
multiplier = 5
sharedVariable(4)	// 4 * multiplier = 20


// When using a closure in an instance method, implied references to self
//	must be explicitely written. In this example, a view controller is
//	animating a label. The syntax makes this clear that the closure it
//	capturing the self variable, not the label variable.
class LabelViewController: UIViewController {
	@IBOutlet var label: UILabel!
	
	override func viewDidAppear(animated: Bool) {
		UIView.animateWithDuration(1.5, animations: { self.label.alpha = 1.0 })
	}
}

//
// These are examples of variables and functions that refer to a closure.
// The type of the variable describe the parameters and return type
//	the closure must conform to.
//

// This variable stores a closure that accepts two parameters (Int and String)
//	and returns an integer result.
var closure: ((Int, String) -> Int) = { (number,name) in return 0 }

// This is a function wiht two parameters. The first is a String, the
//	second is a closure with one paramter (a String) that returns an integer.
func closureAsParameter(key: String, master: ((String) -> Int)) {
	// Call the closure, that expects one String parameter, with the given string
	master(key)
}
// Calling this function...
closureAsParameter("The Key") { (key) in return key.hash }

// Here are examples of closures with no parameters and a Bool return value
var noParamClosure: (() -> Bool) = { () -> Bool in return false } // full form
noParamClosure = { return true }								  // short form

// Here are examples of closures with no parameters and no return value
var nothingClosure: (() -> Void) = { () -> Void in println("I don't do much") }
nothingClosure = { println("I don't do much") }

//
// Shortcuts
//

// Because the types of the parameters and the return value are implied by
//	the variable, the types of the parameters and the return type can be
//	omitted from the closure.
closure = { (number,name) in return 1 }

// You can also omit the parentheses.
closure = { number,name in return 2 }

// If you don't use one or more of the parameters, you can ignore them.
closure = { number,_ in return number+1 }

// You can even dispense with naming the parameters entirely and use the
//	generic parameter names $0, $1, $2, ...

// In this example, the customActionWithDuration is being passed a closure
//	in the actionBlock parameter. The closure gets two parameters, an
//	SKNode and an elapsed time. In the first example, the parameters in
//	the closure are given names (node and elapsedTime):
let action1 = SKAction.customActionWithDuration( 3.0,
	                               actionBlock: {
									(node, elapsedTime) in
									if elapsedTime > 0.5 {
										node.alpha = elapsedTime/3.0
									}
								})
// In this example, the closure code doesn't name the parameters. Instead,
//	it uses their shorthand $n names. In this case, $0 will refer to the
//	SKNode and $1 the elapsed time.
let action2 = SKAction.customActionWithDuration( 3.0,
	actionBlock: { if $1 > 0.5 { $0.alpha = $1/3.0 } })

// The single-expression shortcut lets you write a closure the returns
//	a value as just the expression of the return statement.
// This example creates an array of to-do items, and then sorts them
//	into order by priority.

struct ToDoItem {
	let priority: Int
	let note: String
}
var toDoList = [ ToDoItem(priority: 3, note: "Recycle ice cream cups"),
				 ToDoItem(priority: 1, note: "Buy ice cream"),
				 ToDoItem(priority: 2, note: "Invite friends over") ]

// Swift array object has a sort() function. The function takes a closure
//	that receives two parameters (left,right) and returns a Bool indicating
//	if those items are in order or not.

// Here's the sort function called with named parameters and a return statement
toDoList.sort( { (left, right) in return left.priority < right.priority } )
// Here's the sort function being called using shorthand parameter names
toDoList.sort( { return $0.priority < $1.priority } )
// Here are two examples of writing the entire closure as a return statement
//	expression, once using named parameters and once using shorthand names.
toDoList.sort( { (left, right) in left.priority < right.priority } )
toDoList.sort( { $0.priority < $1.priority } )


// Trailing closures let you pass the last argument of a function call
//	by wrting the closure after the function call.
let scene = SKScene()
scene.enumerateChildNodesWithName("firefly", usingBlock: {
		(node, _) in
		node.hidden = false
	})
// Here's the same call using a trailing closure
scene.enumerateChildNodesWithName("firefly") {
		(node, _) in
		node.hidden = false
	}





