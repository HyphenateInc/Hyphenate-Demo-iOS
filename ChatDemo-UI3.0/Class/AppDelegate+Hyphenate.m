/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "AppDelegate+Hyphenate.h"
#import "AppDelegate+HyphenateDebug.h"

/** Parse **/
#import "AppDelegate+Parse.h"

#import "LoginViewController.h"
#import "ChatDemoHelper.h"
#import "MBProgressHUD.h"

@implementation AppDelegate (Hyphenate)

- (void)hyphenateApplication:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
                      appkey:(NSString *)appkey
                apnsCertName:(NSString *)apnsCertName
                 otherConfig:(NSDictionary *)otherConfig
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedLogin) name:KNotification_login object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(proceedLogout) name:KNotification_logout object:nil];

    // Init Hyhenate SDK
    EMOptions *options = [EMOptions optionsWithAppkey:appkey];
    options.apnsCertName = apnsCertName;
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    [self registerNotification];
    
    BOOL isAutoLogin = [EMClient sharedClient].isAutoLogin;
    if (isAutoLogin) {
        [self proceedLogin];
    }
    else {
        [self proceedLogout];
        [[EMClient sharedClient].options setIsAutoLogin:YES];
    }
}


#pragma mark - login/logout

- (void)proceedLogin
{
    [[FriendRequestViewController shareController] loadDataSourceFromLocalDB];
    
    UINavigationController *navigationController;

    if (self.mainViewController == nil) {
        self.mainViewController = [[MainViewController alloc] init];
        navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainViewController];
    }
    else {
        navigationController  = self.mainViewController.navigationController;
    }
    
    /** Parse **/
    [self initParse];
    
    [ChatDemoHelper shareHelper].mainVC = self.mainViewController;
    
    [[ChatDemoHelper shareHelper] asyncGroupFromServer];
    [[ChatDemoHelper shareHelper] asyncConversationFromDB];
    [[ChatDemoHelper shareHelper] asyncPushOptions];
    
    self.window.rootViewController = navigationController;
}

- (void)proceedLogout
{
    if ([[EMClient sharedClient] isLoggedIn]) {
        [[ChatDemoHelper shareHelper] logout];
    }
    else {
        [self proceedLoginViewController];
    }
}

- (void)proceedLoginViewController
{
    if (self.mainViewController) {
        [self.mainViewController.navigationController popToRootViewControllerAnimated:NO];
    }
    
    self.mainViewController = nil;
    
    [ChatDemoHelper shareHelper].mainVC = nil;
    
    LoginViewController *loginController = [[LoginViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:loginController];
    
    self.window.rootViewController = navigationController;

    /** Parse **/
    [self clearParse];
}


#pragma mark - Notification Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[EMClient sharedClient] asyncBindDeviceToken:deviceToken success:^{
            NSLog(@"bind device token for remote notification succeeded");
        } failure:^(EMError *aError) {
            NSLog(@"Error!!! Failed to bindDeviceToken - %@", aError.errorDescription);
        }];
    });
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Error!!! Failed to register remote notification - %@", error.description);
}


#pragma mark - Push Notification Delegate

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)registerNotification
{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;
    
    // iOS 8+ - Configuring the User Notification Settings
    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
#if !TARGET_IPHONE_SIMULATOR
    
    // iOS 8+ - Registration process with Apple Push Notification service
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        [application registerForRemoteNotifications];
    }
    else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
#endif
}

@end
