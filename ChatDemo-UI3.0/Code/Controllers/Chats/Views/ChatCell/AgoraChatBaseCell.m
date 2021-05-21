/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatBaseCell.h"

#import "AgoraChatBaseBubbleView.h"
#import "AgoraChatTextBubbleView.h"
#import "AgoraChatImageBubbleView.h"
#import "AgoraChatAudioBubbleView.h"
#import "AgoraChatVideoBubbleView.h"
#import "AgoraChatLocationBubbleView.h"
#import "AgoraMessageModel.h"
#import "UIImageView+HeadImage.h"
#import "AgoraUserProfileManager.h"

#define HEAD_PADDING 15.f
#define TIME_PADDING 45.f
#define BOTTOM_PADDING 16.f
#define NICK_PADDING 20.f
#define NICK_LEFT_PADDING 57.f

@interface AgoraChatBaseCell () <AgoraChatBaseBubbleViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *readLabel;
@property (weak, nonatomic) IBOutlet UILabel *nickLable;
@property (weak, nonatomic) IBOutlet UILabel *notDeliveredLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkView;
@property (weak, nonatomic) IBOutlet UIButton *resendButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

@property (strong, nonatomic) AgoraChatBaseBubbleView *bubbleView;

@property (strong, nonatomic) AgoraMessageModel *model;

- (IBAction)didResendButtonPressed:(id)sender;

@end

@implementation AgoraChatBaseCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithMessageModel:(AgoraMessageModel *)model
{
    self = (AgoraChatBaseCell*)[[[NSBundle mainBundle]loadNibNamed:@"AgoraChatBaseCell" owner:nil options:nil] firstObject];
    if (self) {
        [self _setupBubbleView:model];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeadImageSelected:)];
        self.headImageView.userInteractionEnabled = YES;
        [self.headImageView addGestureRecognizer:tap];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _headImageView.left = _model.message.direction == MessageDirectionSend ? (self.width - _headImageView.width - HEAD_PADDING) : HEAD_PADDING;
    
    _timeLabel.left = _model.message.direction == MessageDirectionSend ? (self.width - _timeLabel.width - TIME_PADDING) : TIME_PADDING;
    _timeLabel.top = self.height - BOTTOM_PADDING;
    _timeLabel.textAlignment = _model.message.direction == MessageDirectionSend ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    _nickLable.left = _model.message.direction == MessageDirectionSend ? (self.width - _nickLable.width - NICK_LEFT_PADDING) : NICK_LEFT_PADDING;
    
    _bubbleView.left = _model.message.direction == MessageDirectionSend ? (self.width - _bubbleView.width - TIME_PADDING) : TIME_PADDING;
    _bubbleView.top = _model.message.direction == MessageDirectionSend ? 5.f : NICK_PADDING + 5;
    
    _readLabel.left = KScreenWidth - 135;
    _readLabel.top = self.height - BOTTOM_PADDING;
    _checkView.left = KScreenWidth - 151;
    _checkView.top = self.height - BOTTOM_PADDING;
    _resendButton.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _resendButton.left = _bubbleView.left - 25.f;
    _activityView.top = _bubbleView.top + (_bubbleView.height - _resendButton.height)/2;
    _activityView.left = _bubbleView.left - 25.f;
    _notDeliveredLabel.top = self.height - BOTTOM_PADDING;
    _notDeliveredLabel.left = self.width - _notDeliveredLabel.width - 15.f;
    
    [self _setViewsDisplay];
}

#pragma mark - AgoraChatBaseBubbleViewDelegate

- (void)didBubbleViewPressed:(AgoraMessageModel *)model
{
    if (self.delegate) {
        switch (model.message.body.type) {
            case MessageBodyTypeText:
                if ([self.delegate respondsToSelector:@selector(didTextCellPressed:)]) {
                    [self.delegate didTextCellPressed:model];
                }
                break;
            case MessageBodyTypeImage:
                if ([self.delegate respondsToSelector:@selector(didImageCellPressed:)]) {
                    [self.delegate didImageCellPressed:model];
                }
                break;
            case MessageBodyTypeVoice:
                if ([self.delegate respondsToSelector:@selector(didAudioCellPressed:)]) {
                    [self.delegate didAudioCellPressed:model];
                }
                break;
            case MessageBodyTypeVideo:
                if ([self.delegate respondsToSelector:@selector(didVideoCellPressed:)]) {
                    [self.delegate didVideoCellPressed:model];
                }
                break;
            case MessageBodyTypeLocation:
                if ([self.delegate respondsToSelector:@selector(didLocationCellPressed:)]) {
                    [self.delegate didLocationCellPressed:model];
                }
                break;
            default:
                break;
        }
    }
}

- (void)didBubbleViewLongPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCellLongPressed:)]) {
        [self.delegate didCellLongPressed:self];
    }
}

#pragma mark - action

- (void)didHeadImageSelected:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didHeadImagePressed:)]) {
        [self.delegate didHeadImagePressed:self.model];
    }
}

- (IBAction)didResendButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didResendButtonPressed:)]) {
        [self.delegate didResendButtonPressed:self.model];
    }
}

#pragma mark - private

