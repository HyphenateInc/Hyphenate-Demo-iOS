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

/** @brief default tableFooterView */
@property (strong, nonatomic) UIView *defaultFooterView;

/** @brief data source of tableView */
@property (strong, nonatomic) NSMutableArray *dataArray;

/** @brief current loaded page */
@property (nonatomic) int page;

/**
 @brief if enable pull down to load more. default is NO
 */
@property (nonatomic) BOOL showRefreshHeader;

/** 
 @brief if enable pull up to load more. default is NO
 */
@property (nonatomic) BOOL showRefreshFooter;

/*!
 @method
 @brief pull down to load more
 */
- (void)tableViewDidTriggerHeaderRefresh;

/*!
 @method
 @brief load more
 */
- (void)tableViewDidTriggerFooterRefresh;

/*!
 @method
 @brief finish loading
 @discussion finish loading. Use the parameter reload to determine if call reloadData of tableView reloadData，check isHeader to stop the loading
 @param isHeader  if end pull down/up to load
 */
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader;

@end
