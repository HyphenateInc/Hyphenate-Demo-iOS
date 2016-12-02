/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMCDDeviceManager+Microphone.h"
#import "EMAudioRecorderUtil.h"

@implementation EMCDDeviceManager (Microphone)

- (BOOL)emCheckMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    
    return ret;
}


- (double)emPeekRecorderVoiceMeter{
    double ret = 0.0;
    if ([EMAudioRecorderUtil recorder].isRecording) {
        [[EMAudioRecorderUtil recorder] updateMeters];
        //[recorder averagePowerForChannel:0];
        //[recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [[EMAudioRecorderUtil recorder] peakPowerForChannel:0]));
        ret = lowPassResults;
    }
    
    return ret;
}
@end
