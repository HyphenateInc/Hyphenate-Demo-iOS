/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatroomMembersViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMNotificationNames.h"

@interface EMChatroomMembersViewController ()

@property (nonatomic, strong) EMChatroom *chatroom;
@property (nonatomic, strong) NSString *cursor;

@end

@implementation EMChatroomMembersViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.occupantList", @"Occupant List");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    [self tableViewDidTriggerHeaderRefresh];
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
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    
    NSInteger row = indexPath.row;
    cell.rightLabel.text = nil;
    cell.showAccessoryViewInDelete = [self _isShowCellAccessoryView];
    cell.leftLabel.text = [self.dataArray objectAtIndex:row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
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
    
    UITableViewRowAction *toAdminAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.upgrade", @"Up") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:3];
    }];
    toAdminAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    return @[deleteAction, blackAction, muteAction, toAdminAction];
}

#pragma mark - Action

- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
    
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        if (buttonIndex == 0) { //Remove
            weakSelf.chatroom = [[EMClient sharedClient].roomManager removeMembers:@[userName] fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        } else if (buttonIndex == 1) { //Blacklist
            weakSelf.chatroom = [[EMClient sharedClient].roomManager blockMembers:@[userName] fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        } else if (buttonIndex == 2) {  //Mute
            weakSelf.chatroom = [[EMClient sharedClient].roomManager muteMembers:@[userName] muteMilliseconds:-1 fromChatroom:weakSelf.chatroom.chatroomId error:&error];
        } else if (buttonIndex == 3) {  //To Admin
            weakSelf.chatroom = [[EMClient sharedClient].roomManager addAdmin:userName toChatroom:weakSelf.chatroom.chatroomId error:&error];
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

#pragma mark - private

- (BOOL)_isShowCellAccessoryView
{
    if (self.chatroom.permissionType == EMChatroomPermissionTypeOwner || self.chatroom.permissionType == EMChatroomPermissionTypeAdmin) {
        return YES;
    }
    
    return NO;
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchMembersWithCursor:self.cursor isHeader:YES];
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
    [[EMClient sharedClient].roomManager getChatroomMemberListFromServerWithId:self.chatroom.chatroomId cursor:aCursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        weakSelf.cursor = aResult.cursor;
        
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            
            [weakSelf.dataArray addObjectsFromArray:aResult.list];
            [weakSelf.tableView reloadData];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"Failed to get the group details, please try again later")];
        }
        
        if ([aResult.list count] < pageSize) {
            weakSelf.showRefreshFooter = NO;
        } else {
            weakSelf.showRefreshFooter = YES;
        }
    }];
}

@end
