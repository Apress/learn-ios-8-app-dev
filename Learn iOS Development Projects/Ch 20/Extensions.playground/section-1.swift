// Playground - Extensions
//

import UIKit


class MyWhatsit {
	var name: String
	var location: String
	var image: UIImage?
	
	init( name: String, location: String = "" ) {
		self.name = name;
		self.location = location
	}
}

//
// Extensions add new properties or functions to an existing type
//

extension MyWhatsit {
	var viewImage: UIImage? {
		return image ?? UIImage(named: "camera")
	}
}

var thing = MyWhatsit(name: "Robby the Robot")if thing.viewImage?.size.width > 100.0 {
}



// Extensions can add methods and properties to types you
//	didn't even write or have the source code to.

extension String {
	var inKlingon: String { return self == "Hello" ? "nuqneH" : "nuqjatlh?" }
}

"Hello".inKlingon
"Anything else".inKlingon
