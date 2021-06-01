/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatsCell.h"

#import "AgoraConvertToCommonEmoticonsHelper.h"
#import "AgoraConversationModel.h"
#import "UIImageView+HeadImage.h"

#define kLabelHeight 20.0
#define kTimeLabelWidth 80.0

@interface AgoraChatsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

//@property (weak, nonatomic)  UIImageView *headImageView;
//@property (weak, nonatomic)  UILabel *nameLabel;
//@property (weak, nonatomic)  UILabel *contentLabel;
//@property (weak, nonatomic)  UILabel *timeLabel;
//@property (weak, nonatomic)  UILabel *unreadLabel;

@property (strong, nonatomic) AgoraConversationModel *model;

@end

@implementation AgoraChatsCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_model.conversation.unreadMessagesCount == 0) {
        _unreadLabel.hidden = YES;
        _nameLabel.left = 75.f;
        _nameLabel.width = 170.f;
    } else {
        _unreadLabel.hidden = NO;
        _nameLabel.left = 95.f;
        _nameLabel.width = 150.f;
        _unreadLabel.text = [NSString stringWithFormat:@"%d",_model.conversation.unreadMessagesCount];
    }
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self placeAndLayoutSubViews];
//    }
//    return self;
//}

- (void)placeAndLayoutSubViews {
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(kAgroaPadding);
        make.size.mas_equalTo(50.0);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(kAgroaPadding);
        make.size.mas_equalTo(50.0);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(kAgroaPadding);
        make.size.mas_equalTo(50.0);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(kAgroaPadding);
        make.size.mas_equalTo(50.0);
    }];
    
    [self.unreadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.mas_equalTo(kAgroaPadding);
        make.size.mas_equalTo(50.0);
    }];
    
    
    
}

- (void)setConversationModel:(AgoraConversationModel *)model
{
    _model = model;
    if (model.conversation.type == AgoraConversationTypeChat) {
        [_headImageView imageWithUsername:model.conversation.conversationId placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        _headImageView.image = [UIImage imageNamed:@"default_group_avatar"];
    }
    _nameLabel.text = model.title;
    _contentLabel.text = [self _latestMessageTitleWithConversation:model.conversation];
    _timeLabel.text = [self _latestMessageTimeWithConversation:model.conversation];
    
    if (_model.conversation.unreadMessagesCount == 0) {
        _unreadLabel.hidden = YES;
//        _nameLabel.left = 75.f;
//        _nameLabel.width = 170.f;
    } else {
        _unreadLabel.hidden = NO;
//        _nameLabel.left = 95.f;
//        _nameLabel.width = 150.f;
        _unreadLabel.text = [NSString stringWithFormat:@"%d",_model.conversation.unreadMessagesCount];
    }
    
}

#pragma mark - private

- (NSString *)_latestMessageTitleWithConversation:(AgoraConversation *)conversation
{
    NSString *latestMessageTitle = @"";
    Message *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        MessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case MessageBodyTypeImage:{
                latestMessageTitle = NSLocalizedString(@"chat.image1", @"[image]");
            } break;
            case MessageBodyTypeText:{
                latestMessageTitle = [AgoraConvertToCommonEmoticonsHelper convertToSystemEmoticons:((TextMessageBody *)messageBody).text];
            } break;
            case MessageBodyTypeVoice:{
                latestMessageTitle = NSLocalizedString(@"chat.voice1", @"[voice]");
            } break;
            case MessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"chat.location1", @"[location]");
            } break;
            case MessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"chat.video1", @"[video]");
            } break;
            case MessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"chat.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

- (NSString *)_latestMessageTimeWithConversation:(AgoraConversation*)conversation
{
    NSString *latestMessageTime = @"";
    Message *lastMessage = [conversation latestMessage];;
    if (lastMessage) {
        double timeInterval = lastMessage.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        latestMessageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return latestMessageTime;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//#pragma mark getter and setter
//- (UIImageView *)headImageView {
//    if (_headImageView == nil) {
//        _headImageView = UIImageView.new;
//        _headImageView.contentMode = UIViewContentModeCenter;
//    }
//    return  _headImageView;
//}
//
//- (UILabel *)nameLabel {
//    if (_nameLabel == nil) {
//        _nameLabel = UILabel.new;
//        _nameLabel.textColor = UIColor.blackColor;
//        _nameLabel.font = [UIFont systemFontOfSize:13.0];
//        _nameLabel.textAlignment = NSTextAlignmentLeft;
//    }
//    return  _nameLabel;
//}
//
//- (UILabel *)contentLabel {
//    if (_contentLabel == nil) {
//        _contentLabel = UILabel.new;
//        _contentLabel.textColor = UIColor.blackColor;
//        _contentLabel.font = [UIFont systemFontOfSize:13.0];
//        _contentLabel.textAlignment = NSTextAlignmentLeft;
//    }
//    return  _contentLabel;
//}
//
//
//- (UILabel *)timeLabel {
//    if (_timeLabel == nil) {
//        _timeLabel = UILabel.new;
//        _timeLabel.textColor = UIColor.blackColor;
//        _timeLabel.font = [UIFont systemFontOfSize:11.0];
//        _timeLabel.textAlignment = NSTextAlignmentRight;
//    }
//    return  _timeLabel;
//}
//
//
//- (UILabel *)unreadLabel {
//    if (_unreadLabel == nil) {
//        _unreadLabel = UILabel.new;
//        _unreadLabel.textColor = UIColor.blackColor;
//        _unreadLabel.font = [UIFont systemFontOfSize:10.0];
//        _unreadLabel.textAlignment = NSTextAlignmentCenter;
//    }
//    return  _unreadLabel;
//}

@end
