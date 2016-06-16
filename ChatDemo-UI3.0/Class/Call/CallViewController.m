/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "CallViewController.h"

#import "ChatDemoHelper.h"

@interface CallViewController ()
{
    __weak EMCallSession *_callSession;
    BOOL _isCaller;
    NSString *_status;
    int _timeLength;
    
    NSString * _audioCategory;
    
    UIView *_propertyView;
    UILabel *_sizeLabel;
    UILabel *_timedelayLabel;
    UILabel *_framerateLabel;
    UILabel *_lostcntLabel;
    UILabel *_remoteBitrateLabel;
    UILabel *_localBitrateLabel;
    NSTimer *_propertyTimer;
    UILabel *_networkLabel;
}

@property (strong, nonatomic) UITapGestureRecognizer *tapRecognizer;

@end

@implementation CallViewController

- (instancetype)initWithSession:(EMCallSession *)session
                       isCaller:(BOOL)isCaller
                         status:(NSString *)statusString
{
    self = [super init];
    
    if (self) {
        
        _callSession = session;
        _isCaller = isCaller;
        _timeLabel.text = @"";
        _timeLength = 0;
        _status = statusString;
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([ud valueForKey:kLocalCallBitrate] && _callSession.type == EMCallTypeVideo) {
            [session setVideoBitrate:[[ud valueForKey:kLocalCallBitrate] intValue]];
        }
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    [self _setupSubviews];
    
    self.nameLabel.text = _callSession.remoteUsername;
    self.statusLabel.text = _status;
    
    if (_isCaller) {
        self.rejectButton.hidden = YES;
        self.answerButton.hidden = YES;
        self.cancelButton.hidden = NO;
    }
    else {
        self.cancelButton.hidden = YES;
        self.rejectButton.hidden = NO;
        self.answerButton.hidden = NO;
    }
    
    if (_callSession.type == EMCallTypeVideo) {
        
        [self initializeVideoView];
        
        [self.view bringSubviewToFront:self.topView];
        [self.view bringSubviewToFront:self.actionView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma makr - property

- (UITapGestureRecognizer *)tapRecognizer
{
    if (_tapRecognizer == nil) {
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapAction:)];
    }
    
    return _tapRecognizer;
}


#pragma mark - subviews

- (void)_setupSubviews
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    self.navigationController.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    bgImageView.contentMode = UIViewContentModeScaleToFill;
    bgImageView.image = [UIImage imageNamed:@"callBg.png"];
    [self.view addSubview:bgImageView];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    self.topView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.topView];
    
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.topView.frame.size.width - 20, 20)];
    self.statusLabel.font = [UIFont systemFontOfSize:15.0];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:self.statusLabel];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.statusLabel.frame), self.topView.frame.size.width, 15)];
    _timeLabel.font = [UIFont systemFontOfSize:12.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:_timeLabel];
    
    _headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.topView.frame.size.width - 50) / 2, CGRectGetMaxY(self.statusLabel.frame) + 20, 50, 50)];
    _headerImageView.image = [UIImage imageNamed:@"user"];
    [self.topView addSubview:_headerImageView];
    
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_headerImageView.frame) + 5, self.topView.frame.size.width, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:14.0];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = _callSession.remoteUsername;
    [self.topView addSubview:self.nameLabel];
    
    _networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.nameLabel.frame) + 5, self.topView.frame.size.width, 20)];
    _networkLabel.font = [UIFont systemFontOfSize:14.0];
    _networkLabel.backgroundColor = [UIColor clearColor];
    _networkLabel.textColor = [UIColor whiteColor];
    _networkLabel.textAlignment = NSTextAlignmentCenter;
    _networkLabel.hidden = YES;
    [self.topView addSubview:_networkLabel];
    
    self.actionView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 260, self.view.frame.size.width, 260)];
    self.actionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.actionView];
    
    // Mute
    CGFloat tmpWidth = [UIScreen mainScreen].bounds.size.width;
    if (_callSession.type == EMCallTypeVideo) {
        self.silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 160) / 5 * 2 + 40, 80, 40, 40)];
    } else {
        self.silenceButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 80) / 3, 80, 40, 40)];
    }
    [self.silenceButton setImage:[UIImage imageNamed:@"call_silence"] forState:UIControlStateNormal];
    [self.silenceButton setImage:[UIImage imageNamed:@"call_silence_h"] forState:UIControlStateSelected];
    [self.silenceButton addTarget:self action:@selector(silenceAction) forControlEvents:UIControlEventTouchUpInside];
    [self.actionView addSubview:self.silenceButton];
    
    if (_callSession.type == EMCallTypeVideo) {
        self.speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth -160)/5*4+ 120, self.silenceButton.frame.origin.y, 40, 40)];

    } else {
        self.speakerOutButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 80)/3 * 2 + 40, self.silenceButton.frame.origin.y, 40, 40)];
    }
    [self.speakerOutButton setImage:[UIImage imageNamed:@"call_out"] forState:UIControlStateNormal];
    [self.speakerOutButton setImage:[UIImage imageNamed:@"call_out_h"] forState:UIControlStateSelected];
    [self.speakerOutButton addTarget:self action:@selector(speakerOutAction) forControlEvents:UIControlEventTouchUpInside];
    [self.actionView addSubview:self.speakerOutButton];
    
    // Reject Button
    int rejectButtonSize = 60;
    self.rejectButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 120) / 3, CGRectGetMaxY(_speakerOutButton.frame) + 20, rejectButtonSize, rejectButtonSize)];
    [self.rejectButton setImage:[UIImage imageNamed:@"call_end"] forState:UIControlStateNormal];
    [self.rejectButton setBackgroundColor:[UIColor HIRedColor]];
    [self.rejectButton addTarget:self action:@selector(rejectAction) forControlEvents:UIControlEventTouchUpInside];
    self.rejectButton.layer.cornerRadius = rejectButtonSize/2;
    self.rejectButton.layer.masksToBounds = YES;
    [self.actionView addSubview:self.rejectButton];
    
    // Answer Button
    int answerButtonSize = 60;
    self.answerButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 120) / 3 * 2 + 60, self.rejectButton.frame.origin.y, answerButtonSize, answerButtonSize)];
    [self.answerButton setImage:[UIImage imageNamed:@"call_pickup"] forState:UIControlStateNormal];
    [self.answerButton setBackgroundColor:[UIColor HIPrimaryColor]];
    [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
    self.answerButton.layer.cornerRadius = answerButtonSize/2;
    self.answerButton.layer.masksToBounds = YES;
    [self.actionView addSubview:self.answerButton];
    
    // Cancel Button
    int cancelButtonSize = 80;
    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - cancelButtonSize) / 2, self.rejectButton.frame.origin.y, cancelButtonSize, cancelButtonSize)];
    [self.cancelButton setImage:[UIImage imageNamed:@"call_end"] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundColor:[UIColor HIRedColor]];
    [self.cancelButton addTarget:self action:@selector(hangupAction) forControlEvents:UIControlEventTouchUpInside];
    self.cancelButton.layer.cornerRadius = cancelButtonSize/2;
    self.cancelButton.layer.masksToBounds = YES;
    [self.actionView addSubview:self.cancelButton];
    
    if (_callSession.type == EMCallTypeVideo) {
        
        CGFloat tmpWidth = [UIScreen mainScreen].bounds.size.width;
        int buttonWidth = 40;
        int buttonHeight = 40;
        int topMargin = 80;
        
        // Record Button
        self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth- 160)/5, topMargin, buttonWidth, buttonHeight)];
        self.recordButton.layer.cornerRadius = 6.0f;
        [self.recordButton setImage:[UIImage imageNamed:@"call_record_start"] forState:UIControlStateNormal];
        [self.recordButton setImage:[UIImage imageNamed:@"call_record_stop"] forState:UIControlStateSelected];
        [self.recordButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.recordButton setBackgroundColor:[UIColor clearColor]];
        [self.recordButton addTarget:self action:@selector(recordAction) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:self.recordButton];
        
        // Video Button
        self.videoButton = [[UIButton alloc] initWithFrame:CGRectMake((tmpWidth - 160)/5 * 3 +  80, topMargin, buttonWidth, buttonHeight)];
        self.videoButton.layer.cornerRadius = 6.0f;
        [self.videoButton setImage:[UIImage imageNamed:@"call_video_on"] forState:UIControlStateNormal];
        [self.videoButton setImage:[UIImage imageNamed:@"call_video_off"] forState:UIControlStateSelected];
        [self.videoButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        [self.videoButton setBackgroundColor:[UIColor clearColor]];
        [self.videoButton addTarget:self action:@selector(videoPauseAction) forControlEvents:UIControlEventTouchUpInside];
        self.videoButton.selected = YES;
        [self.actionView addSubview:self.videoButton];
    }
}

