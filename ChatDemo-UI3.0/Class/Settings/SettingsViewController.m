/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "SettingsViewController.h"

#import "FriendRequestViewController.h"
#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "EditNicknameViewController.h"
#import "UserProfileEditViewController.h"
#import "CallViewController.h"

@interface SettingsViewController ()

@property (strong, nonatomic) UIView *footerView;

@property (strong, nonatomic) UISwitch *autoLoginSwitch;
@property (strong, nonatomic) UISwitch *delConversationSwitch;

@end

@implementation SettingsViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.setting", @"Setting");
    
    self.view.backgroundColor = [UIColor HIGrayLightColor];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
#ifdef ENABLE_GOOGLE_ANALYTICS
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - getter

- (UISwitch *)autoLoginSwitch
{
    if (_autoLoginSwitch == nil) {
        _autoLoginSwitch = [[UISwitch alloc] init];
        [_autoLoginSwitch addTarget:self action:@selector(autoLoginChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _autoLoginSwitch;
}

- (UISwitch *)delConversationSwitch
{
    if (!_delConversationSwitch)
    {
        _delConversationSwitch = [[UISwitch alloc] init];
        _delConversationSwitch.on = [[EMClient sharedClient].options isDeleteMessagesWhenExitGroup];
        [_delConversationSwitch addTarget:self action:@selector(delConversationChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _delConversationSwitch;
}


#pragma mark - Table view datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7 + 1;   // items + spacing
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.section == 0) {
        
        switch(indexPath.row) {
            case 0:
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.textLabel.text = [NSString stringWithFormat:@"SDK Version: %@", [[EMClient sharedClient] version]];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"setting.personalInfo", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                while (cell.contentView.subviews.count) {
                    UIView* child = cell.contentView.subviews.lastObject;
                    [child removeFromSuperview];
                }
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"title.apnsSetting", @"Apns Settings");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"setting.iospushname", @"APNs Display Name");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"title.usernameBlock", @"Black List");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 5:
            {
                //cell.textLabel.text = NSLocalizedString(@"setting.deleteConWhenLeave", @"Delete conversation when leave a group");
                cell.accessoryType = UITableViewCellAccessoryNone;
                self.delConversationSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.delConversationSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.delConversationSwitch.frame.size.height) / 2, self.delConversationSwitch.frame.size.width, self.delConversationSwitch.frame.size.height);
                [cell.contentView addSubview:self.delConversationSwitch];
                
                CGRect frame = cell.contentView.frame;
                frame.origin.x = 16;
                frame.size.width = self.delConversationSwitch.frame.origin.x - frame.origin.x;
                UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
                textLabel.text = NSLocalizedString(@"setting.deleteConWhenLeave", @"Delete conversation when leave a group");
                [cell.contentView addSubview:textLabel];
                break;
            }
            case 6:
                cell.textLabel.text = NSLocalizedString(@"setting.autoLogin", @"Automatic Login");
                cell.accessoryType = UITableViewCellAccessoryNone;
                self.autoLoginSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.autoLoginSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.autoLoginSwitch.frame.size.height) / 2, self.autoLoginSwitch.frame.size.width, self.autoLoginSwitch.frame.size.height);
                [cell.contentView addSubview:self.autoLoginSwitch];
                break;
            default:
                break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        UserProfileEditViewController *userProfile = [[UserProfileEditViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:userProfile animated:YES];
    }
    else if (indexPath.row == 2) {
        PushNotificationViewController *pushController = [[PushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 3) {
        EditNicknameViewController *editName = [[EditNicknameViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:editName animated:YES];
    }
    else if (indexPath.row == 4) {
        BlackListViewController *blackController = [[BlackListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:blackController animated:YES];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView cancelButtonIndex] != buttonIndex) {
        
        UITextField *nameTextField = [alertView textFieldAtIndex:0];
        
        BOOL flag = YES;
        
        if(nameTextField.text.length > 0) {
            
            NSScanner* scan = [NSScanner scannerWithString:nameTextField.text];
            
            int val;
            
            if ([scan scanInt:&val] && [scan isAtEnd]) {
                if ([nameTextField.text intValue] >= 150 && [nameTextField.text intValue] <= 1000) {
                    [CallViewController saveBitrate:nameTextField.text];
                    flag = NO;
                }
            }
        }
        
        if (flag) {
            [self showHint:NSLocalizedString(@"setting.setBitrateTips", @"Set Bitrate should be 150-1000")];
        }
    }
}


#pragma mark - Views

- (UIView *)footerView
{
    if (_footerView == nil) {
        
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 80)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _footerView.frame.size.width, 1)];
        line.backgroundColor = [UIColor HIGrayLightColor];
        [_footerView addSubview:line];
        
        CGRect buttonFrame = CGRectMake(0, 1, _footerView.frame.size.width, 45);
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [logoutButton setBackgroundColor:[UIColor HIRedColor]];
        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.loginUser", @"Logout as  (%@)"), username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];

        UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, logoutButton.frame.origin.y + logoutButton.frame.size.height + 2, _footerView.frame.size.width, 1)];
        borderBottom.backgroundColor = [UIColor HIGrayLightColor];
        [_footerView addSubview:borderBottom];
    }
    
    return _footerView;
}


#pragma mark - action

- (void)autoLoginChanged:(UISwitch *)autoSwitch
{
    [[EMClient sharedClient].options setIsAutoLogin:autoSwitch.isOn];
}

- (void)delConversationChanged:(UISwitch *)control
{
    [[EMClient sharedClient].options setIsDeleteMessagesWhenExitGroup:control.on];
}

- (void)showCallInfoChanged:(UISwitch *)control
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSNumber numberWithBool:control.isOn] forKey:@"showCallInfo"];
    [userDefaults synchronize];
}

- (void)refreshConfig
{
    [self.autoLoginSwitch setOn:[[EMClient sharedClient].options isAutoLogin] animated:NO];
    
    [self.tableView reloadData];
}

- (void)logoutAction
{
    __weak SettingsViewController *weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutInProgress", @"logging out...")];
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        if (!aError) {
            [weakSelf hideHud];
            [[FriendRequestViewController shareController] clear];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_logout object:nil];
        }
        else {
            [weakSelf hideHud];
            [weakSelf showHint:aError.errorDescription];
        }
    }];
}
 
@end
