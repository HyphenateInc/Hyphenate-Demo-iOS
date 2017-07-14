/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>

@interface EMConversationModel : NSObject

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) EMConversation *conversation;

- (instancetype)initWithConversation:(EMConversation*)conversation;

@end
