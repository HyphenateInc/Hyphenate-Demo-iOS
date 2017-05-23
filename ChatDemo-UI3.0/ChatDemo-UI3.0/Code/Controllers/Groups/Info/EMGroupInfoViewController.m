/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMGroupInfoViewController.h"

#import <Hyphenate/EMGroup.h>
#import "UIViewController+HUD.h"
#import "EMUserModel.h"
#import "EMAlertView.h"
#import "EMMemberCell.h"
#import "EMGroupOccupantsViewController.h"
#import "EMGroupAdminsViewController.h"
#import "EMGroupMutesViewController.h"
#import "EMGroupBansViewController.h"
#import "EMGroupTransferOwnerViewController.h"
#import "EMMemberSelectViewController.h"
#import "EMGroupUpdateSubjectViewController.h"
#import "EMNotificationNames.h"

@interface EMGroupInfoViewController ()<EMGroupUIProtocol>

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *groupId;

@property (nonatomic, strong) UIBarButtonItem *addMemberItem;
@property (nonatomic, strong) NSArray *showMembers;

@property (nonatomic) NSInteger moreCellIndex;
@property (nonatomic, strong) UITableViewCell *moreCell;

@property (nonatomic, strong) UIButton *leaveButton;
@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UISwitch *blockMsgSwitch;
@property (nonatomic, strong) UISwitch *pushSwitch;

@end

@implementation EMGroupInfoViewController

- (instancetype)initWithGroupId:(NSString *)aGroupId
{
    self = [super init];
    if (self) {
        _groupId = aGroupId;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUI:) name:KEM_REFRESH_GROUP_INFO object:nil];
    
    [self _setupNavigationBar];
    [self _setupSubviews];
    
    self.tableView.backgroundColor = [UIColor colorWithRed: 226 / 255.0 green: 231 / 255.0 blue: 235 / 255.0 alpha:1.0];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 20;
    self.tableView.sectionIndexBackgroundColor = [UIColor redColor];
    self.tableView.tableFooterView = self.footerView;
    [self.tableView reloadData];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self reloadUI];
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
    self.title = NSLocalizedString(@"title.groupInfo", @"Group Info");
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [addButton setImage:[UIImage imageNamed:@"Button_AddUser"] forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addMemberAction) forControlEvents:UIControlEventTouchUpInside];
    self.addMemberItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    //footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 70)];
    _footerView.backgroundColor = [UIColor clearColor];
    
//    UIButton *clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, _footerView.frame.size.width, 50)];
//    clearButton.accessibilityIdentifier = @"clear_message";
//    [clearButton setTitle:NSLocalizedString(@"message.clear", @"Clear All Messages") forState:UIControlStateNormal];
//    [clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [clearButton addTarget:self action:@selector(clearMessagesAction) forControlEvents:UIControlEventTouchUpInside];
//    [clearButton setBackgroundColor:[UIColor colorWithRed:21 / 255.0 green:155 / 255.0 blue:80 / 255.0 alpha:1.0]];
//    [_footerView addSubview:clearButton];
    
    _leaveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, _footerView.frame.size.width, 50)];
    _leaveButton.accessibilityIdentifier = @"leave";
    [_leaveButton setTitle:NSLocalizedString(@"group.leave", @"Leave Group") forState:UIControlStateNormal];
    [_leaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_leaveButton addTarget:self action:@selector(leaveAction) forControlEvents:UIControlEventTouchUpInside];
    [_leaveButton setBackgroundColor:[UIColor colorWithRed:251 / 255.0 green:60 / 255.0 blue:48 / 255.0 alpha:1.0]];
    [_footerView addSubview:_leaveButton];
    
    //more cell
    _moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
    _moreCell.contentView.backgroundColor = [UIColor colorWithRed: 249 / 255.0 green: 250 / 255.0 blue: 251 / 255.0 alpha:1.0];
    
    UIButton *moreButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 50)];
    moreButton.backgroundColor = [UIColor colorWithRed:249 / 255.0 green:250 / 255.0 blue:251 / 255.0 alpha:1.0];
    [moreButton setTitle:NSLocalizedString(@"button.more", @"Load More") forState:UIControlStateNormal];
    [moreButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreMemberAction) forControlEvents:UIControlEventTouchUpInside];
    [_moreCell.contentView addSubview:moreButton];
    
    //block message switch
    _blockMsgSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 80, 5, 70, 50)];
    [_blockMsgSwitch addTarget:self action:@selector(blockMessageChangeValue) forControlEvents:UIControlEventValueChanged];
    
    //push switch
    _pushSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 80, 5, 70, 50)];
    [_pushSwitch addTarget:self action:@selector(pushChangeValue) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (section == 0) {
        count = [self.group.adminList count];
        if (count > 2) {
            count = 3;
        } else {
            count += 1;
        }
    } else if(section == 1) {
        count = [self.showMembers count];
        if (count > 3) {
            count = 4;
        } else {
            count += 1;
        }
        
        self.moreCellIndex = count - 1;
    } else if (section == 2) {
        if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
            count = 10;
        } else {
            count = 5;
        }
    }
    
    return count;
}

