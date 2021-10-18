/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AgoraGroupInfoType) {
    AgoraGroupInfoType_groupType            =      0,
    AgoraGroupInfoType_canAllInvite,
    AgoraGroupInfoType_openJoin,
    AgoraGroupInfoType_mute,
    AgoraGroupInfoType_pushSetting,
    AgoraGroupInfoType_groupId
};
@class AgoraGroupPermissionModel;

@interface AgoraGroupPermissionCell : AgoraChatCustomBaseCell

@property (strong, nonatomic) IBOutlet UILabel *permissionTitleLabel;

@property (strong, nonatomic) IBOutlet UISwitch *permissionSwitch;

@property (copy, nonatomic) void (^ReturnSwitchState)(BOOL isOn);

@property (strong, nonatomic) AgoraGroupPermissionModel *model;

@end

@interface AgoraGroupPermissionModel : NSObject

@property (nonatomic, assign) AgoraGroupInfoType type;

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL switchState;

@property (nonatomic, strong) NSString *permissionDescription;

@end
