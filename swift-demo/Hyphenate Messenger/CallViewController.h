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

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <Hyphenate/Hyphenate.h>

#define kLocalCallBitrate @"HyphenateLocalCallBitrate"

@class EMCallSession;
@class HyphenateMessengerHelper;

@interface CallViewController : UIViewController

@property (strong, nonatomic) NSTimer *timeTimer;
@property (strong, nonatomic) AVAudioPlayer *ringPlayer;

@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIImageView *headerImageView;

@property (strong, nonatomic) UIButton *rejectButton;
@property (strong, nonatomic) UIButton *answerButton;
@property (strong, nonatomic) UIButton *cancelButton;

@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *videoButton;
@property (strong, nonatomic) UIButton *voiceButton;

@property (strong, nonatomic) UIView *actionView;
@property (strong, nonatomic) UIButton *silenceButton;
@property (strong, nonatomic) UILabel *silenceLabel;
@property (strong, nonatomic) UIButton *speakerOutButton;
@property (strong, nonatomic) UILabel *speakerOutLabel;
@property (strong, nonatomic) UIButton *minimizeButton;
@property (strong, nonatomic) UIButton *switchCameraButton;


- (instancetype)initWithSession:(EMCallSession *)session
                       isCaller:(BOOL)isCaller
                         status:(NSString *)statusString;

+ (BOOL)canVideo;

+ (void)saveBitrate:(NSString*)value;

- (void)startTimer;

- (void)showCallInfo;

- (void)close;

- (void)setNetwork:(EMCallNetworkStatus)status;


@end
