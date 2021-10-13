/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatAudioBubbleView.h"

#import "DACircularProgressView.h"
#import "AgoraMessageModel.h"

#define TIMER_TI 0.04f

@interface AgoraChatAudioBubbleView ()

@property (strong, nonatomic) UIImageView *playView;
@property (strong, nonatomic) UILabel *durationLabel;

@property (strong, nonatomic) DACircularProgressView *progressView;
@property (assign, nonatomic) CGFloat progress;
@property (strong, nonatomic) NSTimer *playTimer;

@end

@implementation AgoraChatAudioBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.durationLabel];
        [self addSubview:self.playView];
        [self addSubview:self.progressView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _durationLabel.frame = CGRectMake(40.f, 12.f, 36.f, 11.f);
    _playView.frame = CGRectMake(5.f, 5.f, 25.f, 25.f);
}

#pragma mark - getter

- (UIImageView*)playView
{
    if (_playView == nil) {
        _playView = [[UIImageView alloc] init];
        _playView.image = [UIImage imageNamed:@"Icon_Play"];
        _playView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _playView;
}

- (UILabel*)durationLabel
{
    if (_durationLabel == nil) {
        _durationLabel = [[UILabel alloc] init];
        _durationLabel.font = [UIFont systemFontOfSize:11.f];
    }
    return _durationLabel;
}

- (DACircularProgressView*)progressView
{
    if (_progressView == nil) {
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake(5, 5, 25.f, 25.f)];
        _progressView.userInteractionEnabled = NO;
        _progressView.thicknessRatio = 0.2;
        _progressView.roundedCorners = NO;
    }
    return _progressView;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(79.f, 35.f);
}

- (void)setModel:(AgoraMessageModel *)model
{
    [super setModel:model];
    
    AgoraChatVoiceMessageBody *body = (AgoraChatVoiceMessageBody*)model.message.body;
    _durationLabel.text = [self formatDuration:body.duration];
    _durationLabel.textColor = model.message.direction == AgoraChatMessageDirectionSend ? WhiteColor : AlmostBlackColor;
    
    if (model.isPlaying) {
        [self startPlayAudio];
    } else {
        [self stopPlayAudio];
    }
}

#pragma mark - private

- (void)playAudio
{
    AgoraChatVoiceMessageBody *body = (AgoraChatVoiceMessageBody*)self.model.message.body;
    [_progressView setProgress:_progress animated:YES];
    _progress = _progress + 1/(body.duration/TIMER_TI);
    if (_progress >= 1) {
        [self stopPlayAudio];
    }
}

- (void)startPlayAudio
{
    _playTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_TI target:self selector:@selector(playAudio) userInfo:nil repeats:YES];
    _progressView.hidden = NO;
    _progress = 0;
    _playView.hidden = YES;
}

- (void)stopPlayAudio
{
    [_playTimer invalidate];
    _progressView.hidden = YES;
    _playView.hidden = NO;
}

- (NSString*)formatDuration:(int)timeDuration
{
    NSString *formatedDuration;

    int hour = timeDuration / 3600;
    int min = (timeDuration - hour * 3600) / 60;
    int sec = timeDuration - hour * 3600 - min * 60;
    
    NSString *formatedHr = [self formatTimeWithPrefixZero:hour];
    NSString *formatedMin = [self formatTimeWithPrefixZero:min];
    NSString *formatedSec = [self formatTimeWithPrefixZero:sec];
    
    if (hour > 0) {
        formatedDuration = [NSString stringWithFormat:@"%@:%@:%@", formatedHr, formatedMin, formatedSec];
    }
    else if (min > 0){
        formatedDuration = [NSString stringWithFormat:@"%@:%@", formatedMin, formatedSec];
    }
    else {
        formatedDuration = [NSString stringWithFormat:@"00:%@", formatedSec];
    }
    
    return formatedDuration;
}

- (NSString *)formatTimeWithPrefixZero:(int)digit {
    if (digit < 10) {
        return [NSString stringWithFormat:@"0%i", digit];
    }
    else {
        return [NSString stringWithFormat:@"%i", digit];
    }
}

+ (CGFloat)heightForBubbleWithMessageModel:(AgoraMessageModel *)model
{
    return 35.f;
}

@end
