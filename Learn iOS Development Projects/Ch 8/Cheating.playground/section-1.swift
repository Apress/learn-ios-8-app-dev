// Playground - noun: a place where people can play

import UIKit

class MyScoreController {
    var score = 0
    @IBOutlet var scoreView: UILabel!
    
    @IBAction func incrementScore(sender: AnyObject!) {
        score += 1
        scoreView.text = "\(score)"
    }
}
