//
//  EMApplyRequestCell.swift
//  Hyphenate-Demo-Swift
//
//  Created by 杜洁鹏 on 2017/6/26.
//  Copyright © 2017年 杜洁鹏. All rights reserved.
//

import UIKit

typealias ApplyCallBack = (_ model: EMApplyModel) -> Void

class EMApplyRequestCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var declineApply: ApplyCallBack?
    var acceptApply: ApplyCallBack?
    
    var _model: EMApplyModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryType = UITableViewCellAccessoryType.none
        selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setAccept(_ callBack: @escaping ApplyCallBack){
        acceptApply = callBack
    }
    
    func setDecline(_ callBack: @escaping ApplyCallBack) {
        declineApply = callBack
    }
    
    func set(model: EMApplyModel) {
        _model = model
        var defaultImage = "default_avatar.png"
        if _model?.style == EMApplyStype.contact {
            titleLabel.text = _model?.applyNickName
        }else {
            defaultImage = "default_group_avatar.png"
            titleLabel.text = (_model?.groupSubject?.characters.count)! > 0 ? _model?.groupSubject : _model?.groupId
            if _model?.style == EMApplyStype.joinGroup {
                titleLabel.text = "\(String(describing: _model?.applyNickName))" + "wants to join"
            }
        }
        
        avatarImageView.image = UIImage(named:defaultImage)
        if _model?.style == EMApplyStype.groupInvitation {
            acceptButton.setImage(UIImage(named:"Button_Join.png"), for: UIControlState.normal)
        }else {
            acceptButton.setImage(UIImage(named:"Button_Accept.png"), for: UIControlState.normal)
        }
    }
    
    @IBAction func AcceptAction(_ sender: UIButton) {
        
        acceptApply!(_model!)
    }
    
    @IBAction func declineAction(_ sender: UIButton) {
        declineApply!(_model!)
    }
}