- (UITableViewCell *)_setupCellForSection2:(UITableView *)tableView row:(NSInteger)row
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    }
    
    cell.detailTextLabel.text = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (row) {
        case 0:
            cell.textLabel.text = NSLocalizedString(@"group.id",@"Group ID");
            cell.detailTextLabel.text = self.groupId;
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"group.groupType", @"Group Type");
            cell.detailTextLabel.text = self.group.isPublic ? NSLocalizedString(@"group.public", @"Public") : NSLocalizedString(@"group.private", @"Private");
            break;
        case 2:
            cell.textLabel.text = NSLocalizedString(@"group.block", @"Block");
            [cell.contentView addSubview:self.blockMsgSwitch];
            break;
        case 3:
            cell.textLabel.text = NSLocalizedString(@"group.pushNotification", @"Push Notification");
            [cell.contentView addSubview:self.pushSwitch];
            break;
        case 4:
            cell.textLabel.text = NSLocalizedString(@"message.clear", @"Clear All Messages");
            break;
        case 5:
            cell.textLabel.text = NSLocalizedString(@"title.transferOwner", @"Transfer Owner");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 6:
            cell.textLabel.text = NSLocalizedString(@"title.updateGroupName", @"Update group name");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 7:
            cell.textLabel.text = NSLocalizedString(@"title.adminList", @"Admin List");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 8:
            cell.textLabel.text = NSLocalizedString(@"title.blacklist", @"Blacklist");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 9:
            cell.textLabel.text = NSLocalizedString(@"title.muteList", @"Mute List");
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1 && row == self.moreCellIndex) {
        return self.moreCell;
    }
    
    if (section == 2) {
        return [self _setupCellForSection2:tableView row:row];
    }
    
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.rightLabel.text = @"";
    if (section == 0) {
        if (row == 0) {
            cell.leftLabel.text = self.group.owner;
            cell.rightLabel.text = @"owner";
        } else {
            cell.leftLabel.text = [self.group.adminList objectAtIndex:(row - 1)];
            cell.rightLabel.text = @"admin";
        }
    } else if (section == 1) {
        cell.leftLabel.text = [self.showMembers objectAtIndex:row];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 20)];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:13];
    if (section == 0) {
        headerLabel.backgroundColor = [UIColor colorWithRed: 157 / 255.0 green: 170 / 255.0 blue: 179 / 255.0 alpha:1.0];
        headerLabel.text = NSLocalizedString(@"group.sectionHeaderOwnerAndAdmin", @"  Owner and Admin List");
    } else if (section == 1) {
        headerLabel.backgroundColor = [UIColor colorWithRed: 157 / 255.0 green: 170 / 255.0 blue: 179 / 255.0 alpha:1.0];
        headerLabel.text = NSLocalizedString(@"group.sectionHeaderMembers", @"  Member List");
    } else {
        headerLabel.backgroundColor = [UIColor colorWithRed: 226 / 255.0 green: 231 / 255.0 blue: 235 / 255.0 alpha:1.0];
        headerLabel.text = @"  ";
    }
    
    return headerLabel;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    if (section != 2) {
        return;
    }
    
    NSInteger row = indexPath.row;
    switch (row) {
        case 4:
        {
            [self clearMessagesAction];
        }
            break;
        case 5:
        {
            if (self.group.permissionType == EMGroupPermissionTypeOwner) {
                EMGroupTransferOwnerViewController *transferController = [[EMGroupTransferOwnerViewController alloc] initWithGroup:self.group];
                [self.navigationController pushViewController:transferController animated:YES];
            } else {
                [self showHint:@"只有Owner能进行此操作"];
            }
        }
            break;
        case 6:
        {
            if (self.group.permissionType == EMGroupPermissionTypeOwner) {
                EMGroupUpdateSubjectViewController *updateController = [[EMGroupUpdateSubjectViewController alloc] initWithGroupId:self.groupId subject:self.group.subject];
                [self.navigationController pushViewController:updateController animated:YES];
            } else {
                [self showHint:@"只有Owner能进行此操作"];
            }
        }
            break;
        case 7:
        {
            EMGroupAdminsViewController *adminController = [[EMGroupAdminsViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:adminController animated:YES];

        }
            break;
        case 8:
        {
            EMGroupBansViewController *bansController = [[EMGroupBansViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:bansController animated:YES];
        }
            break;
        case 9:
        {
            EMGroupMutesViewController *mutesController = [[EMGroupMutesViewController alloc] initWithGroup:self.group];
            [self.navigationController pushViewController:mutesController animated:YES];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - EMGroupUIProtocol

- (void)addSelectOccupants:(NSArray<EMUserModel *> *)modelArray
{
    NSInteger maxUsersCount = self.group.setting.maxUsersCount;
    if (([modelArray count] + self.group.occupantsCount) > maxUsersCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.maxUserCount", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];

        return;
    }

    [self.navigationController popToViewController:self animated:YES];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (EMUserModel *model in modelArray) {
            [source addObject:model.hyphenateId];
        }

        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.invite", @"%@ invite you to group: %@ [%@]"), username, weakSelf.group.subject, weakSelf.group.groupId];
        EMError *error = nil;
        weakSelf.group = [[EMClient sharedClient].groupManager addOccupants:source toGroup:weakSelf.groupId welcomeMessage:messageStr error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:weakSelf.view animated:YES];
            if (!error) {
                [weakSelf.tableView reloadData];
            }
            else {
                [weakSelf showHint:error.errorDescription];
            }
            
        });
    });
}