- (void)initializeVideoView
{
    // Recipient's window
    _callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:_callSession.remoteVideoView];
    
    // my window
    CGFloat width = 80;
    CGFloat height = self.view.frame.size.height / self.view.frame.size.width * width;
    _callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 90, CGRectGetMaxY(self.statusLabel.frame), width, height)];
    [self.view addSubview:_callSession.localVideoView];
    
    // call info
    _propertyView = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(self.actionView.frame) - 90, self.view.frame.size.width - 20, 90)];
    _propertyView.backgroundColor = [UIColor clearColor];
    _propertyView.hidden = NO;
    [self.view addSubview:_propertyView];
    
    width = (CGRectGetWidth(_propertyView.frame) - 20) / 2;
    height = CGRectGetHeight(_propertyView.frame) / 3;
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    _sizeLabel.backgroundColor = [UIColor clearColor];
    _sizeLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_sizeLabel];
    
    _timedelayLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, 0, width, height)];
    _timedelayLabel.backgroundColor = [UIColor clearColor];
    _timedelayLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_timedelayLabel];
    
    _framerateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height, width, height)];
    _framerateLabel.backgroundColor = [UIColor clearColor];
    _framerateLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_framerateLabel];
    
    _lostcntLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height, width, height)];
    _lostcntLabel.backgroundColor = [UIColor clearColor];
    _lostcntLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_lostcntLabel];
    
    _localBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, height * 2, width, height)];
    _localBitrateLabel.backgroundColor = [UIColor clearColor];
    _localBitrateLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_localBitrateLabel];
    
    _remoteBitrateLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, height * 2, width, height)];
    _remoteBitrateLabel.backgroundColor = [UIColor clearColor];
    _remoteBitrateLabel.textColor = [UIColor whiteColor];
    [_propertyView addSubview:_remoteBitrateLabel];
}


