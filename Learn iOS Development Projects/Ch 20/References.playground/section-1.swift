// Playground - Reference vs. Value

import UIKit



func pad(var # string: String, with char: Character, var # count: Int) -> String {
	while count > 0 {
		string.append(char)
		count--
	}
	return string
}


let originalString = "Yahoo"
let paddedString = pad(string: originalString, with: "!", count: 4)



func padSurPlace(inout # string: String, with char: Character, var # count: Int) -> String {
	while count > 0 {
		string.append(char)
		count--
	}
	return string
}


var mutableString = "Yahoo"
padSurPlace(string: &mutableString, with: "!", count: 3)
println(mutableString)

