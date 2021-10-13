/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraMainViewController.h"

#import "AgoraContactsViewController.h"
#import "AgoraChatsViewController.h"
#import "AgoraSettingsViewController.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraCDDeviceManager.h"
#import "AgoraChatViewController.h"
#import <UserNotifications/UserNotifications.h>

#define kGroupMessageAtList      @"em_at_list"
#define kGroupMessageAtAll       @"all"

static const CGFloat kDefaultPlaySoundInterval = 3.0;

static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";

@interface AgoraMainViewController () <AgoraChatManagerDelegate, AgoraChatGroupManagerDelegate, AgoraChatClientDelegate>
{
    AgoraContactsViewController *_contactsVC;
    AgoraChatsViewController *_chatsVC;
    AgoraSettingsViewController *_settingsVC;
}

@property (strong, nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation AgoraMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadViewControllers];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    
    [self setupUnreadMessageCount];
    
    [self registerNotifications];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)dealloc
{
    [self unregisterNotifications];
}

#pragma mark - Notification Registration

- (void)registerNotifications
{
    [self unregisterNotifications];
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications
{
    [[AgoraChatClient sharedClient] removeDelegate:self];
    [[AgoraChatClient sharedClient].chatManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark - viewController

- (void)loadViewControllers
{
    self.title = NSLocalizedString(@"title.contacts", @"Contacts");
    _contactsVC = [[AgoraContactsViewController alloc] init];
    _contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.contacts", @"Contacts")
                                                           image:[UIImage imageNamed:@"Contacts"]
                                                             tag:0];
    [_contactsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Contacts_active"]];
    [self unSelectedTapTabBarItems:_contactsVC.tabBarItem];
    [self selectedTapTabBarItems:_contactsVC.tabBarItem];
    [_contactsVC setupNavigationItem:self.navigationItem];
    
    _chatsVC = [[AgoraChatsViewController alloc] init];
    _chatsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.chats", @"Chats")
                                                        image:[UIImage imageNamed:@"Chats"]
                                                          tag:1];
    [_chatsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Chats_active"]];
    [self unSelectedTapTabBarItems:_chatsVC.tabBarItem];
    [self selectedTapTabBarItems:_chatsVC.tabBarItem];
    
    _settingsVC = [[AgoraSettingsViewController alloc] init];
    _settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"title.settings", @"Settings")
                                                           image:[UIImage imageNamed:@"Settings"]
                                                             tag:2];
    [_settingsVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"Settings_active"]];
    [self unSelectedTapTabBarItems:_settingsVC.tabBarItem];
    [self selectedTapTabBarItems:_settingsVC.tabBarItem];
    
    self.viewControllers = @[_contactsVC,_chatsVC,_settingsVC];
    self.selectedIndex = 0;
    
    [AgoraChatDemoHelper shareHelper].contactsVC = _contactsVC;

    [AgoraChatDemoHelper shareHelper].settingsVC = _settingsVC;

    [AgoraChatDemoHelper shareHelper].chatsVC = _chatsVC;

}

- (void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:11.f], NSFontAttributeName,BlueyGreyColor,NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateNormal];
}

- (void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont systemFontOfSize:11.f],
                                        NSFontAttributeName,KermitGreenTwoColor,NSForegroundColorAttributeName,
                                        nil] forState:UIControlStateSelected];
}

- (void)setupUnreadMessageCount
{
    NSArray *conversations = [[AgoraChatClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (AgoraChatConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatsVC) {
        if (unreadCount > 0) {
            if (unreadCount >= 99) {
                _chatsVC.tabBarItem.badgeValue = @"99+";
            }else {
                _chatsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%@", @(unreadCount)];
            }
        }else{
            _chatsVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
    
    
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    if (userInfo) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (obj != self) {
                if (![obj isKindOfClass:[AgoraChatViewController class]]) {
                    [self.navigationController popViewControllerAnimated:NO];
                }
                else {
                    NSString *conversationChatter = userInfo[kConversationChatter];
                    AgoraChatViewController *chatViewController = (AgoraChatViewController *)obj;
                    if (![chatViewController.conversationId isEqualToString:conversationChatter]) {
                        [self.navigationController popViewControllerAnimated:NO];
                        AgoraChatType messageType = [userInfo[kMessageType] intValue];
                        chatViewController = [[AgoraChatViewController alloc] initWithConversationId:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                        [self.navigationController pushViewController:chatViewController animated:NO];
                    }
                    *stop= YES;
                }
            }
            else {
                AgoraChatViewController *chatViewController = nil;
                NSString *conversationChatter = userInfo[kConversationChatter];
                AgoraChatType messageType = [userInfo[kMessageType] intValue];
                chatViewController = [[AgoraChatViewController alloc] initWithConversationId:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                [self.navigationController pushViewController:chatViewController animated:NO];
            }
        }];
    }
    else if (_chatsVC) {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:_chatsVC];
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 0) {
        self.title = NSLocalizedString(@"title.contacts", @"Contacts");
        [_contactsVC setupNavigationItem:self.navigationItem];
    }
    else if (item.tag == 1){
        self.title = NSLocalizedString(@"title.chats", @"Chats");
        self.navigationItem.rightBarButtonItem = nil;
        [_chatsVC setupNavigationItem:self.navigationItem];
    }
    else if (item.tag == 2){
        self.title = NSLocalizedString(@"title.settings", @"Settings");
        [self clearNavigationItem];
    }
}

#pragma mark - AgoraChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self setupUnreadMessageCount];
    
#if !TARGET_IPHONE_SIMULATOR
    for (AgoraChatMessage *message in aMessages) {
        
        UIApplicationState state = [[UIApplication sharedApplication] applicationState];
        switch (state) {
            case UIApplicationStateActive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateInactive:
                [self playSoundAndVibration];
                break;
            case UIApplicationStateBackground:
                [self showBackgroundNotificationWithMessage:message];
                break;
            default:
                break;
        }
    }
#endif
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    [self setupUnreadMessageCount];
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    [self setupUnreadMessageCount];
}

#pragma mark - AgoraChatClientDelegate

- (void)connectionStateDidChange:(AgoraChatConnectionState)aConnectionState
{
    [_chatsVC networkChanged:aConnectionState];
}

- (void)userAccountDidLoginFromOtherDevice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

- (void)userAccountDidRemoveFromServer
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
}

