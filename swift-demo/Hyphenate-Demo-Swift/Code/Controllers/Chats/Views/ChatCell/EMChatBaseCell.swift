//
//  EMChatBaseCell.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/22.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate

let HEAD_PADDING: CGFloat = 15
let TIME_PADDING: CGFloat = 45
let BOTTOM_PADDING: CGFloat = 16
let NICK_PADDING: CGFloat = 20
let NICK_LEFT_PADDING: CGFloat = 57

@objc protocol EMChatBaseCellDelegate {
    func didHeadImagePressed(model: EMMessageModel)
    func didTextCellPressed(model: EMMessageModel)
    func didImageCellPressed(model: EMMessageModel)
    func didAudioCellPressed(model: EMMessageModel)
    func didVideoCellPressed(model: EMMessageModel)
    func didLocationCellPressed(model: EMMessageModel)
    func didCellLongPressed(cell: EMChatBaseCell)
    func didResendButtonPressed(model: EMMessageModel)
}

class EMChatBaseCell: UITableViewCell, EMChatBaseBubbleViewDelegate {

    weak var delegate: EMChatBaseCellDelegate?
    var _model: EMMessageModel?
    var _bubbleView: EMChatBaseBubbleView?
    
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readLabel: UILabel!
    @IBOutlet weak var resendButton: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var checkView: UIImageView!
    @IBOutlet weak var notDeliveredLabel: UILabel!
    @IBOutlet weak var nickLabel: UILabel!

    class func chatBaseCell(withMessageModel model: EMMessageModel) -> EMChatBaseCell {
        let baseCell = Bundle.main.loadNibNamed("EMChatBaseCell", owner: nil, options: nil)?.first as! EMChatBaseCell
        baseCell._setupBubbleView(model: model)
        
        return baseCell
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let isSend = _model!.message!.direction == EMMessageDirectionSend
        headImageView.left(left: isSend ? CGFloat(width() - headImageView.width() - HEAD_PADDING) : HEAD_PADDING)
        timeLabel.left(left: isSend ? width() - timeLabel.width() - TIME_PADDING : TIME_PADDING)
        timeLabel.top(top: height() - BOTTOM_PADDING)
        timeLabel.textAlignment = isSend ? NSTextAlignment.right : NSTextAlignment.left
        
        nickLabel.left(left: isSend ? width() - nickLabel.width() - NICK_LEFT_PADDING : NICK_LEFT_PADDING)
    
        _bubbleView?.left(left: isSend ? width() - (_bubbleView?.width())! - TIME_PADDING : TIME_PADDING)
        _bubbleView?.top(top: isSend ? 5: NICK_PADDING + 5)
        
        readLabel.left(left: kScreenWidth - 135)
        readLabel.top(top: height() - BOTTOM_PADDING)
        checkView.left(left: kScreenWidth - 151)
        checkView.top(top: height() - BOTTOM_PADDING)
        resendButton.top(top: (_bubbleView?.top())! + ((_bubbleView?.height())! - resendButton.height()) / 2)
        resendButton.left(left: (_bubbleView?.left())! - 25)
        activityView.top(top: (_bubbleView?.top())! + ((_bubbleView?.height())! - resendButton.height()) / 2)
        activityView.left(left: (_bubbleView?.left())! - 25)
        notDeliveredLabel.top(top: height() - CGFloat(BOTTOM_PADDING))
        notDeliveredLabel.left(left: width() - notDeliveredLabel.width() - 15)
        
        _setViewsDisplay()
    }
    
    // MARK: - EMChatBaseBubbleViewDelegate
    func didBubbleViewPressed(model: EMMessageModel) {
        if delegate != nil {
            switch model.message!.body.type {
            case EMMessageBodyTypeText:
                delegate?.didTextCellPressed(model: model)
                break
            case EMMessageBodyTypeImage:
                delegate?.didImageCellPressed(model: model)
                break
            case EMMessageBodyTypeVoice:
                delegate?.didAudioCellPressed(model: model)
                break
            case EMMessageBodyTypeVideo:
                delegate?.didVideoCellPressed(model: model)
                break
            case EMMessageBodyTypeLocation:
                delegate?.didLocationCellPressed(model: model)
                break
            default: break
                
            }
        }
    }
    
    func didBubbleViewLongPressed() {
        if delegate != nil {
            delegate?.didCellLongPressed(cell: self)
        }
    }
    
    // MARK: - Actions
    func didHeadImageSelected(sender: AnyObject) {
        if delegate != nil {
            delegate?.didHeadImagePressed(model: _model!)
        }
    }
    
    @IBAction func didResendButtonPressed(_ sender: UIButton) {
        if delegate != nil {
            delegate?.didResendButtonPressed(model: _model!)
        }
    }
    
