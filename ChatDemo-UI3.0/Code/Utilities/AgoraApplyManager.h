/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "AgoraApplyModel.h"

@interface AgoraApplyManager : NSObject

+ (instancetype)defaultManager;

- (NSUInteger)unHandleApplysCount;

- (NSArray *)contactApplys;

- (NSArray *)groupApplys;

- (void)addApplyRequest:(AgoraApplyModel *)model;

- (void)removeApplyRequest:(AgoraApplyModel *)model;

- (BOOL)isExistingRequest:(NSString *)applyHyphenateId
                  groupId:(NSString *)groupId
               applyStyle:(AgoraApplyStyle)applyStyle;

@end
