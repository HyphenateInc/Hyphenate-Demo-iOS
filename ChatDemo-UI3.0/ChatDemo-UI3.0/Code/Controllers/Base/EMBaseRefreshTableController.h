/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface EMBaseRefreshTableController : UITableViewController

@property (nonatomic, copy) void(^headerRefresh)(BOOL isRefreshing);

- (void)endHeaderRefresh;

- (UIView *)tableViewFoot;

@end
