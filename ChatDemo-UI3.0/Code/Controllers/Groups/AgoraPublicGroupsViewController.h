//
//  AgoraPublicGroupsNewViewController.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBaseRefreshTableController.h"
#import "AgoraGroupModel.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraPublicGroupsViewController : AgoraBaseRefreshTableController
@property (nonatomic, strong,readonly) NSMutableArray<AgoraGroupModel *> *publicGroups;

- (void)setSearchResultArray:(NSArray *)resultArray isEmptySearchKey:(BOOL)isEmptySearchKey;
- (void)setSearchState:(BOOL)isSearching;
@property (nonatomic,copy)void (^addGroupBlock)(void);

@end

NS_ASSUME_NONNULL_END
