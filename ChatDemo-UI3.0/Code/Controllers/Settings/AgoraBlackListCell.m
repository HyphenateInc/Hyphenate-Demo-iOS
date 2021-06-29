//
//  AgoraBlackListCell.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBlackListCell.h"
@interface AgoraBlackListCell ()
@property (strong, nonatomic)  UIImageView *headImageView;
@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UIButton *unBlockButton;
@property (strong, nonatomic)  NSString *unBlockUserId;

@end

@implementation AgoraBlackListCell
#pragma mark life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self placeAndLayoutSubViews];
    }
    return  self;
}

- (void)placeAndLayoutSubViews {
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.unBlockButton];
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kAgroaPadding);
        make.left.equalTo(self.contentView).offset(kAgroaPadding);
        make.size.mas_equalTo(46.0);
        make.bottom.mas_equalTo(-kAgroaPadding);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageView);
        make.left.equalTo(self.headImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.unBlockButton.mas_left).offset(-kAgroaPadding);
    }];
    
    [self.unBlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.headImageView);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding);
        make.width.mas_equalTo(70.0);
        make.height.mas_equalTo(40.0);
    }];
}

- (void)updateCellWithObj:(id)obj {
    NSString *userId = obj;
    self.nameLabel.text = userId;
    self.unBlockUserId = userId;
}



#pragma mark private method
- (void)unBlock {
    if (self.unBlockCompletion) {
        self.unBlockCompletion(self.unBlockUserId);
    }
}

#pragma mark getter and setter
- (UIImageView *)headImageView {
    if (_headImageView == nil) {
        _headImageView = UIImageView.new;
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.image = [UIImage imageNamed:@"default_avatar.png"];
    }
    return  _headImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = UILabel.new;
        _nameLabel.textColor = UIColor.blackColor;
        _nameLabel.font = [UIFont systemFontOfSize:14.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return  _nameLabel;
}

- (UIButton *)unBlockButton {
    if (_unBlockButton == nil) {
        _unBlockButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        [_unBlockButton setTitle:NSLocalizedString(@"contact.unblock", @"Unblock") forState:UIControlStateNormal];
        [_unBlockButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [_unBlockButton addTarget:self action:@selector(unBlock) forControlEvents:UIControlEventTouchUpInside];
        [_unBlockButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _unBlockButton.backgroundColor = [UIColor colorWithRed:79 / 255.0 green:175 / 255.0 blue:36 / 255.0 alpha:1.0];
        _unBlockButton.layer.cornerRadius = 5.0f;
    }
    return _unBlockButton;
}


@end
