/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

typedef void (^EMRealtimeSearchResultsBlock)(NSArray *results);

@interface EMRealtimeSearchUtils : NSObject

+ (instancetype)defaultUtil;

- (void)realtimeSearchWithSource:(id)source
                    searchString:(NSString *)searchString
                     resultBlock:(EMRealtimeSearchResultsBlock)block;

- (void)realtimeSearchDidFinish;

@end
