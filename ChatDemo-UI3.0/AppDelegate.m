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
#import "AppDelegate+Parse.h"

//@import Firebase;

@interface AppDelegate () <AgoraChatClientDelegate>

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
    
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    // init HyphenateSDK
    AgoraOptions *options = [AgoraOptions optionsWithAppkey:@"easemob-demo#chatdemoui"];
//    AgoraOptions *options = [AgoraOptions optionsWithAppkey:@"1118210518231124#demo"];

   
    

    // Hyphenate cert keys
    NSString *apnsCertName = nil;
    #if DEBUG
        apnsCertName = @"DevelopmentCertificate";
    #else
        apnsCertName = @"ProductionCertificate";
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
    
//    [EaseCallManager sharedManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    AgoraLaunchViewController *launch = [[AgoraLaunchViewController alloc] init];
    self.window.rootViewController = launch;
    [self.window makeKeyAndVisible];
    
    [self _registerAPNS];
    [self registerNotifications];
    
    // Fabric
//    [Fabric with:@[[Crashlytics class]]];
    
    // Use Firebase library to configure APIs
//    [FIRApp configure];
    
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

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([AgoraChatDemoHelper shareHelper].mainVC) {
        [[AgoraChatDemoHelper shareHelper].mainVC didReceiveLocalNotification:notification];
    }
}

#pragma mark - RAgoraote Notification Registration

- (void)application:(UIApplication *)application didRegisterForRAgoraoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[AgoraChatClient sharedClient] registerForRemoteNotificationsWithDeviceToken:deviceToken
                                                                completion:^(AgoraError *aError) {
        
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRAgoraoteNotificationsWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", @"Fail to register apns")
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
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
    if ([application respondsToSelector:@selector(registerForRAgoraoteNotifications)]) {
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
#if DEBUG
    NSString *alertMsg = aError == nil ? NSLocalizedString(@"login.endAutoLogin.succeed", @"Automatic login succeed") : NSLocalizedString(@"login.endAutoLogin.failure", @"Automatic login failed");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMsg delegate:nil cancelButtonTitle:NSLocalizedString(@"login.ok", @"Ok") otherButtonTitles:nil, nil];
    [alert show];
#endif
}

@end
