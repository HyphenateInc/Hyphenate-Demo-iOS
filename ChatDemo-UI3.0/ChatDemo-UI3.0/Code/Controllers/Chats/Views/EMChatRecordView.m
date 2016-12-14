/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatRecordView.h"

#import <AVFoundation/AVFoundation.h>
#import "EMCDDeviceManager.h"

@interface EMChatRecordView ()
{
    NSTimer *_recordTimer;
    int _recordLength;
}

@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

- (IBAction)recordButtonTouchDown:(id)sender;
- (IBAction)recordButtonTouchUpOutside:(id)sender;
- (IBAction)recordButtonTouchUpInside:(id)sender;
- (IBAction)recordDragOutside:(id)sender;
- (IBAction)recordDragInside:(id)sender;

@end

@implementation EMChatRecordView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.width = KScreenWidth;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _recordButton.left = (KScreenWidth - _recordButton.width)/2;
    _timeLabel.width = KScreenWidth;
    _recordLabel.width = KScreenWidth;
}

- (void)startTimer
{
    _timeLabel.hidden = NO;
    _recordLength = 0;
    _recordTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(recordTimerAction) userInfo:nil repeats:YES];
}

- (void)endTimer
{
    _timeLabel.hidden = YES;
    _timeLabel.text = @"00:0";
    [_recordTimer invalidate];
}

- (void)resetView
{
    _recordLabel.text = NSLocalizedString(@"chat.hold.record", "Hold to record");
    _recordLabel.textColor = SteelGreyColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record"] forState:UIControlStateNormal];
    self.backgroundColor = PaleGrayColor;
    [self endTimer];
}

#pragma mark - action

- (IBAction)recordButtonTouchDown:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.send", @"Release to send");
    _recordLabel.textColor = OrangeRedColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record active"] forState:UIControlStateNormal];
    [self startTimer];
    
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
         if (error) {
             
         }
     }];
}

- (IBAction)recordButtonTouchUpOutside:(id)sender
{
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
    [self resetView];
}

- (IBAction)recordButtonTouchUpInside:(id)sender
{
    [self resetView];
    WEAK_SELF
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didFinishRecord:duration:)]) {
                [weakSelf.delegate didFinishRecord:recordPath duration:aDuration];
            }
        }
    }];
}

- (IBAction)recordDragOutside:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.cancel", @"Release to cancel");
    _recordLabel.textColor = WhiteColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record cancel"] forState:UIControlStateNormal];
    self.backgroundColor = BlueyGreyColor;
}

- (IBAction)recordDragInside:(id)sender
{
    _recordLabel.text = NSLocalizedString(@"chat.release.send", @"Release to send");
    _recordLabel.textColor = OrangeRedColor;
    [_recordButton setImage:[UIImage imageNamed:@"Button_Record active"] forState:UIControlStateNormal];
    self.backgroundColor = PaleGrayColor;
}

- (void)recordTimerAction
{
    _recordLength += 1;
    int hour = _recordLength / 3600;
    int m = (_recordLength - hour * 3600) / 60;
    int s = _recordLength - hour * 3600 - m * 60;
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        _timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

#pragma mark - private

- (BOOL)_canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                bCanRecord = granted;
            }];
        }
    }
    
    return bCanRecord;
}

@end