- (void)clearNavigationItem
{
    self.navigationItem.titleView = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - private

- (AgoraChatConversationType)conversationTypeFromMessageType:(AgoraChatType)type
{
    AgoraChatConversationType conversatinType = AgoraChatConversationTypeChat;
    switch (type) {
        case AgoraChatTypeChat:
            conversatinType = AgoraChatConversationTypeChat;
            break;
        case AgoraChatTypeGroupChat:
            conversatinType = AgoraChatConversationTypeGroupChat;
            break;
        case AgoraChatTypeChatRoom:
            conversatinType = AgoraChatConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

- (void)playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }

    self.lastPlaySoundDate = [NSDate date];
    
    [[AgoraCDDeviceManager sharedInstance] playNewMessageSound];

    [[AgoraCDDeviceManager sharedInstance] playVibration];
}

- (void)showBackgroundNotificationWithMessage:(AgoraChatMessage *)message
{
    AgoraChatPushOptions *options = [[AgoraChatClient sharedClient] pushOptions];
    __block NSString *alertBody = @"";
    __block NSString *title = @"";

    if (options.displayStyle == AgoraChatPushDisplayStyleMessageSummary) {
        AgoraChatMessageBody *messageBody = message.body;
        NSString *messageStr = [self getMessageStrWithMessageBody:messageBody];
        

     
        
        [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:@[message.from] completion:^(NSDictionary * _Nonnull userInfoDic) {
            AgoraChatUserInfo *userInfo = userInfoDic[message.from];
            title = userInfo.nickName;
            
            if (message.chatType == AgoraChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[AgoraChatClient sharedClient].currentUsername]) {
                            alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                        }
                    }
                }
                NSArray *groupArray = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
                for (AgoraChatGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                    }
                }
            }
            else if (message.chatType == AgoraChatTypeChatRoom) {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[AgoraChatClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
            
            alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
            [self setNotifactionWithMessage:message alertBody:alertBody];
        }];
        
    }
    else {
        alertBody = NSLocalizedString(@"message.receiveMessage", @"you have a new message");
        [self setNotifactionWithMessage:message alertBody:alertBody];
    }
}


- (NSString *)getMessageStrWithMessageBody:(AgoraChatMessageBody*)messageBody {
    NSString *resultString = @"";
    switch (messageBody.type) {
        case AgoraChatMessageBodyTypeText:
            resultString = ((AgoraChatTextMessageBody *)messageBody).text;
            break;
        case AgoraChatMessageBodyTypeImage:
            resultString = NSLocalizedString(@"chat.image1", @"[image]");
            break;
        case AgoraChatMessageBodyTypeLocation:
            resultString = NSLocalizedString(@"chat.location1", @"[location]");
            break;
        case AgoraChatMessageBodyTypeVoice:
            resultString = NSLocalizedString(@"chat.voice1", @"[voice]");
            break;
        case AgoraChatMessageBodyTypeVideo:
            resultString = NSLocalizedString(@"chat.video1", @"[video]");
            break;
        default:
            break;
    }
    return resultString;
}



- (void)setNotifactionWithMessage:(AgoraChatMessage *)message
                        alertBody:(NSString *)alertBody {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    BOOL playSound = NO;
    if (!self.lastPlaySoundDate || timeInterval >= kDefaultPlaySoundInterval) {
        self.lastPlaySoundDate = [NSDate date];
        playSound = YES;
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        if (playSound) {
            content.sound = [UNNotificationSound defaultSound];
        }
        content.body = alertBody;
        content.userInfo = userInfo;
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:message.messageId content:content trigger:trigger];
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
    }
    else {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.fireDate = [NSDate date];
        notification.alertBody = alertBody;
        notification.alertAction = NSLocalizedString(@"open", @"Open");
        notification.timeZone = [NSTimeZone defaultTimeZone];
        if (playSound) {
            notification.soundName = UILocalNotificationDefaultSoundName;
        }
        notification.userInfo = userInfo;
        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    }
}

@end
