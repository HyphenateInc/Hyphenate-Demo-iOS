/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraGroupsViewController.h"
#import "AgoraGroupCell.h"
#import "AgoraGroupModel.h"
#import "AgoraNotificationNames.h"
#import "AgoraGroupInfoViewController.h"
#import "AgoraChatViewController.h"
#import "AgoraCreateViewController.h"

@interface AgoraGroupsViewController ()

@end

@implementation AgoraGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavBar];
    [self addNotifications];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
}

- (void)dealloc {
    [self removeNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadGroupsFromServer];
}

- (void)setupNavBar {
    self.title = NSLocalizedString(@"common.groups", @"Groups");
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addGroupAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:rightBar];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

- (void)loadGroupsFromServer {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)loadGroupsFromCache {
    NSArray *myGroups = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    for (AgoraGroup *group in myGroups) {
        AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    [self tableViewDidFinishTriggerHeader:YES];
    [self.tableView reloadData];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshGroupList:) name:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
}

#pragma mark - Action

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addGroupAction {
    
    AgoraCreateViewController *publicVc = [[AgoraCreateViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publicVc];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];

}

#pragma mark - Notification Method

- (void)refreshGroupList:(NSNotification *)notification {
    NSArray *groupList = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
    [self.dataArray removeAllObjects];
    for (AgoraGroup *group in groupList) {
        AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AgoraGroupCell";
    AgoraGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupCell" owner:self options:nil] lastObject];
    }
    cell.model = self.dataArray[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AgoraGroupModel *model = self.dataArray[indexPath.row];
    AgoraConversation *conversation = [[AgoraChatClient sharedClient].chatManager getConversation:model.hyphenateId type:AgoraConversationTypeGroupChat createIfNotExist:YES];
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:model.subject forKey:@"subject"];
    [ext setObject:[NSNumber numberWithBool:model.group.isPublic] forKey:@"isPublic"];
    conversation.ext = ext;
    
    AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:model.hyphenateId conversationType:AgoraConversationTypeGroupChat];
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchJoinedGroupWithPage:self.page isHeader:NO];
}

- (void)fetchJoinedGroupWithPage:(NSInteger)aPage
                        isHeader:(BOOL)aIsHeader
{
    __weak typeof(self) weakSelf = self;
    
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[AgoraChatClient sharedClient].groupManager getJoinedGroupsFromServerWithPage:self.page pageSize:50 completion:^(NSArray *aList, AgoraError *aError) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        if (!aError && aList.count > 0) {
            [weakSelf.dataArray removeAllObjects];
            for (AgoraGroup *group in aList) {
                AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

@end
