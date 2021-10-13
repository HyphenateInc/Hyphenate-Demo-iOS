/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatroomsViewController.h"
#import "AgoraGroupCell.h"
#import "AgoraGroupModel.h"
#import "AgoraNotificationNames.h"
#import "AgoraGroupInfoViewController.h"
#import "AgoraChatViewController.h"

#import "AgoraChatroomCell.h"
#import "UIViewController+HUD.h"

@interface AgoraChatroomsViewController ()

@end

@implementation AgoraChatroomsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(destroyChatroom:) name:KAgora_DESTROY_CHATROOM_NOTIFICATION object:nil];
    
    [self setupNavBar];
    
    self.tableView.rowHeight = 50;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Layout subviews

- (void)setupNavBar
{
    self.title = NSLocalizedString(@"common.chatrooms", @"Chatrooms");
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 20, 20);
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [leftBtn setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateHighlighted];
    [leftBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBar = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    [self.navigationItem setLeftBarButtonItem:leftBar];
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Notification Method

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
    static NSString *cellIdentifier = @"AgoraChatroomCell";
    AgoraChatroomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AgoraChatroomCell" owner:self options:nil] lastObject];
    }
    
    AgoraChatroom *chatroom = [self.dataArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = chatroom.subject;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AgoraChatroom *chatroom = self.dataArray[indexPath.row];
    
    AgoraChatConversation *conversation = [[AgoraChatClient sharedClient].chatManager getConversation:chatroom.chatroomId type:AgoraChatConversationTypeChatRoom createIfNotExist:YES];
    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    [ext setObject:chatroom.subject forKey:@"subject"];
    conversation.ext = ext;
    
    AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:chatroom.chatroomId conversationType:AgoraChatConversationTypeChatRoom];
    chatViewController.title = chatroom.subject;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0f;
}

#pragma mark - Notification

- (void)destroyChatroom:(NSNotification *)aNotification
{
    id obj = aNotification.object;
    if (obj && [obj isKindOfClass:[AgoraChatroom class]]) {
        AgoraChatroom *chatroom = (AgoraChatroom *)obj;
        for (AgoraChatroom *room in self.dataArray) {
            if ([room.chatroomId isEqualToString:chatroom.chatroomId]) {
                [self.dataArray removeObject:room];
                [self.tableView reloadData];
                break;
            }
        }
    }
}

#pragma mark - Data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchChatroomsWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchChatroomsWithPage:self.page isHeader:NO];
}

- (void)fetchChatroomsWithPage:(NSInteger)aPage
                      isHeader:(BOOL)aIsHeader
{
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[AgoraChatClient sharedClient].roomManager getChatroomsFromServerWithPage:self.page pageSize:50 completion:^(AgoraChatPageResult *aResult, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        
        if (aError) {
            [self showAlertWithMessage:NSLocalizedString(@"hud.fail", @"Get chatroom list failure.")];
            return ;
        }
        
        if (aIsHeader) {
            [self.dataArray removeAllObjects];
        }
        [weakSelf.dataArray addObjectsFromArray:aResult.list];
        
        if (aResult.count < 50 ) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
        
        [weakSelf.tableView reloadData];
    }];
}

@end
