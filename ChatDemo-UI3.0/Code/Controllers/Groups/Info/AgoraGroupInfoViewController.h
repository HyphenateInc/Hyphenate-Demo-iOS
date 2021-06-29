/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraBaseRefreshTableController.h"

@interface AgoraGroupInfoViewController : AgoraBaseRefreshTableController
@property (nonatomic,copy) void (^updateGroupNameBlock)(NSString *groupName);

- (instancetype)initWithGroupId:(NSString *)aGroupId;

@end
