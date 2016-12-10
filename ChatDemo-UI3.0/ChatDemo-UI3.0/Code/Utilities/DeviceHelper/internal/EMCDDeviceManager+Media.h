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

#import "EMCDDeviceManagerBase.h"

@interface EMCDDeviceManager (Media)

#pragma mark - AudioPlayer

- (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

- (void)stopPlaying;

- (void)stopPlayingWithChangeCategory:(BOOL)isChange;

-(BOOL)isPlaying;

#pragma mark - AudioRecorder
- (void)asyncStartRecordingWithFileName:(NSString *)fileName
                                completion:(void(^)(NSError *error))completion;

-(void)asyncStopRecordingWithCompletion:(void(^)(NSString *recordPath,
                                                 NSInteger aDuration,
                                                 NSError *error))completion;
-(void)cancelCurrentRecording;


-(BOOL)isRecording;

@end
