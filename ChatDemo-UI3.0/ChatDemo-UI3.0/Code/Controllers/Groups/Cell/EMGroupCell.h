/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import "EMGroupUIProtocol.h"
@class EMGroupModel;

@interface EMGroupCell : UITableViewCell

@property (nonatomic, strong) EMGroupModel *model;

@property (nonatomic, assign) BOOL isRequestedToJoinPublicGroup;

@property (nonatomic, assign) id<EMGroupUIProtocol> delegate;

@end
