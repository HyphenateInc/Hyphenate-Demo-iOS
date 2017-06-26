//
//  HyphenateTextField.swift
//  Hyphenate Messenger
//
//  Created by peng wan on 9/10/16.
//  Copyright © 2016 Hyphenate Inc. All rights reserved.
//

import UIKit
import CoreGraphics

class HyphenateTextField: UITextField {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.borderColor = UIColor(red: 214.0/255.0, green: 214.0/255.0, blue: 217.0/255.0, alpha: 1.0).cgColor
        layer.borderWidth = 1.0
        backgroundColor = UIColor.white
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 15, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 15, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 15, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
}
