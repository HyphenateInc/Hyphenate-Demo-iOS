//
//  EMChatLocationBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/26.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

let LOCATION_IMAGEVIEW_SIZE: CGFloat = 95

class EMChatLocationBubbleView: EMChatBaseBubbleView {
    var addressLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        _backImageView?.image = UIImage(named:"Location")
        addressLabel = UILabel()
        addressLabel?.textColor = AlmostBlackColor
        addressLabel?.font = UIFont.systemFont(ofSize: LABEL_FONT_SIZE)
        addressLabel?.numberOfLines = 0
        addressLabel?.backgroundColor = UIColor.clear
        _backImageView?.addSubview(addressLabel!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textBlockMinSize: CGSize = CGSize(width: 95, height: 25)
        let body = _model?.message?.body as! EMLocationMessageBody
        let addressSize = (body.address!.boundingRect(with: textBlockMinSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:addressLabel!.font], context: nil) as CGRect).size

        let width = addressSize.width < LOCATION_IMAGEVIEW_SIZE ? LOCATION_IMAGEVIEW_SIZE : addressSize.width
        
        return CGSize(width: width, height: LOCATION_IMAGEVIEW_SIZE)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addressLabel?.frame = CGRect(x: 5, y: (_backImageView?.height())! - 30, width: (_backImageView?.width())! - 30, height: 25)
    }
    
    override func set(model: EMMessageModel) {
        super.set(model: model)
        let body = _model?.message?.body as! EMLocationMessageBody
        addressLabel?.text = body.address
    }
    
    class func heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat {
        return 100
    }
}
