/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "EMApplyModel.h"

@interface EMApplyManager : NSObject

+ (instancetype)defaultManager;

- (NSUInteger)unHandleApplysCount;

- (NSArray *)contactApplys;

- (NSArray *)groupApplys;

- (void)addApplyRequest:(EMApplyModel *)model;

- (void)removeApplyRequest:(EMApplyModel *)model;

- (BOOL)isExistingRequest:(NSString *)applyHyphenateId
                  groupId:(NSString *)groupId
               applyStyle:(EMApplyStyle)applyStyle;

@end
