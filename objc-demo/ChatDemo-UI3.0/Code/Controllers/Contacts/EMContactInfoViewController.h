/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
@class EMUserModel;

@interface EMContactInfoViewController : UITableViewController

- (instancetype)initWithUserModel:(EMUserModel *)model;

@end
