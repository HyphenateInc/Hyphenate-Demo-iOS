/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraBaseSettingController.h"

typedef void(^UpdatedDisplayNameBlock)(NSString *newDisplayName);

@interface AgoraPushDisplaynameViewController : AgoraBaseSettingController

@property (nonatomic, copy) NSString *currentDisplayName;

@property (nonatomic, copy)UpdatedDisplayNameBlock callBack;

- (void)getUpdatedDisplayName:(UpdatedDisplayNameBlock)callBack;
@end
