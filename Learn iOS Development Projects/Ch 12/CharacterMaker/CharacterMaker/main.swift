//
//  main.swift
//  CharacterMaker
//
//  Created by James Bucanek on 9/1/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import Foundation

let image = "image"
let name = "name"
let description = "description"

let dataModel = [
	[	 name: "Alice",
		image: "char-alice",
  description: "Alice is seven and a half years old, quaintly logical, and resolutely independant. She's fond of sweets and books with pictures."],

	[	 name: "White Rabbit",
		image: "char-rabbit",
  description: "Perpetually late, the White Rabbit is the first character Alice sees. He's a nervous little fellow that does not like his house invaded by little girls, regardless of size."],

	[	 name: "The Dodo",
		image: "char-dodo",
  description: "An officious bird, the Dodo presides over the Caucus race, in which everyone wins, even Alice."],

	[	 name: "The Caterpillar",
		image: "char-caterpillar",
  description: "The Caterpillar is a hookah-smoking caterpilla exactly three inches high which, according to him, \"is a very good height indeed\" (though Alice believes it to be a wretched height)."],

	[	 name: "The Flamingo",
		image: "char-flamingo",
  description: "The chief difficulty Alice found at first was in managing her flamingo."],

	[	 name: "The Hatter",
		image: "char-madhatter",
  description: "Quite mad, the hatter and the March Hare were sentenced to perpetual tea time. He is fond of riddles and poetry."]
]

(dataModel as NSArray).writeToFile( "~/Desktop/Characters.nsarray".stringByExpandingTildeInPath,
						atomically: false)
