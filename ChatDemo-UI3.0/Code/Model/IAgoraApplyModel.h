/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AgoraApplyStyle) {
    AgoraApplyStyle_contact         =          0,
    AgoraApplyStyle_joinGroup,
    AgoraApplyStyle_groupInvitation
};

#define kApply_recordId             @"recordId"
#define kApply_applyHyphenateId     @"applyHyphenateId"
#define kApply_applyNickName        @"applyNickName"
#define kApply_reason               @"reason"
#define kApply_receiverHyphenateId  @"receiverHyphenateId"
#define kApply_receiverNickname     @"receiverNickname"
#define kApply_style                @"style"
#define kApply_groupId              @"groupId"
#define kApply_groupSubject         @"groupSubject"
#define kApply_groupMemberCount     @"groupMemberCount"

@protocol IAgoraApplyModel <NSObject>

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