#pragma mark - private

- (void)showPropertyData
{
    if (_callSession) {
        
        _sizeLabel.text = [NSString stringWithFormat:@"%@%i/%i", NSLocalizedString(@"call.videoSize", @"Width/Height: "), [_callSession getVideoWidth], [_callSession getVideoHeight]];
        
        _timedelayLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoTimedelay", @"Time delay: "), [_callSession getVideoTimedelay]];
        
        _framerateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoFramerate", @"Framerate: "), [_callSession getVideoFramerate]];
        
        _lostcntLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLostcnt", @"Lost cnt: "), [_callSession getVideoLostcnt]];
        
        _localBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoLocalBitrate", @"Local Bitrate: "), [_callSession getVideoLocalBitrate]];
        
        _remoteBitrateLabel.text = [NSString stringWithFormat:@"%@%i", NSLocalizedString(@"call.videoRemoteBitrate", @"Remote Bitrate: "), [_callSession getVideoRemoteBitrate]];
    }
}

- (void)_beginRing
{
    [_ringPlayer stop];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    _ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [_ringPlayer setVolume:1];
    _ringPlayer.numberOfLoops = -1; //-1 is for infinite loop
    
    if([_ringPlayer prepareToPlay]) {
        [_ringPlayer play];
    }
}

- (void)stopRing
{
    [_ringPlayer stop];
}

- (void)timeTimerAction:(id)sender
{
    _timeLength += 1;
    int hour = _timeLength / 3600;
    int m = (_timeLength - hour * 3600) / 60;
    int s = _timeLength - hour * 3600 - m * 60;
    
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

#pragma mark - UITapGestureRecognizer

- (void)viewTapAction:(UITapGestureRecognizer *)tap
{
    self.topView.hidden = !self.topView.hidden;
    self.actionView.hidden = !self.actionView.hidden;
    _propertyView.hidden = !_propertyView.hidden;
}

#pragma mark - action

- (void)recordAction
{
    self.recordButton.selected = !self.recordButton.selected;
    if (self.recordButton.selected) {
        NSString *recordPath = NSHomeDirectory();
        recordPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer",recordPath];
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:recordPath]){
            [fm createDirectoryAtPath:recordPath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];
        }
        [_callSession startVideoRecord:recordPath];
    } else {
        NSString *tempPath = [_callSession stopVideoRecord];
        if (tempPath.length > 0) {
            //            NSURL *videoURL = [NSURL fileURLWithPath:tempPath];
            //            MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            //            [moviePlayerController.moviePlayer prepareToPlay];
            //            moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
            //            [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
        }
    }
}

