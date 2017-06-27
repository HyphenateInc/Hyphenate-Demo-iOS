/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import "EMBaseRefreshTableController.h"
#import "EMGroupModel.h"

@interface EMPublicGroupsViewController : EMBaseRefreshTableController

@property (nonatomic, strong) NSMutableArray<EMGroupModel *> *publicGroups;
@property (nonatomic, strong) NSMutableArray<EMGroupModel *> *searchResults;
- (void)setSearchState:(BOOL)isSearching;

@end
