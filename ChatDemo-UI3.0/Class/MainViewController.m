/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "MainViewController.h"

#import "SettingsViewController.h"
#import "FriendRequestViewController.h"
#import "ChatViewController.h"
#import "UserProfileManager.h"
#import "ConversationListController.h"
#import "ContactListViewController.h"
#import "ChatDemoHelper.h"
#import "AddFriendViewController.h"

static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationID = @"ConversationID";
static NSString *kGroupName = @"GroupName";

@interface MainViewController () <UIAlertViewDelegate, EMCallManagerDelegate>

@property (strong, nonatomic) UIBarButtonItem *addFriendItem;
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (strong, nonatomic) ConversationListController *chatListVC;
@property (strong, nonatomic) ContactListViewController *contactsVC;
@property (strong, nonatomic) SettingsViewController *settingsVC;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = NSLocalizedString(@"title.conversation", @"Chats");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRequestCount) name:kNotification_didReceiveRequest object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRequestCount) name:@"updateRequestCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageCount:) name:kNotification_unreadMessageCountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCmdMessages:) name:kNotification_didReceiveCmdMessages object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendNotification:) name:kNotification_didReceiveMessages object:nil];


    [self setupTabBars];
    
    self.selectedIndex = 0;
    [self selectedTapTabBarItems:self.chatListVC.tabBarItem];
    
    self.addFriendItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"add"]
                                                                            style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(addFriendAction)];
    self.navigationItem.rightBarButtonItem = self.addFriendItem;

    [self updateRequestCount];
    
    [ChatDemoHelper shareHelper].contactViewVC = self.contactsVC;
    [ChatDemoHelper shareHelper].conversationListVC = self.chatListVC;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateUnreadMessageCount:nil];
    
//    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
//    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    self.navigationItem.rightBarButtonItem = nil;

    if (item.tag == 0) {
        self.title = NSLocalizedString(@"title.conversation", @"Chats");
    }
    else if (item.tag == 1) {
        self.title = NSLocalizedString(@"title.addressbook", @"Contacts");
        self.navigationItem.rightBarButtonItem = self.addFriendItem;
    }
    else if (item.tag == 2) {
        self.title = NSLocalizedString(@"title.setting", @"Settings");
        [self.settingsVC refreshConfig];
    }
}


#pragma mark - private

- (void)setupTabBars
{
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor HIPrimaryColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];

    // Chats screen
    self.chatListVC = [[ConversationListController alloc] initWithNibName:nil bundle:nil];
    [self.chatListVC networkChanged:_connectionState];
    self.chatListVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Chats" image:[UIImage imageNamed:@"tabbar_chats"] selectedImage:[UIImage imageNamed:@"tabbar_chatsHL"]];
    self.chatListVC.tabBarItem.tag = 0;
    [self unSelectedTapTabBarItems:self.chatListVC.tabBarItem];
    [self selectedTapTabBarItems:self.chatListVC.tabBarItem];
    
    // Contacts screen
    self.contactsVC = [[ContactListViewController alloc] initWithNibName:nil bundle:nil];
    self.contactsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts"
                                                               image:[UIImage imageNamed:@"tabbar_contactsHL"]
                                                       selectedImage:[UIImage imageNamed:@"tabbar_contacts"]];
    self.contactsVC.tabBarItem.tag = 1;
    [self unSelectedTapTabBarItems:self.contactsVC.tabBarItem];
    [self selectedTapTabBarItems:self.contactsVC.tabBarItem];
    
    // Settings Screen
    self.settingsVC = [[SettingsViewController alloc] init];
    self.settingsVC.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Settings" image:[UIImage imageNamed:@"tabbar_settingHL"] selectedImage:[UIImage imageNamed:@"tabbar_setting"]];
    self.settingsVC.tabBarItem.tag = 2;
    self.settingsVC.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self unSelectedTapTabBarItems:self.settingsVC.tabBarItem];
    [self selectedTapTabBarItems:self.settingsVC.tabBarItem];
    
    self.viewControllers = @[self.chatListVC, self.contactsVC, self.settingsVC];
}

-(void)unSelectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor grayColor], NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}

