//
//  EMChatVideoBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/23.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import SDWebImage

class EMChatVideoBubbleView: EMChatBaseBubbleView {
    var videoButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        contentMode = UIViewContentMode.scaleAspectFill
        layer.cornerRadius = 10
        
        videoButton = UIButton(type: UIButtonType.custom)
        videoButton.setBackgroundImage(UIImage(named:"Icon_Play"), for: UIControlState.normal)
        videoButton.isUserInteractionEnabled = false
        addSubview(videoButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoButton.frame = CGRect(x: (width() - 50) / 2, y: (height() - 50) / 2, width: 50, height: 50)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var retSize: CGSize = CGSize.zero
        let body = _model?.message?.body as! EMVideoMessageBody
        if _model?.message?.ext != nil {
            retSize = CGSize(width: 0, height: MAX_SIZE / 4 * 3)
        }else {
            retSize = body.thumbnailSize
        }
        
        if retSize.width == 0 || retSize.height == 0 {
            retSize = CGSize(width: MAX_SIZE, height: MAX_SIZE)
        }
        
        if retSize.width > retSize.height {
            let height = MAX_SIZE / retSize.width * retSize.height
            retSize.height = height
            retSize.width = MAX_SIZE
        } else {
            let width = MAX_SIZE / retSize.height * retSize.width
            retSize.height = MAX_SIZE
            retSize.width = width
        }
        
        return retSize
    }
    
    override func set(model: EMMessageModel) {
        super.set(model: model)
        let body = _model?.message?.body as! EMVideoMessageBody
        if body.thumbnailLocalPath != nil {
            let thumnailImageData = NSData.init(contentsOfFile: body.thumbnailLocalPath)
            if thumnailImageData != nil {
                _backImageView?.image = UIImage.init(data: thumnailImageData! as Data)
            }
        }else {
            _backImageView?.sd_setImage(with: URL.init(string: body.remotePath), placeholderImage: nil)
        }
    }
    
    class func heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat {
        var retSize: CGSize = CGSize.zero
        let body = model.message?.body as! EMVideoMessageBody
        if model.message?.ext != nil {
            retSize = CGSize(width: 0, height: MAX_SIZE / 4 * 3)
        }else {
            retSize = body.thumbnailSize
        }
        
        if retSize.width == 0 || retSize.height == 0 {
            retSize = CGSize(width: MAX_SIZE, height: MAX_SIZE)
        }
        
        if retSize.width > retSize.height {
            let height = MAX_SIZE / retSize.width * retSize.height
            retSize.height = height
            retSize.width = MAX_SIZE
        } else {
            let width = MAX_SIZE / retSize.height * retSize.width
            retSize.height = MAX_SIZE
            retSize.width = width
        }
        
        return retSize.height
    }
}
