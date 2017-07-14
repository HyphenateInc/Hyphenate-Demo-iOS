/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMAddAdminViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMNotificationNames.h"

@interface EMAddAdminViewController ()

@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSMutableArray *scrollViewArray;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIScrollView *headerScrollView;

@property (nonatomic,strong) NSString *cursor;

@end

@implementation EMAddAdminViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId
{
    self = [super init];
    if (self) {
        self.groupId = aGroupId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _setupNavigationBar];
    [self _setupHeaderView];
    
    self.selectedArray = [[NSMutableArray alloc] init];
    self.scrollViewArray = [[NSMutableArray alloc] init];
    self.cursor = @"";
    
    self.tableView.rowHeight = 50;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar

- (void)_setupNavigationBar
{
    self.title = NSLocalizedString(@"title.addAdmin", @"Add Admin");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
    [doneButton setTitle:NSLocalizedString(@"button.save", @"Save") forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithRed:79 / 255.0 green:175 / 255.0 blue:36 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = doneItem;
}

#pragma mark - Subviews

- (void)_setupHeaderView
{
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 135)];
    _headerView.backgroundColor = [UIColor whiteColor];
    
    _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, _headerView.frame.size.width - 20, 20)];
    _headerLabel.backgroundColor = [UIColor clearColor];
    _headerLabel.font = [UIFont systemFontOfSize:15];
    [_headerView addSubview:_headerLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _headerView.frame.size.height - 20, _headerView.frame.size.width, 20)];
    lineView.backgroundColor = [UIColor colorWithRed: 226 / 255.0 green: 231 / 255.0 blue: 235 / 255.0 alpha:1.0];
    [_headerView addSubview:lineView];
    
    _headerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_headerLabel.frame) + 8, _headerView.frame.size.width - 20, CGRectGetMinY(lineView.frame) - CGRectGetMaxY(_headerLabel.frame) - 8)];
    _headerScrollView.contentSize = CGSizeMake(0, _headerScrollView.frame.size.height);
    [_headerView addSubview:_headerScrollView];
}

- (void)_addScrollUserView:(NSString *)aUsername
{
    if ([aUsername length] == 0) {
        return;
    }
    
    if ([self.selectedArray count] == 0) {
        self.tableView.tableHeaderView = self.headerView;
    }
    
    [self.selectedArray addObject:aUsername];
    
    NSInteger count = [self.selectedArray count];
    self.headerLabel.text = [NSString stringWithFormat:@"已选（%lu）", (unsigned long)count];
    
    NSInteger width = 40;
    UIView *userView = [[UIView alloc] initWithFrame:CGRectMake((count - 1) * (width + 10), 0, width, self.headerScrollView.frame.size.height)];
    self.headerScrollView.contentSize = CGSizeMake(count * (width + 10), _headerScrollView.frame.size.height);
    [self.scrollViewArray addObject:userView];
    [self.headerScrollView addSubview:userView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    imgView.image = [UIImage imageNamed:@"default_avatar"];
    [userView addSubview:imgView];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imgView.frame), width, CGRectGetHeight(userView.frame) - CGRectGetMaxY(imgView.frame))];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.text = aUsername;
    [userView addSubview:nameLabel];
}

- (void)_removeScrollUserView:(NSString *)aUsername
{
    if ([aUsername length] == 0) {
        return;
    }
    
    NSInteger index = [self.selectedArray indexOfObject:aUsername];
    [self.selectedArray removeObject:aUsername];
    
    NSInteger count = [self.scrollViewArray count];
    UIView *removeView = [self.scrollViewArray objectAtIndex:index];
    CGRect tmpFrame;
    CGRect toFrame = removeView.frame;
    [removeView removeFromSuperview];
    for (NSInteger i = index + 1; i < count; i++) {
        UIView *view = [self.scrollViewArray objectAtIndex:i];
        tmpFrame = view.frame;
        view.frame = toFrame;
        toFrame = tmpFrame;
    }
    [self.scrollViewArray removeObject:removeView];
    
    if ([self.selectedArray count] == 0) {
        self.tableView.tableHeaderView = nil;
    }
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
        
        UIImageView *stateView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 35, 15, 20, 20)];
        stateView.tag = 100;
        stateView.image = [UIImage imageNamed:@""];
        [cell.contentView addSubview:stateView];
    }
    
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.leftLabel.text = username;
    
    UIImageView *rightView = [cell.contentView viewWithTag:100];
    if ([self.selectedArray containsObject:username]) {
        rightView.image = [UIImage imageNamed:@"Group3"];
    } else {
        rightView.image = [UIImage imageNamed:@"oval"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *username = [self.dataArray objectAtIndex:indexPath.row];
    UIImageView *rightView = [[tableView cellForRowAtIndexPath:indexPath].contentView viewWithTag:100];
    if ([self.selectedArray containsObject:username]) {
        rightView.image = [UIImage imageNamed:@"oval"];
        [self _removeScrollUserView:username];
    } else {
        rightView.image = [UIImage imageNamed:@"Group3"];
        [self _addScrollUserView:username];
    }
}

#pragma mark - Action

- (void)doneAction
{
    NSMutableArray *failArray = [[NSMutableArray alloc] init];
    NSMutableString *alertMsg = [[NSMutableString alloc] initWithString:@"Fail："];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = nil;
        for (NSString *userName in weakSelf.selectedArray) {
            error = nil;
            [[EMClient sharedClient].groupManager addAdmin:userName toGroup:weakSelf.groupId error:&error];
            if (error) {
                [failArray addObject:userName];
                [alertMsg appendFormat:@" %@", userName];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if ([failArray count] > 0) {
                [weakSelf showAlertWithMessage:alertMsg];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupAdminList" object:group];
            [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUP_INFO object:group];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    });
    
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchMembersWithCursor:self.cursor isHeader:YES];
    
    /*
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        EMError *error = nil;
        EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.groupId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
        });

        if (!error) {
            weakSelf.groupId = group.groupId;
            [weakSelf.dataArray removeAllObjects];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.cursor = @"";
                [weakSelf fetchMembersWithCursor:weakSelf.cursor isHeader:YES];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
            });
        }
    });
    */
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}

- (void)fetchMembersWithCursor:(NSString *)aCursor
                      isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:aCursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        weakSelf.cursor = aResult.cursor;
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        
        if (aIsHeader) {
            [weakSelf.dataArray removeAllObjects];
        }
        
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
