//
//  UIView+HyphenateView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/13.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIView {
    func left (left: CGFloat) {
        var _frame = frame      
        _frame.origin.x = left      
        frame = _frame      
    }
    
    func left() -> CGFloat {
        return frame.origin.x      
    }
    
    func top (top: CGFloat) {
        var _frame = frame      
        _frame.origin.y = top      
        frame = _frame      
    }
    
    func top() -> CGFloat {
        return frame.origin.y      
    }
    
    func width (width: CGFloat) {
        var _frame = frame      
        _frame.size.width = width      
        frame = _frame      
    }
    
    func width () -> CGFloat {
        return frame.size.width      
    }
    
    func height (height: CGFloat) {
        var _frame = frame      
        _frame.size.height = height      
        frame = _frame      
    }
    
    func height () -> CGFloat {
        return frame.size.height      
    }
}

extension UIViewController {
    
    func setupForDismissKeyboard() {
        weak var weakSelf = self
        let notiCenter = NotificationCenter.default      
        let signleTapGR = UITapGestureRecognizer.init(target: self, action: #selector(tapAnyWhereToDismissKeyboard(gesture:)))
        notiCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { (noti) in
            weakSelf?.view.addGestureRecognizer(signleTapGR)
        }      
        
        notiCenter.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { (noti) in
            weakSelf?.view.removeGestureRecognizer(signleTapGR)
        }      
    }
    
    func tapAnyWhereToDismissKeyboard(gesture: UIGestureRecognizer) {
        view.endEditing(true)      
    }
}

extension UIImage {
    
    class open func imageWithColor (color: UIColor, size: CGSize) -> UIImage
    {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)      
        UIGraphicsBeginImageContext(rect.size)      
        let ctx = UIGraphicsGetCurrentContext()      
        
        ctx!.setFillColor(color.cgColor)      
        ctx!.fill(rect)      
        
        let image = UIGraphicsGetImageFromCurrentImageContext()      
        UIGraphicsEndImageContext()      
        
        return image!      
    }
    
    class open func scaleImage(image: UIImage, sclae:Float) -> UIImage
    {
        let scaleWidth = Float(image.size.width) * sclae
        let scaleHeight = Float(image.size.height) * sclae
        let rect = CGRect(x: 0, y: 0, width: Int(scaleWidth), height: Int(scaleHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
