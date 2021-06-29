/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraBaseSettingController.h"

typedef void(^UpdatedMyName)(NSString *newName);
@interface AgoraModifyNickNameViewController : AgoraBaseSettingController

@property (nonatomic, copy) NSString *myNickName;

@property (nonatomic, copy)UpdatedMyName callBack;

@end
