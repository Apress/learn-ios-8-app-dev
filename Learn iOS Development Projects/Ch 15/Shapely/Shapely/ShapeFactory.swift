//
//  ShapeFactory.swift
//  Shapely
//
//  Created by James Bucanek on 10/7/14.
//  Copyright (c) 2014 Apress. All rights reserved.
//

import UIKit


class ShapeFactory: NSObject {
    
    @IBOutlet var view: ShapeView! = nil
    @IBOutlet var dblTapGesture: UITapGestureRecognizer! = nil
    @IBOutlet var trplTapGesture: UITapGestureRecognizer! = nil
    
    class func nibNameForShape(shape: ShapeSelector) -> String {
        switch shape {
            case .Rectangle, .Oval:
                return "RectangleShape"
            default:
                return "SquareShape"
        }
    }
    
    func load(# shape: ShapeSelector, inViewController viewController: UIViewController) -> ShapeView {
        let placeholders = [ "viewController": viewController ]
        let options = [ UINibExternalObjects: placeholders ]
        NSBundle.mainBundle().loadNibNamed( ShapeFactory.nibNameForShape(shape),
                                     owner: self,
                                   options: options)
        assert(view != nil, "shape view not connected in xib file")
        view.shape = shape
        dblTapGesture.requireGestureRecognizerToFail(trplTapGesture)
        
        return view!
    }
}
