//
//  EMChatBaseBubbleView.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/22.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

@objc protocol EMChatBaseBubbleViewDelegate {
    @objc optional
    func didBubbleViewPressed(model: EMMessageModel)
    func didBubbleViewLongPressed()
}

class EMChatBaseBubbleView: UIView {
    var _backImageView: UIImageView?
    var _model: EMMessageModel?
    weak var delegate: EMChatBaseBubbleViewDelegate?
    
    public func heightForBubble(withMessageModel model: EMMessageModel) -> CGFloat{
        return 100
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _backImageView = UIImageView()
        _backImageView?.isUserInteractionEnabled = true
        _backImageView?.isMultipleTouchEnabled = true
        _backImageView?.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(_backImageView!)
        _backImageView?.backgroundColor = PaleGrayColor
        _backImageView?.layer.cornerRadius = 10
        backgroundColor = UIColor.clear
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bubbleViewPressed(sender:)))
        addGestureRecognizer(tap)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(bubbleViewLongPressed(sender:)))
        lpgr.minimumPressDuration = 0.5
        addGestureRecognizer(lpgr)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(model: EMMessageModel) {
        _model = model
        _backImageView?.backgroundColor = _model!.message!.direction == EMMessageDirectionSend ? KermitGreenTwoColor : PaleGrayColor
    }
    
    // MARK: - Actions
    func bubbleViewPressed(sender: UITapGestureRecognizer) {
        if delegate != nil {
            delegate!.didBubbleViewPressed!(model: _model!)
        }
    }
    
    func bubbleViewLongPressed(sender: UILongPressGestureRecognizer) {
        if delegate != nil && sender.state == UIGestureRecognizerState.began{
            delegate!.didBubbleViewLongPressed()
        }
    }
}
