/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and rAgoraains
 * the property of Hyphenate Inc.
 */

#import "AppDelegate.h"

#import <UserNotifications/UserNotifications.h>
#import "AgoraMainViewController.h"
#import "AgoraLoginViewController.h"
#import "AgoraLaunchViewController.h"
#import "AgoraChatDEMoHelper.h"

//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>

//@import Firebase;

@interface AppDelegate () <AgoraChatClientDelegate,UNUserNotificationCenterDelegate>

@end


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
        [[UITabBar appearance] setBarTintColor:DefaultBarColor];
        [[UITabBar appearance] setTintColor:KermitGreenTwoColor];
        [[UINavigationBar appearance] setBarTintColor:DefaultBarColor];
        [[UINavigationBar appearance] setTintColor:AlmostBlackColor];
        [[UINavigationBar appearance] setTranslucent:NO];
    }
    
//    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    // init HyphenateSDK
    AgoraOptions *options = [AgoraOptions optionsWithAppkey:@"easemob-demo#easeim"];
//    AgoraOptions *options = [AgoraOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];


    // Hyphenate cert keys
    NSString *apnsCertName = nil;
#if ChatDemo_DEBUG
    apnsCertName = @"ChatDemoDevPush";
#else
    apnsCertName = @"ChatDemoProPush";
#endif
    
    [options setApnsCertName:apnsCertName];
    [options setEnableConsoleLog:YES];
    [options setIsDeleteMessagesWhenExitGroup:NO];
    [options setIsDeleteMessagesWhenExitChatRoom:NO];
    [options setUsingHttpsOnly:YES];
    
    [[AgoraChatClient sharedClient] initializeSDKWithOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loginStateChange:)
                                                 name:KNOTIFICATION_LOGINCHANGE
                                               object:nil];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    AgoraLaunchViewController *launch = [[AgoraLaunchViewController alloc] init];
    self.window.rootViewController = launch;
    [self.window makeKeyAndVisible];
    
    [self _registerAPNS];
    [self registerNotifications];
    

    return YES;
}

- (void)loginStateChange:(NSNotification *)notification
{
    BOOL loginSuccess = [notification.object boolValue];
    if (loginSuccess) {

        AgoraMainViewController *main = [[AgoraMainViewController alloc] init];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:main];
        navigationController.interactivePopGestureRecognizer.delegate = (id)self;
        self.window.rootViewController = navigationController;
        [AgoraChatDemoHelper shareHelper].mainVC = main;
        
    } else {
        AgoraLoginViewController *login = [[AgoraLoginViewController alloc] init];
        self.window.rootViewController = login;
        [AgoraChatDemoHelper shareHelper].mainVC = nil;
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[AgoraChatClient sharedClient] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[AgoraChatClient sharedClient] applicationWillEnterForeground:application];
    
    if ([AgoraChatDemoHelper shareHelper].pushVC) {
        [[AgoraChatDemoHelper shareHelper].pushVC reloadNotificationStatus];
    }
    
    if ([AgoraChatDemoHelper shareHelper].settingsVC) {
        [[AgoraChatDemoHelper shareHelper].settingsVC reloadNotificationStatus];
    }
}

#pragma mark - Remote Notification Registration

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AgoraChatClient sharedClient] bindDeviceToken:deviceToken];
        NSLog(@"%s deviceToken:%@",__func__,deviceToken);
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", @"Fail to register apns")
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%s ",__func__);

    [[AgoraChatClient sharedClient] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%s ",__func__);
    
    if ([AgoraChatDemoHelper shareHelper].mainVC) {
        [[AgoraChatDemoHelper shareHelper].mainVC didReceiveLocalNotification:notification];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSDictionary *userInfo = notification.request.content.userInfo;
    [[AgoraChatClient sharedClient] application:[UIApplication sharedApplication] didReceiveRemoteNotification:userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
//    if (gMainController) {
//        [gMainController didReceiveUserNotification:response.notification];
//    }
    completionHandler();
}

#pragma mark - EMPushManagerDelegateDevice

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
//    EMAlertView *alertView = [[EMAlertView alloc]initWithTitle:@"推送内容" message:str];
//    [alertView show];
    NSLog(@"%s push content:%@",__func__,str);
}


- (void)_registerAPNS
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    if (NSClassFromString(@"UNUserNotificationCenter")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError *error) {
            if (granted) {
#if !TARGET_IPHONE_SIMULATOR
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
#endif
            }
        }];
        return;
    }
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
#endif
}


#pragma mark - delegate registration

- (void)registerNotifications
{
    [self unregisterNotifications];
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications
{
    [[AgoraChatClient sharedClient] removeDelegate:self];
}

#pragma mark - AgoraChatClientDelegate

- (void)autoLoginDidCompleteWithError:(AgoraError *)aError
{
#if ChatDemo_DEBUG
    NSString *alertMsg = aError == nil ? NSLocalizedString(@"login.endAutoLogin.succeed", @"Automatic login succeed") : NSLocalizedString(@"login.endAutoLogin.failure", @"Automatic login failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:NSLocalizedString(@"login.ok", @"Ok") otherButtonTitles:nil, nil];
    [alert show];
#endif
}

@end
