/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <Foundation/Foundation.h>
#import "AgoraContactsViewController.h"
#import "AgoraMainViewController.h"
#import "AgoraPushNotificationViewController.h"
#import "AgoraChatsViewController.h"
#import "AgoraSettingsViewController.h"

@interface AgoraChatDemoHelper : NSObject<AgoraChatClientDelegate, AgoraChatContactManagerDelegate, AgoraChatGroupManagerDelegate, AgoraChatManagerDelegate, AgoraChatroomManagerDelegate>

@property (nonatomic, weak) AgoraContactsViewController *contactsVC;

@property (nonatomic, weak) AgoraMainViewController *mainVC;

@property (nonatomic, weak) AgoraSettingsViewController *settingsVC;

@property (nonatomic, weak) AgoraPushNotificationViewController *pushVC;

@property (nonatomic, weak) AgoraChatsViewController *chatsVC;

+ (instancetype)shareHelper;

- (void)setupUntreatedApplyCount;



@end