- (void)videoPauseAction
{
    if (self.videoButton.selected) {
        [[EMClient sharedClient].callManager pauseVideoTransfer:_callSession.sessionId];
    }
    else {
        [[EMClient sharedClient].callManager resumeVideoTransfer:_callSession.sessionId];
    }
    self.videoButton.selected = !self.videoButton.selected;
}

- (void)voicePauseAction
{
    if (self.voiceButton.selected) {
        [[EMClient sharedClient].callManager pauseVoiceAndVideoTransfer:_callSession.sessionId];
    }
    else {
        [[EMClient sharedClient].callManager resumeVoiceAndVideoTransfer:_callSession.sessionId];
    }
    self.voiceButton.selected = !self.voiceButton.selected;

}

- (void)silenceAction
{
    self.silenceButton.selected = !self.silenceButton.selected;
    [[EMClient sharedClient].callManager markCallSession:_callSession.sessionId isSilence:self.silenceButton.selected];
}

- (void)speakerOutAction
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.speakerOutButton.selected = !self.speakerOutButton.selected;
}

- (void)answerAction
{
#if DEMO_CALL == 1
    
    [self stopRing];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    _audioCategory = audioSession.category;
    if(![_audioCategory isEqualToString:AVAudioSessionCategoryPlayAndRecord]){
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
    
    [[ChatDemoHelper shareHelper] answerCall];
#endif
}

- (void)hangupAction
{
#if DEMO_CALL == 1
    
    [_timeTimer invalidate];
    [self stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
    [audioSession setActive:YES error:nil];
    
    [[ChatDemoHelper shareHelper] hangupCallWithReason:EMCallEndReasonHangup];
#endif
}

- (void)rejectAction
{
#if DEMO_CALL == 1
    [_timeTimer invalidate];
    [self stopRing];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:_audioCategory error:nil];
    [audioSession setActive:YES error:nil];
    
    [[ChatDemoHelper shareHelper] hangupCallWithReason:EMCallEndReasonDecline];
#endif
}

#pragma mark - public

+ (BOOL)canVideo
{
    if([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending){
        if(!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)){\
            UIAlertView * alt = [[UIAlertView alloc] initWithTitle:@"No camera permissions" message:@"Please open in \"Setting\"-\"Privacy\"-\"Camera\"." delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alt show];
            return NO;
        }
    }
    
    return YES;
}

+ (void)saveBitrate:(NSString*)value
{
    NSScanner* scan = [NSScanner scannerWithString:value];
    int val;
    if ([scan scanInt:&val] && [scan isAtEnd]) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:value forKey:kLocalCallBitrate];
        [ud synchronize];
    }
}

- (void)startTimer
{
    if (_callSession.type == EMCallTypeVideo && self.speakerOutButton.selected) {
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //code to be executed on the main queue after delay
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        });
    }
    _timeLength = 0;
    _timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)showCallInfo
{
    if (_callSession.type == EMCallTypeVideo)
    {
        [self showPropertyData];
        
        _propertyTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(showPropertyData) userInfo:nil repeats:YES];
    }
}

- (void)setNetwork:(EMCallNetworkStatus)status
{
    switch (status) {
        case EMCallNetworkStatusNormal:
            _networkLabel.text = @"";
            _networkLabel.hidden = YES;
            break;
        case EMCallNetworkStatusUnstable:
            _networkLabel.text = NSLocalizedString(@"call.networkUnstable", @"Unstable network");
            _networkLabel.hidden = NO;
            break;
        case EMCallNetworkStatusNoData:
            _networkLabel.text = NSLocalizedString(@"call.noDate", @"No network data");
            _networkLabel.hidden = NO;
            break;
        default:
            break;
    }
}

- (void)close
{
    _callSession.remoteVideoView.hidden = YES;
    _callSession = nil;
    _propertyView = nil;
    
    if (_timeTimer) {
        [_timeTimer invalidate];
        _timeTimer = nil;
    }
    
    if (_propertyTimer) {
        [_propertyTimer invalidate];
        _propertyTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
