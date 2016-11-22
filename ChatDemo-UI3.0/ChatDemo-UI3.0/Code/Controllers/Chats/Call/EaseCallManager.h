/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "EaseCallViewController.h"
#import "EMSettingsViewController.h"
#import "EMMainViewController.h"

@interface EaseCallManager : NSObject

+ (instancetype) sharedManager;

@property (strong, nonatomic) EMCallSession *callSession;

@property (strong, nonatomic) EaseCallViewController *callController;

@property (strong, nonatomic) EMMainViewController *mainVC;

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

- (void)answerCall;



@end
