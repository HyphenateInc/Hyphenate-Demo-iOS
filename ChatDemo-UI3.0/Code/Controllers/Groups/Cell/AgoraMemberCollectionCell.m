/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraMemberCollectionCell.h"
#import "AgoraUserModel.h"

@interface AgoraMemberCollectionCell()

@property (strong, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (strong, nonatomic) IBOutlet UIImageView *deleteImageView;
@property (strong, nonatomic) IBOutlet UILabel *nicknamLabel;

@end

@implementation AgoraMemberCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([self.reuseIdentifier isEqualToString:@"AgoraMemberCollection_Edit_Cell"]) {
        _deleteImageView.hidden = YES;
    }
}

- (void)setModel:(AgoraUserModel *)model {
    if (_deleteImageView && [self.reuseIdentifier isEqualToString:@"AgoraMemberCollection_Edit_Cell"]) {
        _deleteImageView.hidden = NO;
    }
    _model = model;
    if (!_model) {
        _nicknamLabel.text = @"";
        _avatarImageView.image = [UIImage imageNamed:@"Button_Add Member.png"];
        return;
    }
    _nicknamLabel.text = _model.nickname;
    if (_model.avatarURLPath.length > 0) {
        NSURL *avatarUrl = [NSURL URLWithString:_model.avatarURLPath];
        [_avatarImageView sd_setImageWithURL:avatarUrl placeholderImage:_model.defaultAvatarImage];
    }
    else {
        _avatarImageView.image = _model.defaultAvatarImage;
    }
}

@end
