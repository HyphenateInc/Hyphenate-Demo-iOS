/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class AgoraApplyModel;
@interface AgoraApplyRequestCell : UITableViewCell

@property (nonatomic, strong) AgoraApplyModel *model;

@property (nonatomic, copy) void(^declineApply)(AgoraApplyModel *model);

@property (nonatomic, copy) void(^acceptApply)(AgoraApplyModel *model);

@end