    func _setupBubbleView(model: EMMessageModel) {
        _model = model
        switch _model!.message!.body.type {
        case EMMessageBodyTypeText:
            _bubbleView = EMChatTextBubbleView()
            break
        case EMMessageBodyTypeImage:
            _bubbleView = EMChatImageBubbleView()
            break
        case EMMessageBodyTypeVideo:
            _bubbleView = EMChatVideoBubbleView()
        case EMMessageBodyTypeLocation:
            _bubbleView = EMChatLocationBubbleView()
            break
        case EMMessageBodyTypeVoice:
            _bubbleView = EMChatAudioBubbleView()
            break
        default: break
            
        }
        
        _bubbleView?.delegate = self
        contentView.addSubview(_bubbleView!)
    }
    
    func _getMessageTime(message:EMMessage) -> String {
        var timeIntervar = message.timestamp
        if timeIntervar > 140000000000 {
            timeIntervar = timeIntervar / 1000
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: Date.init(timeIntervalSince1970: Double(timeIntervar)))
    }
    
    func _setViewsDisplay() {
        timeLabel.isHidden = false
        if _model!.message!.direction == EMMessageDirectionSend {
            if _model!.message!.status == EMMessageStatusFailed || _model!.message!.status == EMMessageStatusPending {
                notDeliveredLabel.text = "Not Delivered"
                checkView.isHidden = true
                readLabel.isHidden = true
                timeLabel.isHidden = true
                activityView.isHidden = true
                resendButton.isHidden = false
                notDeliveredLabel.isHighlighted = false
            }else if (_model!.message!.status == EMMessageStatusSuccessed) {
                if _model!.message!.isReadAcked {
                    readLabel.text = "Read"
                    checkView.isHidden = false
                } else {
                    readLabel.text = "Sent"
                    checkView.isHidden = true
                }
                
                resendButton.isHidden = true
                notDeliveredLabel.isHidden = true
                activityView.isHidden = true
                readLabel.isHidden = false
            }else if (_model!.message!.status == EMMessageStatusDelivering) {
                activityView.isHidden = true
                readLabel.isHidden = true
                checkView.isHidden = true
                resendButton.isHidden = true
                notDeliveredLabel.isHidden = true
                activityView.isHidden = false
                activityView.startAnimating()
            }
            nickLabel.isHidden = true
        } else {
            activityView.isHidden = true
            readLabel.isHidden = true
            checkView.isHidden = true
            resendButton.isHidden = true
            notDeliveredLabel.isHidden = true
            nickLabel.isHidden = false
        }
        
        if _model!.message!.chatType != EMChatTypeChat {
            checkView.isHidden = true
            readLabel.isHidden = true
        }
    }
    
    // MARK: - Public
    func set(model: EMMessageModel){
        _model = model
        _bubbleView?.set(model: model)
        _bubbleView?.sizeToFit()
        
        headImageView.imageWithUsername(username: (model.message?.from)!, placeholderImage: UIImage(named:"default_avatar"))
        timeLabel.text = _getMessageTime(message: model.message!)
        nickLabel.text = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: (model.message?.from)!)
    }
    
    class func height(forMessageModel model: EMMessageModel) -> CGFloat{
        var height: CGFloat = 100;
        switch model.message!.body.type {
        case EMMessageBodyTypeText:
            height = EMChatTextBubbleView.heightForBubble(withMessageModel: model)
            break
        case EMMessageBodyTypeImage:
            height = EMChatImageBubbleView.heightForBubble(withMessageModel: model)
            break
        case EMMessageBodyTypeVideo:
            height = EMChatVideoBubbleView.heightForBubble(withMessageModel: model)
            break
        case EMMessageBodyTypeLocation:
            height = EMChatLocationBubbleView.heightForBubble(withMessageModel: model)
            break
        case EMMessageBodyTypeVoice:
            height = EMChatAudioBubbleView.heightForBubble(withMessageModel: model)
            break
        default:
            break
        }
        
        if model.message?.direction == EMMessageDirectionReceive {
            return height + NICK_PADDING + 26
        }
        
        return height + 26
    }
    
    class func cellIdentifier(forMessageModel model: EMMessageModel) -> String {
        var identifier = "MessageCell"
        switch model.message!.body.type {
        case EMMessageBodyTypeText:
            identifier = identifier + "Text"
            break
        case EMMessageBodyTypeImage:
            identifier = identifier + "Image"
            break
        case EMMessageBodyTypeVoice:
            identifier = identifier + "Audio"
            break
        case EMMessageBodyTypeLocation:
            identifier = identifier + "Location"
            break
        case EMMessageBodyTypeVideo:
            identifier = identifier + "Video"
            break
        default:
            break
        }

        return identifier
    }
    
}
