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

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "MainViewController.h"
#import "LoginViewController.h"

#import "AppDelegate+Hyphenate.h"
#import "AppDelegate+Parse.h"

/** Hyphenate configuration constants **/
static NSString *const kHyphenateAppKey = @"hyphenate#hyphenatedemo";
static NSString *const kHyphenatePushServiceDevelopment = @"DevelopmentCertificate";
static NSString *const kHyphenatePushServiceProduction = @"ProductionCertificate";

/** Google Analytics configuration constants **/
static NSString *const kGaPropertyId = @"UA-78628613-1";
static NSString *const kTrackingPreferenceKey = @"allowTracking";
static BOOL const kGaDryRun = NO;
static int const kGaDispatchPeriod = 30;

@interface AppDelegate ()

- (void)initializeGoogleAnalytics;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _connectionState = EMConnectionConnected;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    [[UINavigationBar appearance] setBarTintColor:[UIColor HIColorGreenMajor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue" size:21.0], NSFontAttributeName, nil]];
    
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    // APNs Push Service
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = kHyphenatePushServiceDevelopment;
#else
    apnsCertName = kHyphenatePushServiceProduction;
#endif
    
    // Hyphenate init
    [self hyphenateApplication:application
 didFinishLaunchingWithOptions:launchOptions
                        appkey:kHyphenateAppKey
                  apnsCertName:apnsCertName
                   otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    
    // Google Analytics
    [self initializeGoogleAnalytics];

    // Crashlytics
    [Fabric with:@[[Crashlytics class]]];

    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (_mainController) {
        [_mainController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (_mainController) {
        [_mainController didReceiveLocalNotification:notification];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kTrackingPreferenceKey];
}


#pragma mark - Google Analytics

- (void)initializeGoogleAnalytics
{
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    [[GAI sharedInstance] setDispatchInterval:kGaDispatchPeriod];
    [[GAI sharedInstance] setDryRun:kGaDryRun];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];
}

@end
