/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2013-2014 Hyphenate Technologies. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Technologies.
 */

#import "EMCDDeviceManager.h"

@interface EMCDDeviceManager (Microphone)

- (BOOL)emCheckMicrophoneAvailability;

// (0~1)
- (double)emPeekRecorderVoiceMeter;
@end
