/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMGroupOccupantsViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMNotificationNames.h"

@interface EMGroupOccupantsViewController ()

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) NSMutableArray *ownerAndAdmins;

@end

@implementation EMGroupOccupantsViewController

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
    
    self.title = NSLocalizedString(@"title.occupantList", @"Occupant List");
    
    _ownerAndAdmins = [[NSMutableArray alloc] init];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    backButton.accessibilityIdentifier = @"back";
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backItem];
    
    self.showRefreshHeader = YES;
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.ownerAndAdmins count];
    }
    
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    cell.rightLabel.text = nil;
    if (section == 0) {
        cell.leftLabel.text = [self.ownerAndAdmins objectAtIndex:row];
        if (row == 0) {
            cell.showAccessoryViewInDelete = NO;
            cell.rightLabel.text = @"owner";
        } else {
            cell.showAccessoryViewInDelete = [self _isShowCellAccessoryView];
            cell.rightLabel.text = @"admin";
        }
    } else {
        cell.showAccessoryViewInDelete = [self _isShowCellAccessoryView];
        cell.leftLabel.text = [self.dataArray objectAtIndex:row];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 0 && row == 0) {
        return NO;
    }
    
    if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
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
    
    if (indexPath.section == 1) {
        return @[deleteAction, blackAction, muteAction, toAdminAction];
    }
    
    return @[deleteAction, blackAction, muteAction];
}

#pragma mark - Action

- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
    NSString *userName = @"";
    if (indexPath.section == 0) {
        userName = [self.ownerAndAdmins objectAtIndex:indexPath.row];
    } else {
        userName = [self.dataArray objectAtIndex:indexPath.row];
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        if (buttonIndex == 0) { //Remove
            weakSelf.group = [[EMClient sharedClient].groupManager removeOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                if (indexPath.section == 0) {
                    [weakSelf.ownerAndAdmins removeObject:userName];
                } else {
                    [weakSelf.dataArray removeObject:userName];
                }
            }
        } else if (buttonIndex == 1) { //Blacklist
            weakSelf.group = [[EMClient sharedClient].groupManager blockOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                if (indexPath.section == 0) {
                    [weakSelf.ownerAndAdmins removeObject:userName];
                } else {
                    [weakSelf.dataArray removeObject:userName];
                }
            }
        } else if (buttonIndex == 2) {  //Mute
            weakSelf.group = [[EMClient sharedClient].groupManager muteMembers:@[userName] muteMilliseconds:-1 fromGroup:weakSelf.group.groupId error:&error];
        } else if (buttonIndex == 3) {  //To Admin
            weakSelf.group = [[EMClient sharedClient].groupManager addAdmin:userName toGroup:weakSelf.group.groupId error:&error];
            if (!error) {
                [weakSelf.ownerAndAdmins addObject:userName];
                [weakSelf.dataArray removeObject:userName];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf hideHud];
            if (!error) {
                if (buttonIndex != 2) {
                    [weakSelf.tableView reloadData];
                } else {
                    [weakSelf showHint:NSLocalizedString(@"group.mute.success", @"Mute success")];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUP_INFO object:weakSelf.group];
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
    if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
        return YES;
    }
    
    return NO;
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchGroupInfo];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithCursor:self.cursor isHeader:NO];
}

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:self.groupId completion:^(EMGroup *aGroup, EMError *aError) {
        [weakSelf hideHud];
        
        if (!aError) {
            weakSelf.group = aGroup;
            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
            if ([aGroup.groupId isEqualToString:conversation.conversationId]) {
                NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                [ext setObject:aGroup.subject forKey:@"subject"];
                [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
                conversation.ext = ext;
            }
            
            [weakSelf.ownerAndAdmins removeAllObjects];
            [weakSelf.ownerAndAdmins addObject:aGroup.owner];
            [weakSelf.ownerAndAdmins addObjectsFromArray:aGroup.adminList];
            
            weakSelf.cursor = @"";
            [weakSelf fetchMembersWithCursor:weakSelf.cursor isHeader:YES];
        }
        else{
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
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
