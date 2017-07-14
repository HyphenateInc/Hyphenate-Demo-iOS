//
//  EMChatImageBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/23.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

let MAX_SIZE: CGFloat = 250

class EMChatImageBubbleView: EMChatBaseBubbleView {
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
        contentMode = UIViewContentMode.scaleAspectFill
        layer.cornerRadius = 10
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var retSize: CGSize = CGSize.zero
        let body = _model?.message?.body as! EMImageMessageBody
        if _model?.message?.ext != nil {
            retSize = CGSize(width: 0, height: MAX_SIZE / 4 * 3)
        }else {
            retSize = body.size
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
        let body = _model?.message?.body as! EMImageMessageBody
        
        if body.thumbnailLocalPath.characters.count > 0 {
            _backImageView?.image = UIImage.init(contentsOfFile: body.thumbnailLocalPath)
            return
        }
        
        if model.thumbnailImage != nil {
            _backImageView?.image = model.thumbnailImage
            return
        }
        
        let imgData = NSData(contentsOfFile: body.localPath)
        if imgData != nil {
            let image = UIImage.init(data: imgData! as Data)!
            var sclae = 1.0
            if image.size.width > 1000 * 10 || image.size.height > 1000 * 10 {
                sclae = 0.1
            }
             model.thumbnailImage = UIImage.scaleImage(image: UIImage.init(data: imgData! as Data)!, sclae: Float(sclae))
            _backImageView?.image = model.thumbnailImage
        }
    }
    
    class func heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat {
        var retSize: CGSize = CGSize.zero
        let body = model.message?.body as! EMImageMessageBody
        if model.message?.ext != nil {
            retSize = CGSize(width: 0, height: MAX_SIZE / 4 * 3)
        }else {
            retSize = body.size
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
