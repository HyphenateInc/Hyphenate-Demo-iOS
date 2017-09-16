/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface EMAudioRecorderUtil : NSObject

+(BOOL)isRecording;

+ (void)asyncStartRecordingWithPreparePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
+(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

+(void)cancelCurrentRecording;

// current recorder
+(AVAudioRecorder *)recorder;
@end
