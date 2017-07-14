/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface EMAudioPlayerUtil : NSObject

+ (BOOL)isPlaying;

+ (NSString *)playingFilePath;

+ (void)asyncPlayingWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

+ (void)stopCurrentPlaying;

@end
