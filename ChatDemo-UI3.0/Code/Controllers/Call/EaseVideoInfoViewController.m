/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EaseVideoInfoViewController.h"

@interface EaseVideoInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLatencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *frameRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *lostRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *localBitrateLabel;
@property (weak, nonatomic) IBOutlet UILabel *remoteBitrateLabel;

@property (strong, nonatomic) NSTimer *propertyTimer;

@property (strong, nonatomic) NSTimer *timeTimer;

@property (strong, nonatomic) UITapGestureRecognizer *tap;

@end

@implementation EaseVideoInfoViewController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        

    }
    
    return self;
}

- (void)startShowInfo
{
    if (_callSession.type == EMCallTypeVideo) {
        
        [self _reloadPropertyData];
        _propertyTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(_reloadPropertyData) userInfo:nil repeats:YES];
        
    }
}

- (void)_reloadPropertyData
{
    if (_callSession) {
        
        _resolutionLabel.text = [NSString stringWithFormat:@"%d x %d px", (int)_callSession.remoteVideoResolution.width, (int)_callSession.remoteVideoResolution.height];
        
        _timeLatencyLabel.text = [NSString stringWithFormat:@"%i ms", _callSession.videoLatency];
        
        _frameRateLabel.text = [NSString stringWithFormat:@"%i fps", _callSession.remoteVideoFrameRate];
        
        _lostRateLabel.text = [NSString stringWithFormat:@"%i%%",_callSession.remoteVideoLostRateInPercent];
        
        _localBitrateLabel.text = [NSString stringWithFormat:@"%i KB", _callSession.localVideoBitrate];
        
        _remoteBitrateLabel.text = [NSString stringWithFormat:@"%i KB", _callSession.remoteVideoBitrate];

    }
}

- (UITapGestureRecognizer *)tap
{
    if (!_tap) {
        _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeVideoInfo)];
    }
    return _tap;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self startShowInfo];
    _timeLabel.text = _currentTime;
    _nameLabel.text = _callSession.remoteName;
    [self timeTimerAction:nil];
    [self.view addGestureRecognizer:self.tap];

}

- (void)closeVideoInfo
{
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)startTimer:(int)currentTimeLength
{
    _timeLength = currentTimeLength;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)displayTimeDuration:(int)timeDuration
{
    int hour = timeDuration / 3600;
    int min = (timeDuration - hour * 3600) / 60;
    int sec = timeDuration - hour * 3600 - min * 60;
    
    NSString *formatedHr = [self formatTimeWithPrefixZero:hour];
    NSString *formatedMin = [self formatTimeWithPrefixZero:min];
    NSString *formatedSec = [self formatTimeWithPrefixZero:sec];
    
    if (hour > 0) {
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@:%@", formatedHr, formatedMin, formatedSec];
    }
    else if (min > 0){
        _timeLabel.text = [NSString stringWithFormat:@"%@:%@", formatedMin, formatedSec];
    }
    else {
        _timeLabel.text = [NSString stringWithFormat:@"00:%@", formatedSec];
    }
}

- (NSString *)formatTimeWithPrefixZero:(int)digit {
    if (digit < 10) {
        return [NSString stringWithFormat:@"0%i", digit];
    }
    else {
        return [NSString stringWithFormat:@"%i", digit];
    }
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    [self displayTimeDuration:_timeLength];
}

@end
