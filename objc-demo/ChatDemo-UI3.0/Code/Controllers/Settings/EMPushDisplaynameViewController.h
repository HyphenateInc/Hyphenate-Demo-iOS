/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMBaseSettingController.h"

typedef void(^UpdatedDisplayName)(NSString *newDisplayName);

@interface EMPushDisplaynameViewController : EMBaseSettingController

@property (nonatomic, copy) NSString *currentDisplayName;

@property (nonatomic, copy)UpdatedDisplayName callBack;

- (void)getUpdatedDisplayName:(UpdatedDisplayName)callBack;
@end
