/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "EMContactsViewController.h"
#import "EMMainViewController.h"
#import "EMPushNotificationViewController.h"
#import "EMChatsViewController.h"

@interface EMChatDemoHelper : NSObject<EMClientDelegate, EMContactManagerDelegate, EMGroupManagerDelegate, EMChatManagerDelegate, EMChatroomManagerDelegate>

@property (nonatomic, weak) EMContactsViewController *contactsVC;

@property (nonatomic, weak) EMMainViewController *mainVC;

@property (nonatomic, weak) EMSettingsViewController *settingsVC;

@property (nonatomic, weak) EMPushNotificationViewController *pushVC;

@property (nonatomic, weak) EMChatsViewController *chatsVC;

+ (instancetype)shareHelper;

- (void)setupUntreatedApplyCount;



@end
