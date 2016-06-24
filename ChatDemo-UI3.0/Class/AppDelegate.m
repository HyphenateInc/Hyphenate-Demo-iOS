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

#import "MainViewController.h"
#import "LoginViewController.h"

/** Hyphenate **/
#import "AppDelegate+Hyphenate.h"

/** Parse **/
#import "AppDelegate+Parse.h"

/** Fabric **/
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>


/** Hyphenate configuration constants **/
static NSString *const kHyphenateAppKey = @"hyphenatedemo#hyphenatedemo";
static NSString *const kHyphenatePushServiceDevelopment = @"DevelopmentCertificate";
static NSString *const kHyphenatePushServiceProduction = @"ProductionCertificate";

/** Google Analytics configuration constants **/
static NSString *const kGaPropertyId = @"updateKey";
static NSString *const kTrackingPreferenceKey = @"allowTracking";
static BOOL const kGaDryRun = NO;
static int const kGaDispatchPeriod = 30;


@interface AppDelegate ()

/** Hyphenate **/
@property (assign, nonatomic) EMConnectionState connectionState;

/** Google Analytics **/
- (void)initializeGoogleAnalytics;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor HIPrimaryColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"HelveticaNeue" size:21.0], NSFontAttributeName, nil]];
    
    /** Parse **/
    [self parseApplication:application didFinishLaunchingWithOptions:launchOptions];
    
    /** Hyphenate **/
    self.connectionState = EMConnectionConnected;
    
    // APNs Push Service
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = kHyphenatePushServiceDevelopment;
#else
    apnsCertName = kHyphenatePushServiceProduction;
#endif
    
    [self hyphenateApplication:application
 didFinishLaunchingWithOptions:launchOptions
                        appkey:kHyphenateAppKey
                  apnsCertName:apnsCertName
                   otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];

    /** Google Analytics **/
//    [self initializeGoogleAnalytics];

    /** Fabric **/
    [[Fabric sharedSDK] setDebug:YES];
    [Fabric with:@[[Crashlytics class]]];

    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    if (self.mainViewController) {
        [self.mainViewController jumpToChatList];
    }
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if (self.mainViewController) {
        [self.mainViewController didReceiveLocalNotification:notification];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /** Hyphenate **/
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /** Hyphenate **/
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /** Google analytics **/
    [GAI sharedInstance].optOut = ![[NSUserDefaults standardUserDefaults] boolForKey:kTrackingPreferenceKey];
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
