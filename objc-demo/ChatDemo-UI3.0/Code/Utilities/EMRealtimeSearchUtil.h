/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

typedef void (^RealtimeSearchResultsBlock)(NSArray *results);

@interface EMRealtimeSearchUtil : NSObject

@property (nonatomic) BOOL asWholeSearch;

+ (instancetype)currentUtil;

- (void)realtimeSearchWithSource:(id)source
                      searchText:(NSString *)searchText
         collationStringSelector:(SEL)selector
                     resultBlock:(RealtimeSearchResultsBlock)resultBlock;

- (BOOL)realtimeSearchString:(NSString *)searchString
                  fromString:(NSString *)fromString;

- (void)realtimeSearchStop;

@end
