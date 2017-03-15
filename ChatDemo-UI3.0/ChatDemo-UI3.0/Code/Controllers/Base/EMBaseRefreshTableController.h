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

/** @brief 默认的tableFooterView */
@property (strong, nonatomic) UIView *defaultFooterView;

/** @brief tableView的数据源，用户UI显示 */
@property (strong, nonatomic) NSMutableArray *dataArray;

/** @brief 当前加载的页数 */
@property (nonatomic) int page;

/** @brief 是否启用下拉加载更多，默认为NO */
@property (nonatomic) BOOL showRefreshHeader;
/** @brief 是否启用上拉加载更多，默认为NO */
@property (nonatomic) BOOL showRefreshFooter;

/*!
 @method
 @brief 下拉加载更多(下拉刷新)
 */
- (void)tableViewDidTriggerHeaderRefresh;

/*!
 @method
 @brief 上拉加载更多
 */
- (void)tableViewDidTriggerFooterRefresh;

/*!
 @method
 @brief 加载结束
 @discussion 加载结束后，通过参数reload来判断是否需要调用tableView的reloadData，判断isHeader来停止加载
 @param isHeader   是否结束下拉加载(或者上拉加载)
 */
- (void)tableViewDidFinishTriggerHeader:(BOOL)isHeader;

@end
