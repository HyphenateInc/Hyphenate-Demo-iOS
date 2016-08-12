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

#import "PushNotificationViewController.h"

@interface PushNotificationViewController ()

@property (strong, nonatomic) UISwitch *pushDisplaySwitch;
@property (assign, nonatomic) EMPushDisplayStyle pushDisplayStyle;
@property (assign, nonatomic) EMPushNoDisturbStatus noDisturbingStatus;
@property (assign, nonatomic) NSInteger noDisturbingStart;
@property (assign, nonatomic) NSInteger noDisturbingEnd;
@property (strong, nonatomic) NSString *nickName;

@end

@implementation PushNotificationViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.noDisturbingStart = -1;
        self.noDisturbingEnd = -1;
        self.noDisturbingStatus = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.apnsSetting", @"Push Notification");
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self loadPushOptions];
    
    [self.tableView reloadData];
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
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UISwitch *)pushDisplaySwitch
{
    if (_pushDisplaySwitch == nil) {
        _pushDisplaySwitch = [[UISwitch alloc] init];
        [_pushDisplaySwitch addTarget:self action:@selector(pushDisplayChanged:) forControlEvents:UIControlEventValueChanged];
    }
    
    return _pushDisplaySwitch;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1)
    {
        return 3;
    }
    
    return 0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"setting.notDisturb", @"Do Not Disturb");
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            self.pushDisplaySwitch.frame = CGRectMake(self.tableView.frame.size.width - self.pushDisplaySwitch.frame.size.width - 10, (cell.contentView.frame.size.height - self.pushDisplaySwitch.frame.size.height) / 2, self.pushDisplaySwitch.frame.size.width, self.pushDisplaySwitch.frame.size.height);
            [cell.contentView addSubview:self.pushDisplaySwitch];
            
            CGRect frame = cell.textLabel.frame;
            frame.size.width -= self.pushDisplaySwitch.frame.size.width;
            UILabel *textLabel = [[UILabel alloc] initWithFrame:frame];
            textLabel.text = NSLocalizedString(@"setting.showDetail", @"notify the display messages");
            [cell.contentView addSubview:textLabel];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.open", @"On");
            cell.accessoryType = self.noDisturbingStatus == EMPushNoDisturbStatusDay ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 1)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.nightOpen", @"On only from 10pm to 7am.");
            cell.accessoryType = self.noDisturbingStatus == EMPushNoDisturbStatusCustom ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
        else if (indexPath.row == 2)
        {
            cell.textLabel.text = NSLocalizedString(@"setting.close", @"Off");
            cell.accessoryType = self.noDisturbingStatus == EMPushNoDisturbStatusClose ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 30;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL needReload = YES;
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
            {
                needReload = NO;
                [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                        message:NSLocalizedString(@"setting.sureNotDisturb", @"this setting will cause all day in the don't disturb mode, will no longer receive push messages. Whether or not to continue?")
                                completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                                    switch (buttonIndex) {
                                        case 0: {
                                        } break;
                                        default: {
                                            self.noDisturbingStart = 0;
                                            self.noDisturbingEnd = 24;
                                            self.noDisturbingStatus = EMPushNoDisturbStatusDay;
                                            [tableView reloadData];
                                        } break;
                                    }
                                    
                                } cancelButtonTitle:NSLocalizedString(@"no", @"NO")
                              otherButtonTitles:NSLocalizedString(@"yes", @"YES"), nil];
                
            } break;
            case 1:
            {
                self.noDisturbingStart = 22;
                self.noDisturbingEnd = 7;
                self.noDisturbingStatus = EMPushNoDisturbStatusCustom;
            }
                break;
            case 2:
            {
                self.noDisturbingStart = -1;
                self.noDisturbingEnd = -1;
                self.noDisturbingStatus = EMPushNoDisturbStatusClose;
            }
                break;
                
            default:
                break;
        }
        
        if (needReload) {
            [tableView reloadData];
        }
        
        [self savePushOptions];
    }
}


#pragma mark - action

- (void)savePushOptions
{
    BOOL isUpdated = NO;
    
    // push summery vs detailed
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    if (self.pushDisplayStyle != options.displayStyle) {
        options.displayStyle = self.pushDisplayStyle;
        isUpdated = YES;
    }
    
    // APNs nickname
    if (self.nickName && self.nickName.length > 0 && ![self.nickName isEqualToString:options.nickname]) {
        options.nickname = self.nickName;
        isUpdated = YES;
    }
    
    // Do Not Disturb option
    if (options.noDisturbingStartH != self.noDisturbingStart || options.noDisturbingEndH != self.noDisturbingEnd){
        options.noDisturbStatus = self.noDisturbingStatus;
        options.noDisturbingStartH = self.noDisturbingStart;
        options.noDisturbingEndH = self.noDisturbingEnd;
        isUpdated = YES;
    }
    
    __weak typeof(self) weakself = self;
    if (isUpdated) {
        [[EMClient sharedClient] updatePushNotificationOptionsToServerWithCompletion:^(EMError *aError) {
            if (!aError) {
                [weakself.navigationController popViewControllerAnimated:YES];
            }
            else {
                [weakself showHint:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"error.save", @"Failed to save"), aError.errorDescription]];
            }
        }];
    }
}

- (void)pushDisplayChanged:(UISwitch *)pushDisplaySwitch
{
    if (pushDisplaySwitch.isOn) {
        self.pushDisplayStyle = EMPushDisplayStyleMessageSummary;
    }
    else {
        self.pushDisplayStyle = EMPushDisplayStyleSimpleBanner;
    }
    
    [self savePushOptions];
}

- (void)loadPushOptions
{
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] getPushNotificationOptionsFromServerWithCompletion:^(EMPushOptions *aOptions, EMError *aError) {
        if (!aError) {
            [weakself refreshPushOptions];
        }
        else {
        }
    }];
}

- (void)refreshPushOptions
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    self.nickName = options.nickname;
    self.pushDisplayStyle = options.displayStyle;
    self.noDisturbingStatus = options.noDisturbStatus;
    if (self.noDisturbingStatus != EMPushNoDisturbStatusClose) {
        self.noDisturbingStart = options.noDisturbingStartH;
        self.noDisturbingEnd = options.noDisturbingEndH;
    }
    
    BOOL isDisplayOn = self.pushDisplayStyle == EMPushDisplayStyleSimpleBanner ? NO : YES;
    
    [self.pushDisplaySwitch setOn:isDisplayOn animated:YES];
    
    [self.tableView reloadData];
}

@end
