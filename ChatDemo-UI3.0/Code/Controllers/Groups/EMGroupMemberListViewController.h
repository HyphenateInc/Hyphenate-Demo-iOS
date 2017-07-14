/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class EMUserModel;
#import "EMGroupUIProtocol.h"

@interface EMGroupMemberListViewController : UITableViewController

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

- (instancetype)initWithGroup:(EMGroup *)group occupants:(NSArray<EMUserModel *> *)occupants;

@end
