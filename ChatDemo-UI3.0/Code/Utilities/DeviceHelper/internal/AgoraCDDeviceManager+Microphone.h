/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraCDDeviceManager.h"

@interface AgoraCDDeviceManager (Microphone)

- (BOOL)emCheckMicrophoneAvailability;

// (0~1)
- (double)emPeekRecorderVoiceMeter;
@end
