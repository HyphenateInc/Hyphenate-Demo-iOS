/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface AgoraConversationModel : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) AgoraChatConversation *conversation;

- (instancetype)initWithConversation:(AgoraChatConversation*)conversation;

@end
