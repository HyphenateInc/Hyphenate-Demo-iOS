/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMContactCell.h"
#import "EMUserModel.h"

@interface EMContactCell()
@property (strong, nonatomic) IBOutlet UIImageView *avatarImage;
@property (strong, nonatomic) IBOutlet UILabel *nicknameLabel;

@end

@implementation EMContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)setModel:(EMUserModel *)model {
    if (_model != model) {
        _model = model;
    }
    _nicknameLabel.text = _model.nickname;
    _avatarImage.image = _model.defaultAvatarImage;
    if (_model.avatarURLPath.length > 0) {
        [_avatarImage sd_setImageWithURL:[NSURL URLWithString:_model.avatarURLPath] placeholderImage:_model.defaultAvatarImage];
    }
    else {
        _avatarImage.image = _model.defaultAvatarImage;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
