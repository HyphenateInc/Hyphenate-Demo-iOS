//
//  EMGroupOccupantsViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 06/01/2017.
//  Copyright © 2017 XieYajie. All rights reserved.
//

#import "EMGroupOccupantsViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"

@interface EMGroupOccupantsViewController ()

@property (nonatomic, strong) EMGroup *group;
@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, strong) NSMutableArray *ownerAndAdmins;

@end

@implementation EMGroupOccupantsViewController

- (instancetype)initWithGroup:(EMGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.occupantList", @"Occupant List");
    
    _ownerAndAdmins = [[NSMutableArray alloc] init];
    [_ownerAndAdmins addObjectsFromArray:@[@"001", @"002"]];
    [self.dataArray addObjectsFromArray:@[@"003", @"004"]];
    
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
//        return [self.ownerAndAdmins count];
        return 2;
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
            cell.rightLabel.text = @"admin";
        }
    } else {
        cell.showAccessoryViewInDelete = YES;
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
    
//    if (self.group.permissionType == EMGroupPermissionTypeOwner || self.group.permissionType == EMGroupPermissionTypeAdmin) {
//        return YES;
//    }
    
    return YES;
}

- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.remove", @"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:0];
    }];
    deleteAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *blackAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.black", @"ToBlack") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:1];
    }];
    blackAction.backgroundColor = [UIColor colorWithRed: 50 / 255.0 green: 63 / 255.0 blue: 72 / 255.0 alpha:1.0];
    
    UITableViewRowAction *muteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"button.mute", @"Mute") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editActionsForRowAtIndexPath:indexPath actionIndex:2];
    }];
    muteAction.backgroundColor = [UIColor colorWithRed: 116 / 255.0 green: 134 / 255.0 blue: 147 / 255.0 alpha:1.0];
    
    return @[deleteAction, blackAction, muteAction];
}

#pragma mark - Action

- (void)editActionsForRowAtIndexPath:(NSIndexPath *)indexPath actionIndex:(NSInteger)buttonIndex
{
//    NSString *userName = [self.dataArray objectAtIndex:indexPath.row];
//    [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
//    
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        EMError *error = nil;
//        if (buttonIndex == 0) { //Remove
//            weakSelf.group = [[EMClient sharedClient].groupManager removeOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 1) { //Blacklist
//            weakSelf.group = [[EMClient sharedClient].groupManager blockOccupants:@[userName] fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 2) {  //Mute
//            weakSelf.group = [[EMClient sharedClient].groupManager muteMembers:@[userName] muteMilliseconds:-1 fromGroup:weakSelf.group.groupId error:&error];
//        } else if (buttonIndex == 3) {  //To Admin
//            weakSelf.group = [[EMClient sharedClient].groupManager addAdmin:userName toGroup:weakSelf.group.groupId error:&error];
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [weakSelf hideHud];
//            if (!error) {
//                if (buttonIndex != 2) {
//                    [weakSelf.dataArray removeObject:userName];
//                    [weakSelf.tableView reloadData];
//                } else {
//                    [weakSelf showHint:NSLocalizedString(@"group.mute.success", @"Mute success")];
//                }
//                
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateGroupDetail" object:weakSelf.group];
//            }
//            else {
//                [weakSelf showHint:error.errorDescription];
//            }
//        });
//    });
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.cursor = @"";
    [self fetchGroupInfo];
//    [self fetchMembersWithPage:self.page isHeader:YES];
    [self tableViewDidFinishTriggerHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    [self fetchMembersWithPage:self.page isHeader:NO];
}

- (void)fetchGroupInfo
{
    //    __weak typeof(self) weakSelf = self;
    //    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
    //        EMError *error = nil;
    //        EMGroup *group = [[EMClient sharedClient].groupManager getGroupSpecificationFromServerWithId:weakSelf.groupId error:&error];
    //        dispatch_async(dispatch_get_main_queue(), ^{
    //            [weakSelf hideHud];
    //        });
    //
    //        if (!error) {
    //            weakSelf.group = group;
    //            EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:group.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
    //            if ([group.groupId isEqualToString:conversation.conversationId]) {
    //                NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
    //                [ext setObject:group.subject forKey:@"subject"];
    //                [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
    //                conversation.ext = ext;
    //            }
    //
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [weakSelf fetchGroupMembers];
    //            });
    //        }
    //        else{
    //            dispatch_async(dispatch_get_main_queue(), ^{
    //                [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
    //            });
    //        }
    //    });
}

- (void)fetchMembersWithPage:(NSInteger)aPage
                    isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
//    [[EMClient sharedClient].groupManager getGroupMemberListFromServerWithId:self.group.groupId cursor:self.cursor pageSize:pageSize completion:^(EMCursorResult *aResult, EMError *aError) {
//        weakSelf.cursor = aResult.cursor;
//        [weakSelf hideHud];
//        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
//        if (!aError) {
//            if (aIsHeader) {
//                [weakSelf.dataArray removeAllObjects];
//            }
//            
//            [weakSelf.dataArray addObjectsFromArray:aResult.list];
//            [weakSelf.tableView reloadData];
//        } else {
//            [weakSelf showHint:NSLocalizedString(@"group.member.fetchFail", @"Failed to get the group details, please try again later")];
//        }
//        
//        if ([aResult.list count] == 0) {
//            weakSelf.showRefreshFooter = NO;
//        } else {
//            weakSelf.showRefreshFooter = YES;
//        }
//    }];
}

@end
