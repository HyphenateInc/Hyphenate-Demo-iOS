/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraCDDeviceManager+Microphone.h"
#import "AgoraAudioRecorderUtil.h"

@implementation AgoraCDDeviceManager (Microphone)

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
    if ([AgoraAudioRecorderUtil recorder].isRecording) {
        [[AgoraAudioRecorderUtil recorder] updateMeters];
        //[recorder averagePowerForChannel:0];
        //[recorder peakPowerForChannel:0];
        double lowPassResults = pow(10, (0.05 * [[AgoraAudioRecorderUtil recorder] peakPowerForChannel:0]));
        ret = lowPassResults;
    }
    
    return ret;
}
@end
