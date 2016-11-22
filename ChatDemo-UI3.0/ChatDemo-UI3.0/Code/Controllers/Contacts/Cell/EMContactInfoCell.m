/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMContactInfoCell.h"

@interface EMContactInfoCell()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *infoLabel;

@property (strong, nonatomic) IBOutlet UISwitch *blockSwitch;



@end

@implementation EMContactInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setInfoDic:(NSDictionary *)infoDic {
    if (_infoDic != infoDic) {
        _infoDic = infoDic;
    }
    if ([self.reuseIdentifier isEqualToString:@"EMContact_Info_Cell"]) {
        _titleLabel.text = [_infoDic.allKeys lastObject];
        _infoLabel.text = [_infoDic.allValues lastObject];
    }
    else {
        _blockSwitch.hidden = NO;
        _titleLabel.text = [_infoDic.allKeys lastObject];
        _titleLabel.textColor = (UIColor *)[_infoDic.allValues lastObject];
        if ([_titleLabel.text isEqualToString:NSLocalizedString(@"contact.delete", @"Delete Contact")]) {
            _blockSwitch.hidden = YES;
        }
    }
}
- (IBAction)blockContactAction:(id)sender {
    if (_hyphenateId.length == 0) {
        return;
    }
    WEAK_SELF
    if (_blockSwitch.isOn) {
        [[EMClient sharedClient].contactManager addUserToBlackList:_hyphenateId
                                                        completion:^(NSString *aUsername, EMError *aError) {
                                                            if (!aError) {
                                                                if (weakSelf.delegate &&
                                                                    [weakSelf.delegate respondsToSelector:@selector(needRefreshContactsFromServer:)])
                                                                {
                                                                    [weakSelf.delegate needRefreshContactsFromServer:NO];
                                                                }
                                                            }
                                                            else {
                                                                [weakSelf showAlertWithMessage:NSLocalizedString(@"contact.blockFailure", @"Block failure")];
                                                            }
                                                        }];
    } else {
        [[EMClient sharedClient].contactManager removeUserFromBlackList:_hyphenateId
                                                             completion:^(NSString *aUsername, EMError *aError) {
                                                                 if (!aError) {
                                                                     if (weakSelf.delegate &&
                                                                         [weakSelf.delegate respondsToSelector:@selector(needRefreshContactsFromServer:)])
                                                                     {
                                                                         [weakSelf.delegate needRefreshContactsFromServer:YES];
                                                                     }
                                                                 }
                                                                 else {
                                                                     [weakSelf showAlertWithMessage:NSLocalizedString(@"contact.unblockFailure", @"Unblock failure")];
                                                                 }
                                                             }];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
