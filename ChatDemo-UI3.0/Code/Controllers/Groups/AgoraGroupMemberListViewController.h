/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class AgoraUserModel;
#import "AgoraGroupUIProtocol.h"

@interface AgoraGroupMemberListViewController : UITableViewController

@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;

- (instancetype)initWithGroup:(AgoraChatGroup *)group occupants:(NSArray<AgoraUserModel *> *)occupants;

@end
