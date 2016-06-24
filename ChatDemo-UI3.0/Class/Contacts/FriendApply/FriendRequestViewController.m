/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "FriendRequestViewController.h"

#import "ApplyFriendCell.h"
#import "InvitationManager.h"

static FriendRequestViewController *controller = nil;

@interface FriendRequestViewController ()<ApplyFriendCellDelegate>

@end

@implementation FriendRequestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (instancetype)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[self alloc] initWithStyle:UITableViewStylePlain];
    });
    
    return controller;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"title.apply", @"Requests and Notifications");
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    [self loadDataSourceFromLocalDB];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
//    [self.tableView reloadData];
}

#pragma mark - getter

- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    
    return _dataSource;
}

- (NSString *)loginUsername
{
    return [[EMClient sharedClient] currentUsername];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplyFriendCell";
    ApplyFriendCell *cell = (ApplyFriendCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[ApplyFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if(self.dataSource.count > indexPath.row)
    {
        RequestEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        if (entity) {
            cell.indexPath = indexPath;
            HIRequestType requestType = [entity.style intValue];
            if (requestType == HIRequestTypeReceivedGroupInvitation) {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"group"];
            }
            else if (requestType == HIRequestTypeJoinGroup)
            {
                cell.titleLabel.text = NSLocalizedString(@"title.groupApply", @"Group Notification");
                cell.headerImageView.image = [UIImage imageNamed:@"group"];
            }
            else if(requestType == HIRequestTypeFriend){
                cell.titleLabel.text = entity.applicantUsername;
                cell.headerImageView.image = [UIImage imageNamed:@"chatListCellHead"];
            }
            cell.contentLabel.text = entity.reason;
        }
    }
    
    return cell;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RequestEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
    return [ApplyFriendCell heightWithContent:entity.reason];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ApplyFriendCellDelegate

- (void)applyCellAddFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        [self showHudInView:self.view hint:NSLocalizedString(@"sendingApply", @"sending apply...")];
        
        RequestEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        HIRequestType requestType = [entity.style intValue];
        __weak typeof(self) weakSelf = self;
        dispatch_block_t successBlock = ^{
            [weakSelf hideHud];
            [weakSelf.dataSource removeObject:entity];
            NSString *loginUsername = [[EMClient sharedClient] currentUsername];
            [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
            [weakSelf.tableView reloadData];
        };
        
        dispatch_block_t errorBlock = ^{
            [weakSelf hideHud];
            [weakSelf showHint:NSLocalizedString(@"acceptFail", @"accept failure")];
        };
        
        if (requestType == HIRequestTypeReceivedGroupInvitation) {
            [[EMClient sharedClient].groupManager asyncAcceptInvitationFromGroup:entity.groupId inviter:entity.applicantUsername success:^(EMGroup *aGroup) {
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
        else if (requestType == HIRequestTypeJoinGroup)
        {
            [[EMClient sharedClient].groupManager asyncAcceptJoinApplication:entity.groupId applicant:entity.applicantUsername success:^{
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
        else if(requestType == HIRequestTypeFriend){
            [[EMClient sharedClient].contactManager asyncAcceptInvitationForUsername:entity.applicantUsername success:^{
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
    }
}

- (void)applyCellRefuseFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.dataSource count]) {
        [self showHudInView:self.view hint:NSLocalizedString(@"sendingApply", @"sending apply...")];
        RequestEntity *entity = [self.dataSource objectAtIndex:indexPath.row];
        HIRequestType requestType = [entity.style intValue];
        
        __weak typeof(self) weakSelf = self;
        dispatch_block_t successBlock = ^{
            [weakSelf hideHud];
            [weakSelf.dataSource removeObject:entity];
            NSString *loginUsername = [[EMClient sharedClient] currentUsername];
            [[InvitationManager sharedInstance] removeInvitation:entity loginUser:loginUsername];
            [weakSelf.tableView reloadData];
        };
        
        dispatch_block_t errorBlock = ^{
            [weakSelf hideHud];
            [weakSelf showHint:NSLocalizedString(@"rejectFail", @"reject failure")];
        };
        
        if (requestType == HIRequestTypeReceivedGroupInvitation) {
            [[EMClient sharedClient].groupManager asyncDeclineInvitationFromGroup:entity.groupId inviter:entity.applicantUsername reason:nil success:^{
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
        else if (requestType == HIRequestTypeJoinGroup)
        {
            [[EMClient sharedClient].groupManager asyncDeclineJoinApplication:entity.groupId applicant:entity.applicantUsername reason:nil success:^{
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
        else if(requestType == HIRequestTypeFriend){
            [[EMClient sharedClient].contactManager asyncDeclineInvitationForUsername:entity.applicantUsername success:^{
                successBlock();
            } failure:^(EMError *aError) {
                errorBlock();
            }];
        }
    }
}

#pragma mark - public

- (void)addNewRequest:(NSDictionary *)dictionary
{
    if (dictionary && [dictionary count] > 0) {
        NSString *applyUsername = [dictionary objectForKey:@"username"];
        HIRequestType style = [[dictionary objectForKey:@"requestType"] intValue];
        
        if (applyUsername && applyUsername.length > 0) {
            for (int i = ((int)[_dataSource count] - 1); i >= 0; i--) {
                RequestEntity *oldEntity = [_dataSource objectAtIndex:i];
                HIRequestType oldStyle = [oldEntity.style intValue];
                if (oldStyle == style && [applyUsername isEqualToString:oldEntity.applicantUsername]) {
                    if(style != HIRequestTypeFriend)
                    {
                        NSString *newGroupid = [dictionary objectForKey:@"groupname"];
                        if (newGroupid || [newGroupid length] > 0 || [newGroupid isEqualToString:oldEntity.groupId]) {
                            break;
                        }
                    }
                    
                    oldEntity.reason = [dictionary objectForKey:@"applyMessage"];
                    [_dataSource removeObject:oldEntity];
                    [_dataSource insertObject:oldEntity atIndex:0];
                    [self.tableView reloadData];
                    
                    return;
                }
            }
            
            //new apply
            RequestEntity * newEntity= [[RequestEntity alloc] init];
            newEntity.applicantUsername = [dictionary objectForKey:@"username"];
            newEntity.style = [dictionary objectForKey:@"requestType"];
            newEntity.reason = [dictionary objectForKey:@"applyMessage"];
            
            NSString *loginName = [[EMClient sharedClient] currentUsername];
            newEntity.receiverUsername = loginName;
            
            NSString *groupId = [dictionary objectForKey:@"groupId"];
            newEntity.groupId = (groupId && groupId.length > 0) ? groupId : @"";
            
            NSString *groupSubject = [dictionary objectForKey:@"groupname"];
            newEntity.groupSubject = (groupSubject && groupSubject.length > 0) ? groupSubject : @"";
            
            NSString *loginUsername = [[EMClient sharedClient] currentUsername];
            [[InvitationManager sharedInstance] addInvitation:newEntity loginUser:loginUsername];
            
            [_dataSource insertObject:newEntity atIndex:0];
            [self.tableView reloadData];

        }
    }
}

- (void)loadDataSourceFromLocalDB
{
    [_dataSource removeAllObjects];
    NSString *loginName = [self loginUsername];
    if(loginName && [loginName length] > 0)
    {
        NSArray * applyArray = [[InvitationManager sharedInstance] getSavedFriendRequests:loginName];
        [self.dataSource addObjectsFromArray:applyArray];
        
        [self.tableView reloadData];
    }
}

- (void)backAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRequestCount" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clear
{
    [_dataSource removeAllObjects];
    [self.tableView reloadData];
}

@end
