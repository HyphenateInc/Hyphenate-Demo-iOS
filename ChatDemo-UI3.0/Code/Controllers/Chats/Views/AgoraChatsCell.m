//
//  AgoraChatsCellNew.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatsCell.h"
#import "AgoraConvertToCommonEmoticonsHelper.h"
#import "AgoraConversationModel.h"
#import "UIImageView+HeadImage.h"

#define kLabelHeight 20.0
#define kTimeLabelWidth 80.0
#define kUnReadLabelHeight 20.0
#define kHeadImageViewHeight 50.0

@interface AgoraChatsCell ()

@property (strong, nonatomic)  UIImageView *headImageView;
@property (strong, nonatomic)  UILabel *nameLabel;
@property (strong, nonatomic)  UILabel *contentLabel;
@property (strong, nonatomic)  UILabel *timeLabel;
@property (strong, nonatomic)  UILabel *unreadLabel;
@property (strong, nonatomic) AgoraConversationModel *model;

@end

@implementation AgoraChatsCell

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
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.unreadLabel];

    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView);
        make.left.mas_equalTo(kAgroaPadding * 2);
        make.size.mas_equalTo(kHeadImageViewHeight);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView).offset(-kAgroaPadding);
        make.left.mas_equalTo(self.headImageView.mas_right).offset(kAgroaPadding);
        make.right.equalTo(self.timeLabel.mas_left).offset(-kAgroaPadding * 0.5);
        make.height.mas_equalTo(20.0);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom);
        make.left.equalTo(self.nameLabel);
        make.right.equalTo(self.unreadLabel.mas_left).offset(-kAgroaPadding * 0.5);
        make.height.equalTo(self.nameLabel);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.nameLabel);
        make.right.equalTo(self.contentView).offset(-kAgroaPadding *2);
        make.width.mas_equalTo(80.0f);
        make.height.equalTo(self.nameLabel);
    }];
    
    [self.unreadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentLabel);
        make.right.equalTo(self.timeLabel);
        make.width.mas_equalTo(kUnReadLabelHeight);
        make.height.mas_equalTo(kUnReadLabelHeight);
    }];
    
}

- (void)setConversationModel:(AgoraConversationModel *)model
{
    _model = model;
    if (model.conversation.type == AgoraChatConversationTypeChat) {
        [_headImageView imageWithUsername:model.conversation.conversationId placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    } else {
        _headImageView.image = [UIImage imageNamed:@"default_group_avatar"];
    }
    _nameLabel.text = model.title;
    _contentLabel.text = [self _latestMessageContentWithConversation:model.conversation];
    _timeLabel.text = [self _latestMessageTimeWithConversation:model.conversation];
    
    if (_model.conversation.unreadMessagesCount == 0) {
        _unreadLabel.hidden = YES;
    } else {
        _unreadLabel.hidden = NO;
        if (_model.conversation.unreadMessagesCount >= 99) {
            _unreadLabel.text = @"99+";
        }else {
            _unreadLabel.text = [NSString stringWithFormat:@"%d",_model.conversation.unreadMessagesCount];
        }
    }
    
}

#pragma mark - private

- (NSString *)_latestMessageContentWithConversation:(AgoraChatConversation *)conversation
{
    NSString *latestMessageTitle = @"";
    AgoraChatMessage *lastMessage = [conversation latestMessage];
    if (lastMessage) {
        AgoraChatMessageBody *messageBody = lastMessage.body;
        switch (messageBody.type) {
            case AgoraChatMessageBodyTypeImage:{
                latestMessageTitle = NSLocalizedString(@"chat.image1", @"[image]");
            } break;
            case AgoraChatMessageBodyTypeText:{
                latestMessageTitle = [AgoraConvertToCommonEmoticonsHelper convertToSystemEmoticons:((AgoraChatTextMessageBody *)messageBody).text];
            } break;
            case AgoraChatMessageBodyTypeVoice:{
                latestMessageTitle = NSLocalizedString(@"chat.voice1", @"[voice]");
            } break;
            case AgoraChatMessageBodyTypeLocation: {
                latestMessageTitle = NSLocalizedString(@"chat.location1", @"[location]");
            } break;
            case AgoraChatMessageBodyTypeVideo: {
                latestMessageTitle = NSLocalizedString(@"chat.video1", @"[video]");
            } break;
            case AgoraChatMessageBodyTypeFile: {
                latestMessageTitle = NSLocalizedString(@"chat.file1", @"[file]");
            } break;
            default: {
            } break;
        }
    }
    return latestMessageTitle;
}

- (NSString *)_latestMessageTimeWithConversation:(AgoraChatConversation*)conversation
{
    NSString *latestMessageTime = @"";
    AgoraChatMessage *lastMessage = [conversation latestMessage];;
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
}

#pragma mark getter and setter
- (UIImageView *)headImageView {
    if (_headImageView == nil) {
        _headImageView = UIImageView.new;
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.clipsToBounds = YES;
        _headImageView.layer.cornerRadius = kHeadImageViewHeight * 0.5;
    }
    return  _headImageView;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = UILabel.new;
        _nameLabel.textColor = UIColor.blackColor;
        _nameLabel.font = [UIFont systemFontOfSize:13.0];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
    }
    return  _nameLabel;
}

- (UILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = UILabel.new;
        _contentLabel.textColor = BlueyGreyColor;
        _contentLabel.font = [UIFont systemFontOfSize:13.0];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
    }
    return  _contentLabel;
}


- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = UILabel.new;
        _timeLabel.textColor = BlueyGreyColor;
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return  _timeLabel;
}


- (UILabel *)unreadLabel {
    if (_unreadLabel == nil) {
        _unreadLabel = UILabel.new;
        _unreadLabel.textColor = UIColor.whiteColor;
        _unreadLabel.font = [UIFont systemFontOfSize:10.0];
        _unreadLabel.textAlignment = NSTextAlignmentCenter;
        _unreadLabel.layer.cornerRadius = kUnReadLabelHeight * 0.5;
        _unreadLabel.clipsToBounds = YES;
        _unreadLabel.backgroundColor = KermitGreenTwoColor;
    }
    return  _unreadLabel;
}

@end

#undef kLabelHeight
#undef kTimeLabelWidth
#undef kUnReadLabelHeight
#undef kHeadImageViewHeight
