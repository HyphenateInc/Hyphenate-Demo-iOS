/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class EMApplyModel;
@interface EMApplyRequestCell : UITableViewCell

@property (nonatomic, strong) EMApplyModel *model;

@property (nonatomic, copy) void(^declineApply)(EMApplyModel *model);

@property (nonatomic, copy) void(^acceptApply)(EMApplyModel *model);

@end
