/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "SettingsViewController.h"

#import "ApplyViewController.h"
#import "PushNotificationViewController.h"
#import "BlackListViewController.h"
#import "DebugViewController.h"
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
    
    self.view.backgroundColor = [UIColor HIColorLightGray];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:NSStringFromClass(self.class) value:@""];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
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
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SettingsCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0) {
        
        switch(indexPath.row) {
            case 0:
                cell.textLabel.text = NSLocalizedString(@"setting.autoLogin", @"Automatic Login");
                cell.accessoryType = UITableViewCellAccessoryNone;
                self.autoLoginSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.autoLoginSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.autoLoginSwitch.frame.size.height) / 2, self.autoLoginSwitch.frame.size.width, self.autoLoginSwitch.frame.size.height);
                [cell.contentView addSubview:self.autoLoginSwitch];
                break;
            case 1:
                cell.textLabel.text = NSLocalizedString(@"title.apnsSetting", @"Apns Settings");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.textLabel.text = NSLocalizedString(@"title.buddyBlock", @"Black List");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 3:
                cell.textLabel.text = NSLocalizedString(@"title.debug", @"Debug");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 4:
                cell.textLabel.text = NSLocalizedString(@"setting.deleteConWhenLeave", @"Delete conversation when leave a group");
                cell.accessoryType = UITableViewCellAccessoryNone;
                self.delConversationSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.delConversationSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.delConversationSwitch.frame.size.height) / 2, self.delConversationSwitch.frame.size.width, self.delConversationSwitch.frame.size.height);
                [self.delConversationSwitch setOn:NO animated:NO];
                [cell.contentView addSubview:self.delConversationSwitch];
                break;
            case 5:
                cell.textLabel.text = NSLocalizedString(@"setting.iospushname", @"APNs Display Name");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 6:
                cell.textLabel.text = NSLocalizedString(@"setting.personalInfo", nil);
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                while (cell.contentView.subviews.count) {
                    UIView* child = cell.contentView.subviews.lastObject;
                    [child removeFromSuperview];
                }
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
        PushNotificationViewController *pushController = [[PushNotificationViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:pushController animated:YES];
    }
    else if (indexPath.row == 2)
    {
        BlackListViewController *blackController = [[BlackListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:blackController animated:YES];
    }
    else if (indexPath.row == 3)
    {
        DebugViewController *debugController = [[DebugViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:debugController animated:YES];
    }
    else if (indexPath.row == 5) {
        EditNicknameViewController *editName = [[EditNicknameViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:editName animated:YES];
    }
    else if (indexPath.row == 6){
        UserProfileEditViewController *userProfile = [[UserProfileEditViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:userProfile animated:YES];
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
        line.backgroundColor = [UIColor HIColorLightGray];
        [_footerView addSubview:line];
        
        CGRect buttonFrame = CGRectMake(0, 1, _footerView.frame.size.width, 45);
        
        UIButton *logoutButton = [[UIButton alloc] initWithFrame:buttonFrame];
        [logoutButton setBackgroundColor:[UIColor HIColorRed]];
        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *logoutButtonTitle = [[NSString alloc] initWithFormat:NSLocalizedString(@"setting.loginUser", @"Logout as  (%@)"), username];
        [logoutButton setTitle:logoutButtonTitle forState:UIControlStateNormal];
        [logoutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:logoutButton];

        UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, logoutButton.frame.origin.y + logoutButton.frame.size.height + 2, _footerView.frame.size.width, 1)];
        borderBottom.backgroundColor = [UIColor HIColorLightGray];
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
    [self.autoLoginSwitch setOn:[[EMClient sharedClient].options isAutoLogin] animated:YES];
    
    [self.tableView reloadData];
}

- (void)logoutAction
{
    __weak SettingsViewController *weakSelf = self;
    
    [self showHudInView:self.view hint:NSLocalizedString(@"setting.logoutOngoing", @"loging out...")];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        EMError *error = [[EMClient sharedClient] logout:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf hideHud];
            
            if (error != nil) {
                [weakSelf showHint:error.errorDescription];
            }
            else {
                [[ApplyViewController shareController] clear];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
            }
        });
    });
}
 
@end
