/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import "AgoraBaseRefreshTableController.h"

@interface AgoraContactsViewController : AgoraBaseRefreshTableController

- (void)setupNavigationItem:(UINavigationItem *)navigationItem;

- (void)loadContactsFromServer;

- (void)reloadContacts;

- (void)reloadContactRequests;

- (void)reloadGroupNotifications;

@end
