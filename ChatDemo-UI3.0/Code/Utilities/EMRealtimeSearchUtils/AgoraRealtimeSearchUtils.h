/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

typedef void (^AgoraRealtimeSearchResultsBlock)(NSArray *results);

@interface AgoraRealtimeSearchUtils : NSObject

+ (instancetype)defaultUtil;

- (void)realtimeSearchWithSource:(id)source
                    searchString:(NSString *)searchString
                     resultBlock:(AgoraRealtimeSearchResultsBlock)block;

- (void)realtimeSearchDidFinish;

@end
