//
//  EMContactDetailedTableViewCell.m
//  Pods
//
//  Created by Jerry Wu on 6/15/16.
//
//

#import "EMContactDetailedTableViewCell.h"

#import "EaseImageView.h"
#import "UIImageView+EMWebCache.h"
#import <Hyphenate/Hyphenate.h>
#import "UIColor+EaseUI.h"

@implementation EMContactDetailedTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.avatarView.imageCornerRadius = 0;
    
    UILongPressGestureRecognizer *headerLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerLongPress:)];
    [self addGestureRecognizer:headerLongPress];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    if (self.avatarView.badge) {
        self.avatarView.badgeBackgroudColor = [UIColor redColor];
    }
}

#pragma mark - private layout subviews

- (void)setUserModel:(id<IUserModel>)userModel
{
    _userModel = userModel;
    
    if ([_userModel.nickname length] > 0) {
        self.titleLabel.text = _userModel.nickname;
    }
    else{
        self.titleLabel.text = _userModel.username;
    }
    
    if ([_userModel.avatarURLPath length] > 0){
        [self.avatarView.imageView sd_setImageWithURL:[NSURL URLWithString:_userModel.avatarURLPath] placeholderImage:_userModel.avatarImage];
    }
    else {
        if (_userModel.avatarImage) {
            self.avatarView.image = _userModel.avatarImage;
        }
    }
    
    self.avatarView.badge = userModel.unreadMessageCount;
    self.avatarView.badgeSize = 32;
    self.avatarView.badgeBackgroudColor = [UIColor EUPrimaryColor];
}

- (void)setConversationModel:(id<IConversationModel>)conversationModel
{
    _conversationModel = conversationModel;
    
    if ([_conversationModel.title length] > 0) {
        self.titleLabel.text = _conversationModel.title;
    }
    else{
        self.titleLabel.text = _conversationModel.conversation.conversationId;
    }
    
    if (self.showAvatar) {
        if ([_conversationModel.avatarURLPath length] > 0){
            [self.avatarView.imageView sd_setImageWithURL:[NSURL URLWithString:_conversationModel.avatarURLPath] placeholderImage:_conversationModel.avatarImage];
        } else {
            if (_conversationModel.avatarImage) {
                self.avatarView.image = _conversationModel.avatarImage;
            }
        }
    }
    
    if (_conversationModel.conversation.unreadMessagesCount == 0) {
        _avatarView.showBadge = NO;
    }
    else{
        _avatarView.showBadge = YES;
        _avatarView.badge = _conversationModel.conversation.unreadMessagesCount;
    }
}

//- (void)setTitleLabelFont:(UIFont *)titleLabelFont
//{
//    _titleLabelFont = titleLabelFont;
//    _titleLabel.font = _titleLabelFont;
//}
//
//- (void)setTitleLabelColor:(UIColor *)titleLabelColor
//{
//    _titleLabelColor = titleLabelColor;
//    _titleLabel.textColor = _titleLabelColor;
//}

#pragma mark - action

- (void)headerLongPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        if(_delegate && _indexPath && [_delegate respondsToSelector:@selector(cellLongPressAtIndexPath:)]) {
            [_delegate cellLongPressAtIndexPath:self.indexPath];
        }
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (self.avatarView.badge) {
        self.avatarView.badgeBackgroudColor = [UIColor redColor];
    }
}


+ (NSString *)cellIdentifier
{
    return @"EMContactDetailedTableViewCell";
}

@end
