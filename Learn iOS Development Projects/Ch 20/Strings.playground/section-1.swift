// Playground - Strings
//

import UIKit


var string: String = "Hello!"
let immutableString: String = "Salut!"

var character: Character  = "!"


// Unicode is Swift's native character set.
// All strings and characters—even programming symbols—support the
//	entire Unicode character set.

// Unicode in strings
let hungary = "Üdvözlöm!"
let babyChick = "🐥"
// Unicode in variable names
let olá = "Hello!"
let 💖 = "sparkling heart"
let π = 3.14159265359

// Special characters in a string literal are escaped with a \
//	preceeding the pattern.
let nullChar = "\0"
let singleBackslash = "\\"
let horizontalTab = "\t"
let lineFeed = "\n"
let carriageReturn = "\r"
let doubleQuote = "\""
let singleQuote = "\'"
let anyUnicodeCharacter = "\u{1f425}"


//
// String interpolation
//

// Any value that can be converted into a string can be included
//	in a string literal between \( and ). The value replaces the
//	embedded expression.
let moon = "🌜"
let piLove = "I am over the \(moon) for \(π)"

// If you need precise control over formatting, create the string using NSString's
//	format: initializer instead.
NSString(format: "I am over the %@ for %.4f", moon, π)
NSString(format: "The value of %C is approximately %.4f", 0x03C0, π)


// String length vs. character count
// Some Unicode characters are composed of multiple Unicode values. In a string, the
//	Unicode values occupy two or more values in the array, but are treated as a single
//	Unicode character. This means the number of code values in a string isn't always the
//	same as the number of characters in the string.
let tricky = "\u{E9}\u{20DD}"
println("The length of \"\(tricky)\" is \((tricky as NSString).length)")
println("The character count of \"\(tricky)\" is \(countElements(tricky))")



//
// String manipulation
//

// Concatinate two strings using the + operater
let threeStrings = moon + " " + 💖
// Append a string using the += operator
var mutableString = "¡Hola!"
mutableString += " James"
// Append a character or string using the append() function
let exclamation: Character = "!"
mutableString.append(exclamation)


//
// Strings are NSString objects
//

let sparkRange = (threeStrings as NSString).rangeOfString("spark")
let objcString = threeStrings as NSString
let words = objcString.componentsSeparatedByString(" ")
// (var strings are not NSMutableString objects)


//
// Attributed strings
// (see AttributedString project)
//

