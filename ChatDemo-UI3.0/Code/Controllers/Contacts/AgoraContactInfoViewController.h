/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class AgoraUserModel;

@interface AgoraContactInfoViewController : UITableViewController

@property (nonatomic,copy) void (^addBlackListBlock)(void);
@property (nonatomic,copy) void (^deleteContactBlock)(void);

- (instancetype)initWithUserModel:(AgoraUserModel *)model;

@end
