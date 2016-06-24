/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "GroupListViewController.h"

@interface ContactListViewController : EaseUsersListViewController <EMChatManagerDelegate>

@property (strong, nonatomic) GroupListViewController *groupController;

- (void)reloadRequestCount;
- (void)reloadGroupView;
- (void)reloadDataSource;
- (void)addFriendAction;

@end
