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

#import "AddFriendViewController.h"

#import "FriendRequestViewController.h"
#import "AddFriendCell.h"
#import "InvitationManager.h"

@interface AddFriendViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UITextField *addFriendTextField;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@end

@implementation AddFriendViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.title = NSLocalizedString(@"friend.add", @"Add friend");
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = self.headerView;
    
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = footerView;
    
    UIBarButtonItem *addBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Add"
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(addUserAction)];
    self.navigationItem.rightBarButtonItem = addBarButtonItem;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    [self.view addSubview:self.addFriendTextField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter

- (UITextField *)addFriendTextField
{
    if (_addFriendTextField == nil) {
        
        _addFriendTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 10, self.view.frame.size.width - 20, 40)];
        _addFriendTextField.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        _addFriendTextField.layer.borderWidth = 0.5;
        _addFriendTextField.layer.cornerRadius = 6;
        _addFriendTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 30)];
        _addFriendTextField.leftViewMode = UITextFieldViewModeAlways;
        _addFriendTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _addFriendTextField.font = [UIFont systemFontOfSize:15.0];
        _addFriendTextField.backgroundColor = [UIColor whiteColor];
        _addFriendTextField.placeholder = NSLocalizedString(@"friend.inputNameToSearch", @"Enter friend's username");
        _addFriendTextField.returnKeyType = UIReturnKeyDone;
        _addFriendTextField.delegate = self;
    }
    
    return _addFriendTextField;
}

- (UIView *)headerView
{
    if (_headerView == nil) {
        
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 60)];
        _headerView.backgroundColor = [UIColor whiteColor];
        
        [_headerView addSubview:self.addFriendTextField];
    }
    
    return _headerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
//    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddFriendCell";
    
    AddFriendCell *cell = (AddFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AddFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedIndexPath = indexPath;
    
    NSString *friendName = [self.dataSource objectAtIndex:indexPath.row];
    [self sendUserFriendRequest:friendName];
}

- (void)sendUserFriendRequest:(NSString *)friendName
{
    if ([self isUsernameExist:friendName]) {
        
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.repeat", @"'%@' is already your friend"), friendName];
        
        [EMAlertView showAlertWithTitle:message
                                message:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
        
    }
    else if ([self hasSendUserRequest:friendName])
    {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.repeatApply", @"Send the friend request to '%@' again"), friendName];
        [EMAlertView showAlertWithTitle:message
                                message:nil
                        completionBlock:nil
                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                      otherButtonTitles:nil];
    }
    else
    {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyInvite", @"%@ sent you a friend request"), [[EMClient sharedClient] currentUsername]];
        
        [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendFriendRequest", @"sending friend request...")];
        
        // Currently the method doesn't provide feedback if user exist or not on the server
        [[EMClient sharedClient].contactManager asyncAddContact:friendName message:message success:^{
            
            [self hideHud];

            [self showHint:NSLocalizedString(@"friend.sendFriendRequestSuccess", @"Friend request sent")];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(EMError *aError) {
            
            [self hideHud];

            [self showHint:NSLocalizedString(@"friend.sendFriendRequestFail", @"send friend request fails, please try again")];
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action

- (void)addUserAction
{
    [self.addFriendTextField resignFirstResponder];
    
    NSString *friendName = [self.addFriendTextField.text lowercaseString];
    
    if (friendName.length > 0)
    {
        NSString *loginUsername = [[[EMClient sharedClient] currentUsername] lowercaseString];
        
        if ([[self.addFriendTextField.text lowercaseString] isEqualToString:loginUsername]) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                                message:NSLocalizedString(@"friend.notAddSelf", @"can't add yourself as a friend")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                                      otherButtonTitles:nil, nil];
            
            [alertView show];
            
            return;
        }
        
        // Check friend request list
        if ([self hasUserSentFriendRequest:friendName]) {
            return;
        }
        else {
            [self sendUserFriendRequest:friendName];
        }
        
//        [self.dataSource removeAllObjects];
//        
//        [self.dataSource addObject:self.addFriendTextField.text];
//        
//        [self.tableView reloadData];
    }
}

- (BOOL)hasUserSentFriendRequest:(NSString *)username
{
    NSArray *requests = [[FriendRequestViewController shareController] dataSource];
    
    if (requests && [requests count] > 0) {
        
        for (RequestEntity *entity in requests) {
            
            HIRequestType type = [entity.style intValue];
            
            BOOL isGroup = type == HIRequestTypeFriend ? NO : YES;
            
            if (!isGroup && [entity.applicantUsername isEqualToString:username]) {
                
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"friend.repeatInvite", @"%@ sent an invitation to you"), username];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                                    message:message
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                                          otherButtonTitles:nil, nil];
                
                [alertView show];
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (BOOL)hasSendUserRequest:(NSString *)username
{
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromDB];
    for (NSString *userObject in userlist) {
        if ([username isEqualToString:userObject]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isUsernameExist:(NSString *)username
{
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromDB];
    for (NSString *userObject in userlist) {
        if ([username isEqualToString:userObject]){
            return YES;
        }
    }
    return NO;
}

- (void)sendFriendRequestToUsername:(NSString *)username message:(NSString *)message
{
    if (username && username.length > 0) {
        
        [self showHudInView:self.view hint:NSLocalizedString(@"friend.sendFriendRequest", @"sending friend request...")];
      
        // Currently the method doesn't provide feedback if user exist or not on the server
        [[EMClient sharedClient].contactManager asyncAddContact:username message:message success:^{
            
            [self hideHud];
            
            [self showHint:NSLocalizedString(@"friend.sendFriendRequestSuccess", @"Friend request sent")];
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } failure:^(EMError *aError) {
            
            [self hideHud];
            
            [self showHint:NSLocalizedString(@"friend.sendFriendRequestFail", @"send friend request fails, please try again")];
        }];
    }
}


@end