#pragma mark - Action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)addMemberAction
{
    NSMutableArray *occupants = [[NSMutableArray alloc] init];
    [occupants addObject:self.group.owner];
    [occupants addObjectsFromArray:self.group.adminList];
    [occupants addObjectsFromArray:self.group.memberList];
    
    NSMutableArray *occupantModels = [[NSMutableArray alloc] init];
    for (NSString *username in occupants) {
        EMUserModel *model = [[EMUserModel alloc] initWithHyphenateId:username];
        [occupantModels addObject:model];
    }
    EMMemberSelectViewController *selectionController = [[EMMemberSelectViewController alloc] initWithInvitees:occupantModels maxInviteCount:0];
    selectionController.style = EMContactSelectStyle_Invite;
    selectionController.title = NSLocalizedString(@"title.inviteContacts", @"Invite Contacts");
    selectionController.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectionController];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)moreMemberAction
{
    EMGroupOccupantsViewController *allController = [[EMGroupOccupantsViewController alloc] initWithGroupId:self.groupId];
    [self.navigationController pushViewController:allController animated:YES];
}

- (void)clearMessagesAction
{
    __weak typeof(self) weakSelf = self;
    [EMAlertView showAlertWithTitle:NSLocalizedString(@"button.prompt", @"Prompt")
                            message:NSLocalizedString(@"chat.clearMsg", @"Do you want to delete all messages?")
                    completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                        if (buttonIndex == 1) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATIONNAME_DELETEALLMESSAGE object:weakSelf.groupId];
                        }
                    } cancelButtonTitle:NSLocalizedString(@"button.cancel", @"Cancel")
                  otherButtonTitles:NSLocalizedString(@"button.ok", @"OK"), nil];
}

