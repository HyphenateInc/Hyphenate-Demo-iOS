/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface AgoraMessageModel : NSObject

@property (strong, nonatomic,readonly) AgoraChatMessage *message;

@property (strong, nonatomic) AgoraChatUserInfo *userInfo;

@property (assign, nonatomic) BOOL isPlaying;

@property (assign, nonatomic) void(^fetchUserInfoBlcok)();

@property (nonatomic ,assign) BOOL isRecall;

- (instancetype)initWithMessage:(AgoraChatMessage*)message;


@end
