/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "IAgoraApplyModel.h"

@interface AgoraApplyModel : NSObject<IAgoraApplyModel>

@property (nonatomic, strong, readonly) NSString *recordId;
@property (nonatomic, strong) NSString * applyHyphenateId;
@property (nonatomic, strong) NSString * applyNickName;
@property (nonatomic, strong) NSString * reason;
@property (nonatomic, strong) NSString * receiverHyphenateId;
@property (nonatomic, strong) NSString * receiverNickname;
@property (nonatomic, assign) AgoraApplyStyle style;
@property (nonatomic, strong) NSString * groupId;
@property (nonatomic, strong) NSString * groupSubject;
@property (nonatomic, assign) NSInteger groupMemberCount;

@end
