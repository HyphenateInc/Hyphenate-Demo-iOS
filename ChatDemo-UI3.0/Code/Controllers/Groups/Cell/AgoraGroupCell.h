/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>
#import "AgoraGroupUIProtocol.h"
@class AgoraGroupModel;

@interface AgoraGroupCell : UITableViewCell

@property (nonatomic, strong) AgoraGroupModel *model;

@property (nonatomic, assign) BOOL isRequestedToJoinPublicGroup;

@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;

@end
