/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMCDDeviceManager.h"
#import <AudioToolbox/AudioToolbox.h>
@interface EMCDDeviceManager (Remind)

- (SystemSoundID)playNewMessageSound;

- (void)playVibration;
@end