-(void)selectedTapTabBarItems:(UITabBarItem *)tabBarItem
{
    [tabBarItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, [UIColor HIPrimaryColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
}

- (void)updateUnreadMessageCount:(NSNotification *)notification
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    
    if (self.chatListVC) {
        
        if (unreadCount > 0) {
            self.chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", (int)unreadCount];
        }
        else {
            self.chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)updateRequestCount
{
    NSInteger unreadCount = [[[FriendRequestViewController shareController] dataSource] count];
   
    if (self.contactsVC) {
        if (unreadCount > 0) {
            self.contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", (int)unreadCount];
        }else{
            self.contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    
    [self.chatListVC networkChanged:connectionState];
}


#pragma mark - Notifications

- (void)sendNotification:(NSNotification *)notification
{
#if !TARGET_IPHONE_SIMULATOR
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    switch (state) {
        case UIApplicationStateActive:
            [self playSoundAndVibration];
            break;
        case UIApplicationStateInactive:
            [self playSoundAndVibration];
            break;
        case UIApplicationStateBackground:
            [self showNotificationWithMessage:notification.object];
            break;
        default:
            break;
    }
#endif
}

- (void)playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        return;
    }
    
    self.lastPlaySoundDate = [NSDate date];
    
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        NSString *title = [[UserProfileManager sharedInstance] getNickNameWithUsername:message.from];
        
        if (message.chatType == EMChatTypeGroupChat) {
            
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            
            for (EMGroup *group in groupArray) {
                
                if ([group.groupId isEqualToString:message.conversationId]) {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                    break;
                }
            }
        }
        else if (message.chatType == EMChatTypeChatRoom)
        {
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            
            NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
            
            NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
            
            NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
            if (chatroomName) {
                title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
            }
        }
        
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else {
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
    }
    else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationID];
    notification.userInfo = userInfo;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void)addFriendAction
{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:addController animated:YES];
}


#pragma mark - Notifications

- (void)handleCmdMessages:(NSNotification *)notification
{
    [self showHint:NSLocalizedString(@"receiveCmd", @"receive cmd message")];
}


#pragma mark - Auto Reconnect

- (void)willAutoReconnect
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
    }
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        }else{
            [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
        }
    }
}

#pragma mark - public

- (void)jumpToChatList
{
    if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
//        ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
//        [chatController hideImagePicker];
    }
    else if (self.chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:self.chatListVC];
    }
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        NSArray *viewControllers = self.navigationController.viewControllers;
        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            
            if (obj != self)
            {
                if (![obj isKindOfClass:[ChatViewController class]])
                {
                    [self.navigationController popViewControllerAnimated:NO];
                }
                else
                {
                    NSString *conversationID = userInfo[kConversationID];
                    ChatViewController *chatViewController = (ChatViewController *)obj;
                    if (![chatViewController.conversation.conversationId isEqualToString:conversationID])
                    {
                        [self.navigationController popViewControllerAnimated:NO];
                        
                        EMChatType messageType = [userInfo[kMessageType] intValue];
                        
                        chatViewController = [[ChatViewController alloc] initWithConversationID:conversationID conversationType:[self conversationTypeFromMessageType:messageType]];
                        
                        switch (messageType) {
                                
                            case EMChatTypeChat:
                                {
                                    NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                                    for (EMGroup *group in groupArray) {
                                        if ([group.groupId isEqualToString:conversationID]) {
                                            chatViewController.title = group.subject;
                                            break;
                                        }
                                    }
                                }
                                break;
                            default:
                                chatViewController.title = conversationID;
                                break;
                        }
                        [self.navigationController pushViewController:chatViewController animated:NO];
                    }
                    *stop= YES;
                }
            }
            else
            {
                ChatViewController *chatViewController = (ChatViewController *)obj;
                
                NSString *conversationID = userInfo[kConversationID];
                
                EMChatType messageType = [userInfo[kMessageType] intValue];
                
                chatViewController = [[ChatViewController alloc] initWithConversationID:conversationID conversationType:[self conversationTypeFromMessageType:messageType]];
                switch (messageType) {
                    case EMChatTypeGroupChat:
                    {
                        NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                        for (EMGroup *group in groupArray) {
                            if ([group.groupId isEqualToString:conversationID]) {
                                chatViewController.title = group.subject;
                                break;
                            }
                        }
                    }
                        break;
                    default:
                        chatViewController.title = conversationID;
                        break;
                }
                [self.navigationController pushViewController:chatViewController animated:NO];
            }
        }];
    }
    else if (self.chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:self.chatListVC];
    }
}

@end
