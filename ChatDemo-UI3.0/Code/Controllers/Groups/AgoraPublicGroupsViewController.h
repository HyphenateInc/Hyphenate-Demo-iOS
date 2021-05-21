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
#import "AgoraGroupModel.h"

@interface AgoraPublicGroupsViewController : AgoraBaseRefreshTableController

@property (nonatomic, strong) NSMutableArray<AgoraGroupModel *> *publicGroups;
@property (nonatomic, strong) NSMutableArray<AgoraGroupModel *> *searchResults;
- (void)setSearchState:(BOOL)isSearching;

@end
