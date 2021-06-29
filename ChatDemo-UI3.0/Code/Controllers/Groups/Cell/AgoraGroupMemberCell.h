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
@class AgoraUserModel;

@interface AgoraGroupMemberCell : UITableViewCell

@property (nonatomic, assign) BOOL isGroupOwner;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) AgoraUserModel *model;

@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;

@end
