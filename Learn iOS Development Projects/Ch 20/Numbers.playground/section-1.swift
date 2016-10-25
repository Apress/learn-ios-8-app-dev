// Playground - Numbers

import UIKit


// Casual types (size changes based on processor architecture)
let integer: Int = 0
let unsignedInteger: UInt = 0
let cgFloat: CGFloat = 0.0

// Word size specific types
let eightBitInteger: Int8 = -8
let unsignedEightBitInteger: UInt8 = 8
let sixteenBitInteger: Int16 = -16
let unsignedSixteenBitInteger: UInt16 = 16
let thirtyTwoBitInteger: Int32 = -32
let unsignedThirtyTwoBitInteger: UInt32 = 32
let sixtyFourBitInteger: Int64 = -64
let unsignedSixtyFourBitInteger: UInt64 = 64
let double: Double = 1.64
let float: Float = 1.32


var signed: Int = 1
var unsigned: UInt = 2
var floating: Double = double
//signed = unsigned // invalid
//unsigned = signed // invalid
//floating = float // invalid
signed = Int(unsigned)
unsigned = UInt(signed)
floating = Double(float)


// Every integer type has an initializer that will let you convert
//	any other numeric type into the desire type.
Int(unsignedInteger)			// unsigned int -> int
Int(cgFloat)					// CGFlooat -> int
Int(eightBitInteger)			// 8-bit int -> int
Int(unsignedEightBitInteger)	// unsigned 8-bit int -> int
Int(sixteenBitInteger)			// 16-bit int -> int
Int(unsignedSixteenBitInteger)	// unsigned 16-bit int -> int
Int(thirtyTwoBitInteger)

//let tooBigToFit = UInt8(300)	// error: 300 won't fit in a byte


// Numeric literals
let decimal = 123
let negative = -86
let hexadecimal = 0xa113cafe
let octal = 0o557
let binary = 0b10110110
let floating_point = 1.5
let float_with_exponent = 6.02214129e23
let hexadecimal_float = 0x2ff0.7p2
let leading_zeros = 000000099
let underscore_seperators = 23_000_000_000
let float_with_seperators = 6.022_141_29e23

extension Int {
	var casualName: String {
		switch self {
			case 0:
				return "no"
			case 1:
				return "just one"
			case 2:
				return "a couple"
			case 3:
				return "a few"
			default:
				return "many"
		}
	}
}

let number = 3
number.casualName


// Overflow and Underflow
let big = 999__999_999
let bigger = 9_999_999_999
//let wayTooBig = big * bigger <-- overflow



