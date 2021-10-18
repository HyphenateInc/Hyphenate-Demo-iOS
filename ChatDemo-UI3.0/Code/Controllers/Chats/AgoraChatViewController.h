/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface AgoraChatViewController : AgoraChatBaseViewController

@property (nonatomic, strong, readonly) NSString *conversationId;
@property (nonatomic, strong) void(^leaveGroupBlock)(void);

- (instancetype)initWithConversationId:(NSString*)conversationId conversationType:(AgoraChatConversationType)type;

@end