- (void)_setupBubbleView:(AgoraMessageModel*)model
{
    _model = model;
    switch (model.message.body.type) {
        case MessageBodyTypeText:
            _bubbleView = [[AgoraChatTextBubbleView alloc] init];
            break;
        case MessageBodyTypeImage:
            _bubbleView = [[AgoraChatImageBubbleView alloc] init];
            break;
        case MessageBodyTypeVoice:
            _bubbleView = [[AgoraChatAudioBubbleView alloc] init];
            break;
        case MessageBodyTypeVideo:
            _bubbleView = [[AgoraChatVideoBubbleView alloc] init];
            break;
        case MessageBodyTypeLocation:
            _bubbleView = [[AgoraChatLocationBubbleView alloc] init];
            break;
        default:
            _bubbleView = [[AgoraChatTextBubbleView alloc] init];
            break;
    }
    _bubbleView.delegate = self;
    [self.contentView addSubview:_bubbleView];
}

- (NSString *)_getMessageTime:(Message*)message
{
    NSString *messageTime = @"";
    if (message) {
        double timeInterval = message.timestamp ;
        if(timeInterval > 140000000000) {
            timeInterval = timeInterval / 1000;
        }
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM-dd HH:mm"];
        messageTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval]];
    }
    return messageTime;
}

- (void)_setViewsDisplay
{
    _timeLabel.hidden = NO;
    if (_model.message.direction == MessageDirectionSend) {
        if (_model.message.status == MessageStatusFailed || _model.message.status == MessageStatusPending) {
            _notDeliveredLabel.text = NSLocalizedString(@"chat.not.delivered", @"Not Delivered");
            _checkView.hidden = YES;
            _readLabel.hidden = YES;
            _timeLabel.hidden = YES;
            _activityView.hidden = YES;
            _resendButton.hidden = NO;
            _notDeliveredLabel.hidden = NO;
            
        } else if (_model.message.status == MessageStatusSucceed) {
            if (_model.message.isReadAcked) {
                _readLabel.text = NSLocalizedString(@"chat.read", @"Read");
                _checkView.hidden = NO;
            } else {
                _readLabel.text = NSLocalizedString(@"chat.sent", @"Sent");
                _checkView.hidden = YES;
            }
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = YES;
            _readLabel.hidden = NO;
        } else if (_model.message.status == MessageStatusDelivering) {
            _activityView.hidden = YES;
            _readLabel.hidden = YES;
            _checkView.hidden = YES;
            _resendButton.hidden = YES;
            _notDeliveredLabel.hidden = YES;
            _activityView.hidden = NO;
            [_activityView startAnimating];
        }
        _nickLable.hidden = YES;
    } else {
        _activityView.hidden = YES;
        _readLabel.hidden = YES;
        _checkView.hidden = YES;
        _resendButton.hidden = YES;
        _notDeliveredLabel.hidden = YES;
        _nickLable.hidden = NO;
    }
    
    if (_model.message.chatType != AgoraChatTypeChat) {
        _checkView.hidden = YES;
        _readLabel.hidden = YES;
    }
}

#pragma mark - public

- (void)setMessageModel:(AgoraMessageModel *)model
{
    _model = model;
    
    [_bubbleView setModel:_model];
    [_bubbleView sizeToFit];
    
    [_headImageView imageWithUsername:model.message.from placeholderImage:[UIImage imageNamed:@"default_avatar"]];
    _timeLabel.text = [self _getMessageTime:model.message];
    _nickLable.text = [[AgoraUserProfileManager sharedInstance] getNickNameWithUsername:model.message.from];
}

+ (CGFloat)heightForMessageModel:(AgoraMessageModel *)model
{
    CGFloat height = 100.f;
    switch (model.message.body.type) {
        case MessageBodyTypeText:
            height = [AgoraChatTextBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case MessageBodyTypeImage:
            height = [AgoraChatImageBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case MessageBodyTypeLocation:
            height = [AgoraChatLocationBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case MessageBodyTypeVoice:
            height = [AgoraChatAudioBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        case MessageBodyTypeVideo:
            height = [AgoraChatVideoBubbleView heightForBubbleWithMessageModel:model] + 26.f;
            break;
        default:
            break;
    }
    if (model.message.direction == MessageDirectionReceive) {
        return height + NICK_PADDING;
    }
    return height;
}

+ (NSString *)cellIdentifierForMessageModel:(AgoraMessageModel *)model
{
    NSString *identifier = @"MessageCell";
    if (model.message.direction == MessageDirectionSend) {
        identifier = [identifier stringByAppendingString:@"Sender"];
    }
    else{
        identifier = [identifier stringByAppendingString:@"Receiver"];
    }
    
    switch (model.message.body.type) {
        case MessageBodyTypeText:
            identifier = [identifier stringByAppendingString:@"Text"];
            break;
        case MessageBodyTypeImage:
            identifier = [identifier stringByAppendingString:@"Image"];
            break;
        case MessageBodyTypeVoice:
            identifier = [identifier stringByAppendingString:@"Audio"];
            break;
        case MessageBodyTypeLocation:
            identifier = [identifier stringByAppendingString:@"Location"];
            break;
        case MessageBodyTypeVideo:
            identifier = [identifier stringByAppendingString:@"Video"];
            break;
        default:
            break;
    }
    
    return identifier;
}

@end
