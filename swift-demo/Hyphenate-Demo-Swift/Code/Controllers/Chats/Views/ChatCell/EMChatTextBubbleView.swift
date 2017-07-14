//
//  EMChatTextBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/22.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

let LABEL_FONT_SIZE: CGFloat = 11
let BUBBLE_VIEW_PAGGING: CGFloat = 12
let TEXTLABEL_MAX_WIDTH: CGFloat = 200
let LABEL_LINESPACE: CGFloat = 4


class EMChatTextBubbleView: EMChatBaseBubbleView {
    lazy var textLabel: UILabel = {()-> UILabel in
        let _label = UILabel()
        _label.numberOfLines = 0
        _label.lineBreakMode = NSLineBreakMode.byCharWrapping
        _label.font = UIFont.systemFont(ofSize: LABEL_FONT_SIZE)
        _label.textColor = AlmostBlackColor
        _label.backgroundColor = UIColor.clear
        _label.isUserInteractionEnabled = false
        _label.textAlignment = NSTextAlignment.left
        return _label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(textLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var textLabelFrame = bounds
        textLabelFrame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width - 2 * BUBBLE_VIEW_PAGGING, height: frame.size.height - 2 * BUBBLE_VIEW_PAGGING)
        textLabelFrame.origin.x = BUBBLE_VIEW_PAGGING
        textLabelFrame.origin.y = BUBBLE_VIEW_PAGGING
        textLabel.frame = textLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textBlockMinSize = CGSize(width: TEXTLABEL_MAX_WIDTH, height: CGFloat.greatestFiniteMagnitude)
        var retSize = CGSize.zero
        let text = (_model?.message?.body as! EMTextMessageBody).text as NSString
        let paragraphStype = NSMutableParagraphStyle()
        paragraphStype.lineSpacing = EMChatTextBubbleView.lineSpacing()
        retSize = (text.boundingRect(with: textBlockMinSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:EMChatTextBubbleView.textLabelFont(),NSParagraphStyleAttributeName:paragraphStype], context: nil) as CGRect).size
        
        let height = 2 * BUBBLE_VIEW_PAGGING + retSize.height
        let width = 2 * BUBBLE_VIEW_PAGGING + retSize.width
        
        return CGSize(width: width, height: height)
    }
    
    
    override func set(model: EMMessageModel) {
        super.set(model: model)
        _model = model
        let text = (_model?.message?.body as! EMTextMessageBody).text as NSString
        let paragraphStype = NSMutableParagraphStyle()
        paragraphStype.lineSpacing = EMChatTextBubbleView.lineSpacing()
        let attributeString = NSMutableAttributedString(string: text as String)
        attributeString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStype, range: NSMakeRange(0, text.length))
        textLabel.textColor = _model?.message?.direction == EMMessageDirectionSend ? WhiteColor : AlmostBlackColor
        textLabel.attributedText = attributeString
    }
    
    class func heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat {
        let textBlockMinSize = CGSize(width: TEXTLABEL_MAX_WIDTH, height: CGFloat.greatestFiniteMagnitude)
        var retSize = CGSize.zero
        let text = (model.message?.body as! EMTextMessageBody).text as NSString
        let paragraphStype = NSMutableParagraphStyle()
        paragraphStype.lineSpacing = EMChatTextBubbleView.lineSpacing()
        retSize = (text.boundingRect(with: textBlockMinSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:EMChatTextBubbleView.textLabelFont(),NSParagraphStyleAttributeName:paragraphStype], context: nil) as CGRect).size
        
        return 2 * BUBBLE_VIEW_PAGGING + retSize.height
    }
    
    class func lineSpacing() -> CGFloat{
        return LABEL_LINESPACE
    }
    
    class func textLabelFont() -> UIFont{
        return UIFont.systemFont(ofSize: LABEL_FONT_SIZE)
    }
}
