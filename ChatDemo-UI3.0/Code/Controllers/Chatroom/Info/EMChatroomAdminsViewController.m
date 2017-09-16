/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatroomAdminsViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMAddAdminViewController.h"
#import "EMNotificationNames.h"

@interface EMChatroomAdminsViewController ()

@property (nonatomic, strong) EMChatroom *chatroom;

@end

@implementation EMChatroomAdminsViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
        [self.dataArray addObjectsFromArray:self.chatroom.adminList];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:@"UpdateGroupAdminList" object:nil];
    
    [self _setupNavigationBar];
    self.showRefreshHeader = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Navigation Bar

- (void)_setupNavigationBar
{
    self.title = NSLocalizedString(@"title.adminList", @"Admin List");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
//    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
//    [addButton setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
//    [addButton addTarget:self action:@selector(addAdminAction) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
//    self.navigationItem.rightBarButtonItem = addItem;
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
        cell.showAccessoryViewInDelete = YES;
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.leftLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner) {
        return YES;
    }
    
    return NO;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.remove", @"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:0];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.black", @"Block") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:1];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.mute", @"Mute") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:2];
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    UITableViewRowAction *toMemberAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.demote", @"Demote") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:3];
    }];
    toMemberAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    return @[deleteAction, blackAction, muteAction, toMemberAction];
}

#pragma mark - Action

- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        if (buttonIndex == 0) { //remove
            weakSelf.chatroom = [[EMClient sharedClient].roomManager removeMembers:@[userName] fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        } else if (buttonIndex == 1) { //blacklist
            weakSelf.chatroom = [[EMClient sharedClient].roomManager blockMembers:@[userName] fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        } else if (buttonIndex == 2) {  //mute
            weakSelf.chatroom = [[EMClient sharedClient].roomManager muteMembers:@[userName] muteMilliseconds:-1 fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        }  else if (buttonIndex == 3) {  //to member
            weakSelf.chatroom = [[EMClient sharedClient].roomManager removeAdmin:userName fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (!error) {
                if (buttonIndex != 2) {
                    [weakSelf.dataArray removeObject:userName];
                    [weakSelf.tableView reloadData];
                } else {
                    [weakSelf showHint:NSLocalizedString(@"group.mute.success", @"Mute success")];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_CHATROOM_INFO object:weakSelf.chatroom];
            }
            else {
                [weakSelf showHint:error.errorDescription];
            }
        });
    });
}

- (void)addAdminAction
{
//    EMAddAdminViewController *addController = [[EMAddAdminViewController alloc] initWithGroupId:self.group.groupId];
//    [self.navigationController pushViewController:addController animated:YES];
}

- (void)updateUI:(NSNotification *)aNotification
{
//    id obj = aNotification.object;
//    if (obj && [obj isKindOfClass:[EMGroup class]]) {
//        self.group = (EMGroup *)obj;
//    }
//    
//    [self.dataArray removeAllObjects];
//    [self.dataArray addObjectsFromArray:self.group.adminList];
//    [self.tableView reloadData];
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].roomManager getChatroomSpecificationFromServerWithId:self.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:YES];
        
        if (!aError) {
            weakSelf.chatroom = aChatroom;
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:weakSelf.chatroom.adminList];
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.admin.fetchFail", @"failed to get the admin list, please try again later")];
        }
    }];
}

@end
