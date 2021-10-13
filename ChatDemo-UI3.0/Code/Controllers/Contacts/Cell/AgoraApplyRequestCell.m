/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraApplyRequestCell.h"
#import "AgoraApplyModel.h"
#import "AgoraApplyManager.h"

@interface AgoraApplyRequestCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UILabel *tiitleLabel;

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UIButton *acceptButton;

@end

@implementation AgoraApplyRequestCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryNone;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setModel:(AgoraApplyModel *)model {
    _model = model;
    NSString *defaultImageName = @"default_avatar.png";
    if (_model.style == AgoraApplyStyle_contact) {
        _descriptionLabel.hidden = YES;
        _tiitleLabel.text = _model.applyNickName;
    }
    else {
        defaultImageName = @"default_group_avatar.png";
        _descriptionLabel.hidden = NO;
        _tiitleLabel.text = _model.groupSubject.length > 0 ? _model.groupSubject : _model.groupId;
        _descriptionLabel.text = [NSString stringWithFormat:@"%ld %@",(long)_model.groupMemberCount,NSLocalizedString(@"title.memberList", @"Member List")];
        if (_model.style == AgoraApplyStyle_joinGroup) {
            _descriptionLabel.text = [NSString stringWithFormat:@"%@ wants to join",_model.applyNickName];
        }
    }
    _avatarImageView.image = [UIImage imageNamed:defaultImageName];
    if (_model.style > AgoraApplyStyle_joinGroup) {
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Join.png"] forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Join.png"] forState:UIControlStateNormal];
    }
    else {
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Accept.png"] forState:UIControlStateNormal];
        [_acceptButton setImage:[UIImage imageNamed:@"Button_Accept.png"] forState:UIControlStateNormal];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)declineAction:(UIButton *)sender {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (_model.style) {
        case AgoraApplyStyle_contact:
        {
            [[AgoraChatClient sharedClient].contactManager declineFriendRequestFromUser:_model.applyHyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];

            break;
        }
        case AgoraApplyStyle_joinGroup:
        {
            [[AgoraChatClient sharedClient].groupManager declineJoinGroupRequest:_model.groupId sender:_model.applyHyphenateId reason:nil completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];
            break;
        }
        default:
        {
            [[AgoraChatClient sharedClient].groupManager declineGroupInvitation:_model.groupId inviter:_model.applyHyphenateId reason:nil completion:^(AgoraChatError *aError) {
                [weakSelf declineApplyFinished:aError];
            }];
            break;
        }
    }
}


- (IBAction)acceptAction:(id)sender {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    switch (_model.style) {
        case AgoraApplyStyle_contact:
        {
            [[AgoraChatClient sharedClient].contactManager approveFriendRequestFromUser:_model.applyHyphenateId completion:^(NSString *aUsername, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
        case AgoraApplyStyle_joinGroup:
        {
            [[AgoraChatClient sharedClient].groupManager approveJoinGroupRequest:_model.groupId sender:_model.applyHyphenateId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
        default:
        {
            [[AgoraChatClient sharedClient].groupManager acceptInvitationFromGroup:_model.groupId inviter:_model.applyHyphenateId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                [weakSelf acceptApplyFinished:aError];
            }];
            break;
        }
    }
}

- (void)declineApplyFinished:(AgoraChatError *)error {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[AgoraApplyManager defaultManager] removeApplyRequest:_model];
        if (self.declineApply) {
            self.declineApply(_model);
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"contact.refusedFailure", @"Refused to apply for failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

- (void)acceptApplyFinished:(AgoraChatError *)error {
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    if (!error) {
        [[AgoraApplyManager defaultManager] removeApplyRequest:_model];
        if (self.acceptApply) {
            self.acceptApply(_model);
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"contact.agreeFailure", @"Failed to agree to apply") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
}

@end
