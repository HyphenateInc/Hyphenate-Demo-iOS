/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMGroupTransferOwnerViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMNotificationNames.h"

@interface EMGroupTransferOwnerViewController ()

@property (nonatomic, strong) EMGroup *group;

@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIView *selectedView;

@end

@implementation EMGroupTransferOwnerViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        _group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupNavigationBar];
    
    self.showRefreshHeader = YES;
    self.showRefreshFooter = YES;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.selectedView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar

- (void)_setupNavigationBar
{
    self.title = NSLocalizedString(@"title.transferOwner",@"Transfer Owner");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [doneButton setTitle:NSLocalizedString(@"button.save", @"Save") forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithRed:79 / 255.0 green:175 / 255.0 blue:36 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.leftLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    if (indexPath == self.selectedIndexPath) {
        cell.accessoryView = self.selectedView;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectedIndexPath) {
        EMMemberCell *oldCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        oldCell.accessoryView = nil;
    }
    
    if (self.selectedIndexPath == indexPath) {
        self.selectedIndexPath = nil;
        return;
    }
    
    self.selectedIndexPath = nil;
    if (self.selectedIndexPath != indexPath) {
        self.selectedIndexPath = indexPath;
        
        EMMemberCell *cell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
        cell.accessoryView = self.selectedView;
    }
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction
{
    if (self.selectedIndexPath) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *newOwner = [self.dataArray objectAtIndex:self.selectedIndexPath.row];
        
        __weak typeof(self) weakSelf = self;
        [[EMClient sharedClient].groupManager updateGroupOwner:self.group.groupId newOwner:newOwner completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            weakSelf.group = aGroup;
            if (aError) {
                [weakSelf showHint:NSLocalizedString(@"group.changeOwnerFail", @"Failed to change owner")];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUP_INFO object:weakSelf.group];
                [weakSelf backAction];
            }
        }];
    }
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.group.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
        });
        
        if (!error) {
            weakSelf.group = group;
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:weakSelf.group.adminList];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cursor = @"";
                [weakSelf fetchMembersWithPage:weakSelf.page isHeader:YES];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
            });
        }
    });
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithPage:self.page isHeader:NO];
}

- (void)fetchMembersWithPage:(NSInteger)aPage
                    isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError) {
            [weakSelf.dataArray addObjectsFromArray:aResult.list];
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"failed to get the member list, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
    }];
}

@end
