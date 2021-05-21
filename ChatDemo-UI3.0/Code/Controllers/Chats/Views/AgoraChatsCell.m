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
#import "AgoraUserProfileManager.h"
#import "UIImageView+HeadImage.h"

@interface AgoraChatsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *unreadLabel;

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

@end
