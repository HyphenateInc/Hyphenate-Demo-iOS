//
//  EMMessageTextView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/19.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit

class EMMessageTextView: UITextView {
 
    var placeHolder: NSString?
    var placeHolderTextColor: UIColor?

    
    // MARK: - setter
    func set(placeHolder ph: NSString) {
        if ph == placeHolder {
            return
        }
        
        let maxChats = EMMessageTextView.maxChatactersPerLine()
        if ph.length > maxChats {
            placeHolder = ph.substring(to: maxChats - 8) as NSString
            placeHolder = (placeHolder!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) as NSString).appending("...") as NSString
        }
        
        placeHolder = ph
        setNeedsDisplay()
    }
    
    func set(plcaeHolderTextColor color: UIColor) {
        if color == placeHolderTextColor {
            return
        }
        
        placeHolderTextColor = color
        setNeedsDisplay()
    }
    
    // MARK: - Message text view
    func numberOfLinesOfText() -> Int {
        return EMMessageTextView.numberOfLines(forMessage: text)
    }
    
    
    // class func
    class func maxChatactersPerLine() -> Int {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone ? 33 : 109
    }
    
    class func numberOfLines(forMessage message: String) -> Int {
        return (message.characters.count / EMMessageTextView.maxChatactersPerLine()) + 1
    }
    
    // MARK: - text view overrides
    func set(text txt: String?) {
        text = txt
        setNeedsDisplay()
    }
    
    func set(attributedText attTxt: NSAttributedString) {
        attributedText = attTxt
        setNeedsDisplay()
    }
    
    func set(font txtFont: UIFont) {
        font = txtFont
        setNeedsDisplay()
    }
    
    func set(textAlignment txtAlignment: NSTextAlignment) {
        textAlignment = txtAlignment
        setNeedsDisplay()
    }
    
    // MARK: - Notifications
    func didReceive(textDidChangeNotification: Notification) {
        setNeedsDisplay()
    }
    
    func setup() { // TODO du: oc demo never used this method.
        NotificationCenter.default.addObserver(self, selector: #selector(didReceive(textDidChangeNotification:)), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        
        placeHolderTextColor = UIColor.lightGray
        autoresizingMask = [.flexibleWidth]
        scrollIndicatorInsets = UIEdgeInsetsMake(10, 0, 10, 8)
        contentInset = UIEdgeInsets.zero
        isScrollEnabled = true
        scrollsToTop = false
        isUserInteractionEnabled = true
        font = UIFont.systemFont(ofSize: 16)
        textColor = UIColor.black
        backgroundColor = UIColor.white
        keyboardAppearance = UIKeyboardAppearance.default
        keyboardType = UIKeyboardType.default
        textAlignment = NSTextAlignment.left
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
         // setup()
    }
    
    deinit {
        placeHolder = nil
        placeHolderTextColor = nil
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.characters.count == 0 && placeHolder != nil {
            let placeHoldeRect = CGRect.init(x: 10, y: 7, width: rect.size.width, height: rect.size.height)
            placeHolderTextColor?.set()
            
            let paragraphStype = NSMutableParagraphStyle()
            paragraphStype.lineBreakMode = NSLineBreakMode.byTruncatingTail
            paragraphStype.alignment = textAlignment
            
            placeHolder?.draw(in: placeHoldeRect, withAttributes: [NSFontAttributeName: font!, NSForegroundColorAttributeName: placeHolderTextColor!,
                                                                   NSParagraphStyleAttributeName: paragraphStype])
        }
    }
}
