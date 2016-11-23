/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EMGroupPermissionType) {
    EMGroupPermissionType_groupType            =      0,
    EMGroupPermissionType_canAllInvite,
    EMGroupPermissionType_openJoin,
    EMGroupPermissionType_mute,
    EMGroupPermissionType_pushSetting,
    EMGroupPermissionType_groupId
};
@class EMGroupPermissionModel;

@interface EMGroupPermissionCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *permissionTitleLabel;

@property (strong, nonatomic) IBOutlet UISwitch *permissionSwitch;

@property (copy, nonatomic) void (^ReturnSwitchState)(BOOL isOn);

@property (strong, nonatomic) EMGroupPermissionModel *model;

@end

@interface EMGroupPermissionModel : NSObject

@property (nonatomic, assign) EMGroupPermissionType type;

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, assign) BOOL switchState;

@property (nonatomic, strong) NSString *permissionDescription;

@end
