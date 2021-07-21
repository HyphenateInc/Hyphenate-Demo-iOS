/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and rAgoraains
 * the property of Hyphenate Inc.
 */

#import "AgoraSettingsViewController.h"
#import "AgoraAboutViewController.h"
#import "AgoraPushNotificationViewController.h"
#import "AgoraAccountViewController.h"
#import "AgoraChatsSettingViewController.h"
#import "AgoraChatDemoHelper.h"
#import "UIViewController+HUD.h"

@interface AgoraSettingsViewController ()

@property (nonatomic, strong) UISwitch *callPushSwitch;

@property (nonatomic) AgoraPushNoDisturbStatus pushStatus;
@end

@implementation AgoraSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self testUserInfo];
}

- (void)testUserInfo {
    
    [AgoraChatClient.sharedClient.userInfoManager fetchUserInfoById:@[AgoraChatClient.sharedClient.currentUsername] completion:^(NSDictionary *aUserDatas, AgoraError *aError) {
        AgoraUserInfo *userInfo = aUserDatas[AgoraChatClient.sharedClient.currentUsername];
        NSDictionary *dic = @{@"address":@"北京市海淀区",@"tel":@"01011112222"};
        NSError *parseError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
        if (parseError) {
          //解析出错
        }
        NSString * dicStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        userInfo.ext = dicStr;
        [AgoraChatClient.sharedClient.userInfoManager updateOwnUserInfo:userInfo completion:^(AgoraUserInfo *aUserInfo, AgoraError *aError) {
            NSLog(@"aUserInfo.userId:%@ aUserInfo:%@",aUserInfo.userId,aUserInfo.ext);
            
        }];
        
    }];
}

- (void)reloadNotificationStatus
{
    [self.tableView reloadData];
}

#pragma mark - getters

- (UISwitch *)callPushSwitch
{
    if (_callPushSwitch == nil) {
        
        _callPushSwitch = [[UISwitch alloc] init];
        [_callPushSwitch addTarget:self action:@selector(callPushChanged:) forControlEvents:UIControlEventValueChanged];
        [_callPushSwitch setOn:[[[NSUserDefaults standardUserDefaults] objectForKey:@"callPushChanged"] boolValue]];
    }
    
    return _callPushSwitch;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *ident = @"Cell";
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
    if (!cell) {
        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
    }
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.about", @"About");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.push", @"Push Notifications");
        BOOL isPushOn = [self isAllowedNotification];
        cell.detailTextLabel.text = isPushOn ? NSLocalizedString(@"setting.push.enable", @"Enable") : NSLocalizedString(@"setting.push.disable", @"Disable");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 2) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.account", @"Account");
        cell.detailTextLabel.text = [[AgoraChatClient sharedClient] currentUsername];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (indexPath.row == 3) {
        
        cell.textLabel.text = NSLocalizedString(@"setting.chats", @"Chats");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    } else {
        
        cell.textLabel.text = NSLocalizedString(@"setting.callPush", @"If the offline send call push");
        self.callPushSwitch.frame = CGRectMake(self.tableView.frame.size.width - 65, 8, 50, 30);
        [cell.contentView addSubview:self.callPushSwitch];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    if (indexPath.row == 0) {
            
        AgoraAboutViewController *about = [[AgoraAboutViewController alloc] init];
        about.title = NSLocalizedString(@"title.setting.about", @"About");
        [self.navigationController pushViewController:about animated:YES];
    } else if (indexPath.row == 1) {

        AgoraPushNotificationViewController *pushController = [[AgoraPushNotificationViewController alloc] init];
        pushController.title = NSLocalizedString(@"title.setting.push", @"Push Notifications");
        [AgoraChatDemoHelper shareHelper].pushVC = pushController;
        [self.navigationController pushViewController:pushController animated:YES];
    } else if (indexPath.row == 2) {
            
        AgoraAccountViewController *accout = [[AgoraAccountViewController alloc] init];
            accout.title = NSLocalizedString(@"title.setting.account", @"Account");
        [self.navigationController pushViewController:accout animated:YES];
    } else if (indexPath.row == 3) {
            
        AgoraChatsSettingViewController *chatSetting = [[AgoraChatsSettingViewController alloc] init];
        chatSetting.title = NSLocalizedString(@"title.setting.chats", @"Chats");
        [self.navigationController pushViewController:chatSetting animated:YES];
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
        UIView *header = [[UIView alloc] init];
        header.backgroundColor = PaleGrayColor;
        return header;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    } else {
        
        return 20;
    }
}

- (BOOL)isAllowedNotification {
    
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (setting.types != UIUserNotificationTypeNone) {
        
        return YES;
    }
    
    return NO;
}
#pragma mark - Actions

#warning need confirm 
- (void)callPushChanged:(UISwitch *)sender
{
    NSLog(@"callPushChanged --- %d",(int)sender.on);
    
//    AgoraCallOptions *options = [[AgoraChatClient sharedClient].callManager getCallOptions];
//    options.isSendPushIfOffline = sender.isOn;
//    if (sender.isOn) {
//
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        if (![ud objectForKey:@"callPushChanged"]) {
//            [ud setBool:YES forKey:@"callPushChanged"];
//            [ud synchronize];
//        }
//    } else {
//
//        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//        if ([ud objectForKey:@"callPushChanged"]) {
//            [ud rAgoraoveObjectForKey:@"callPushChanged"];
//            [ud synchronize];
//        }
//    }
    
}



@end