- (void)leaveAction
{
    __weak typeof(self) weakSelf = self;
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            EMError *error = [[EMClient sharedClient].groupManager destroyGroup:weakSelf.group.groupId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                if (error) {
                    [weakSelf showHint:NSLocalizedString(@"group.destroyFailure", @"dissolution of group failure")];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_LEAVE_GROUP object:weakSelf.groupId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                }
            });
        });
        
    } else {
        [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"Leave group")];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
            EMError *error = nil;
            [[EMClient sharedClient].groupManager leaveGroup:weakSelf.group.groupId error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf hideHud];
                if (error) {
                    [weakSelf showHint:NSLocalizedString(@"group.leaveFailure", @"exit the group failure")];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_LEAVE_GROUP object:weakSelf.groupId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_GROUPLIST_NOTIFICATION object:nil];
                }
            });
        });
    }
}

- (void)blockMessageChangeValue
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    if (self.blockMsgSwitch.isOn) {
        [[EMClient sharedClient].groupManager blockGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            weakSelf.group = aGroup;
            if (aError) {
                [weakSelf.blockMsgSwitch setOn:NO animated:YES];
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Operation failed")];
            }
        }];
    } else {
        [[EMClient sharedClient].groupManager unblockGroup:self.group.groupId completion:^(EMGroup *aGroup, EMError *aError) {
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
            weakSelf.group = aGroup;
            if (aError) {
                [weakSelf.blockMsgSwitch setOn:YES animated:YES];
                [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Operation failed")];
            }
        }];
    }
    
}

- (void)pushChangeValue
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager updatePushServiceForGroup:self.group.groupId isPushEnabled:self.pushSwitch.isOn completion:^(EMGroup *aGroup, EMError *aError) {
        [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        
        weakSelf.group = aGroup;
        if (aError) {
            [weakSelf.pushSwitch setOn:!weakSelf.group.isPushNotificationEnabled animated:YES];
            [weakSelf showHint:NSLocalizedString(@"hud.fail", @"Operation failed")];
        }
    }];
}

- (void)updateUI:(NSNotification *)aNotif
{
    id obj = aNotif.object;
    if (obj && [obj isKindOfClass:[EMGroup class]]) {
        self.group = (EMGroup *)obj;
    }
    
    [self reloadUI];
}

- (void)reloadUI
{
    if (self.group.permissionType == EMGroupPermissionTypeOwner) {
        [self.leaveButton setTitle:NSLocalizedString(@"group.destroy", @"Destroy Group") forState:UIControlStateNormal];
    } else {
        [self.leaveButton setTitle:NSLocalizedString(@"group.leave", @"Leave Group") forState:UIControlStateNormal];
    }
    
    if ([self isCanInvite]) {
        self.navigationItem.rightBarButtonItem = self.addMemberItem;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.blockMsgSwitch setOn:self.group.isBlocked animated:YES];
    [self.pushSwitch setOn:self.group.isPushNotificationEnabled animated:YES];
    
    [self.tableView reloadData];
}

- (BOOL)isCanInvite
{
    return (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin || self.group.setting.style == EMGroupStylePrivateMemberCanInvite);
}

#pragma mark - DataSource

- (void)tableViewDidTriggerHeaderRefresh
{
    [self fetchGroupInfo];
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
            
            [weakSelf fetchGroupMembers];
        }
        else{
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
}

- (void)fetchGroupMembers
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.groupId cursor:@"" pageSize:10 completion:^(EMCursorResult *aResult, EMError *aError) {
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:YES];
        if (!aError) {
            weakSelf.showMembers = aResult.list;
            [weakSelf reloadUI];
        } else {
            [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
        }
    }];
}


@end
