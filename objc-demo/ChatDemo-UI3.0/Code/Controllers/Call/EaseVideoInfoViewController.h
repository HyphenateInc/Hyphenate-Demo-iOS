/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface EaseVideoInfoViewController : UIViewController

@property (nonatomic, weak) EMCallSession *callSession;

@property (nonatomic, copy) NSString *currentTime;

@property (nonatomic, assign) int timeLength;


- (void)startTimer:(int)currentTimeLength;

@end
