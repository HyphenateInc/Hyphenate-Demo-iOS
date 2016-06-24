/************************************************************
 *  * Hyphenate  
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "ChatGroupDetailViewController.h"

#import "ContactSelectionViewController.h"
#import "EMGroup.h"
#import "ContactView.h"
#import "GroupBansViewController.h"
#import "GroupSubjectChangingViewController.h"
#import "SearchMessageViewController.h"

#pragma mark - ChatGroupDetailViewController

#define kColOfRow 5
#define kContactSize 60

@interface ChatGroupDetailViewController ()<EMGroupManagerDelegate, EMChooseViewDelegate, UIActionSheetDelegate>

- (void)unregisterNotifications;
- (void)registerNotifications;

@property (nonatomic) GroupOccupantType occupantType;
@property (strong, nonatomic) EMGroup *chatGroup;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIView *footerView;
@property (strong, nonatomic) UIButton *clearButton;
@property (strong, nonatomic) UIButton *exitButton;
@property (strong, nonatomic) UIButton *dissolveButton;
@property (strong, nonatomic) UIButton *configureButton;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPress;
@property (strong, nonatomic) ContactView *selectedContact;

@property (nonatomic, strong) UISwitch *pushSwitch;
@property (nonatomic, strong) UISwitch *blockSwitch;

@property (nonatomic, assign) BOOL isOwner;

@end

@implementation ChatGroupDetailViewController

- (void)registerNotifications {
    [self unregisterNotifications];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications {
    [[EMClient sharedClient].groupManager removeDelegate:self];
}

- (void)dealloc {
    [self unregisterNotifications];
}

- (instancetype)initWithGroup:(EMGroup *)chatGroup
{
    self = [super init];
    
    if (self) {

        self.chatGroup = chatGroup;
        _dataSource = [NSMutableArray array];
        _occupantType = GroupOccupantTypeMember;
        [self registerNotifications];
        
        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
        self.isOwner = [self.chatGroup.owner isEqualToString:loginUsername];
    }
    return self;
}

- (instancetype)initWithGroupId:(NSString *)chatGroupId
{
    EMGroup *chatGroup = nil;
    NSArray *groupArray = [[EMClient sharedClient].groupManager getAllGroups];
    for (EMGroup *group in groupArray) {
        if ([group.groupId isEqualToString:chatGroupId]) {
            chatGroup = group;
            break;
        }
    }
    
    if (chatGroup == nil) {
        chatGroup = [EMGroup groupWithId:chatGroupId];
    }
    
    self = [self initWithGroup:chatGroup];
    if (self) {
        //
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.title = @"Group Settings";
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.tableView.tableFooterView = self.footerView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupBansChanged) name:@"GroupBansChanged" object:nil];
    
    [self fetchGroupInfo];
    
    self.pushSwitch = [[UISwitch alloc] init];
    [self.pushSwitch addTarget:self action:@selector(pushSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.pushSwitch setOn:self.chatGroup.isPushNotificationEnabled animated:YES];
    
    self.blockSwitch = [[UISwitch alloc] init];
    [self.blockSwitch addTarget:self action:@selector(blockSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.blockSwitch setOn:self.chatGroup.isBlocked animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


#pragma mark - getter

- (UIScrollView *)scrollView
{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, self.view.frame.size.width - 20, kContactSize)];
        _scrollView.tag = 0;
        
        self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kContactSize - 10, kContactSize - 10)];
        [self.addButton setImage:[UIImage imageNamed:@"addIcon"] forState:UIControlStateNormal];
        [self.addButton setImage:[UIImage imageNamed:@"addIcon"] forState:UIControlStateHighlighted];
        [self.addButton addTarget:self action:@selector(addContact:) forControlEvents:UIControlEventTouchUpInside];
        
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deleteContactBegin:)];
        _longPress.minimumPressDuration = 0.5;
    }
    
    return _scrollView;
}

- (UIButton *)clearButton
{
    if (_clearButton == nil) {
        _clearButton = [[UIButton alloc] init];
        [_clearButton setTitle:NSLocalizedString(@"group.removeAllMessages", @"Clear all messages") forState:UIControlStateNormal];
        [_clearButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_clearButton addTarget:self action:@selector(clearAction) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setBackgroundColor:[UIColor HIRedColor]];
        _clearButton.layer.cornerRadius = 6.0f;
        _clearButton.layer.masksToBounds = YES;
    }
    
    return _clearButton;
}

- (UIButton *)dissolveButton
{
    if (_dissolveButton == nil) {
        _dissolveButton = [[UIButton alloc] init];
        [_dissolveButton setTitle:NSLocalizedString(@"group.destroy", @"Dismiss the group") forState:UIControlStateNormal];
        [_dissolveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_dissolveButton addTarget:self action:@selector(dissolveAction) forControlEvents:UIControlEventTouchUpInside];
        [_dissolveButton setBackgroundColor: [UIColor HIRedColor]];
        _dissolveButton.layer.cornerRadius = 6.0f;
        _dissolveButton.layer.masksToBounds = YES;
    }
    
    return _dissolveButton;
}

- (UIButton *)exitButton
{
    if (_exitButton == nil) {
        _exitButton = [[UIButton alloc] init];
        [_exitButton setTitle:NSLocalizedString(@"group.leave", @"Leave the group") forState:UIControlStateNormal];
        [_exitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [_exitButton setBackgroundColor:[UIColor HIRedColor]];
        _exitButton.layer.cornerRadius = 6.0f;
        _exitButton.layer.masksToBounds = YES;
    }
    
    return _exitButton;
}

- (UIView *)footerView
{
    if (_footerView == nil) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 160)];
        _footerView.backgroundColor = [UIColor clearColor];
        
        self.clearButton.frame = CGRectMake(20, 40, _footerView.frame.size.width - 40, 35);
        [_footerView addSubview:self.clearButton];
        
        self.dissolveButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
        
        self.exitButton.frame = CGRectMake(20, CGRectGetMaxY(self.clearButton.frame) + 30, _footerView.frame.size.width - 40, 35);
    }
    
    return _footerView;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupDetailCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.contentView addSubview:self.scrollView];
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"group.id", @"group ID");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = self.chatGroup.groupId;
    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = NSLocalizedString(@"group.occupantCount", @"Members Count");
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%i / %i", (int)[self.chatGroup.occupants count], (int)self.chatGroup.setting.maxUsersCount];
    }
    else if (indexPath.row == 3)
    {
        // Only none group owner can block messages
//        if(!self.isOwner) {
        self.blockSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.blockSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.blockSwitch.frame.size.height) / 2, self.blockSwitch.frame.size.width, self.blockSwitch.frame.size.height);
        
        cell.textLabel.text = NSLocalizedString(@"group.setting.blockMessage", @"Block Messages");
        [cell.contentView addSubview:self.blockSwitch];
        [cell.contentView bringSubviewToFront:self.blockSwitch];
//        }
    }
    else if (indexPath.row == 4)
    {
        cell.textLabel.text = NSLocalizedString(@"title.groupSubjectChanging", @"Change Group Name");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 5)
    {
        cell.textLabel.text = NSLocalizedString(@"title.groupSearchMessage", @"Search Message from History");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 6)
    {
        cell.textLabel.text = NSLocalizedString(@"title.groupBlackList", @"Group's BlackList");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else if (indexPath.row == 7)
    {
        // Only none group owner can turn of push notification service
//        if (!self.isOwner) {
            self.pushSwitch.frame = CGRectMake(self.tableView.frame.size.width - (self.pushSwitch.frame.size.width + 10), (cell.contentView.frame.size.height - self.pushSwitch.frame.size.height) / 2, self.pushSwitch.frame.size.width, self.pushSwitch.frame.size.height);
            
            if (self.pushSwitch.isOn) {
                cell.textLabel.text = NSLocalizedString(@"group.setting.receiveAndPrompt", @"Push Service ON");
            }
            else {
                cell.textLabel.text = NSLocalizedString(@"group.setting.receiveAndUnprompt", @"Push Service OFF");
            }
            
            [cell.contentView addSubview:self.pushSwitch];
            [cell.contentView bringSubviewToFront:self.pushSwitch];
//        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = (int)indexPath.row;
    if (row == 0) {
        return self.scrollView.frame.size.height + 40;
    }
    else {
        return 50;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 4) {
        
        if (self.isOwner) {
            
            GroupSubjectChangingViewController *changingController = [[GroupSubjectChangingViewController alloc] initWithGroup:self.chatGroup];
            [self.navigationController pushViewController:changingController animated:YES];
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Change Group Name Setting"
                                                                           message:@"Only group owner can change group name"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else if (indexPath.row == 5) {
        SearchMessageViewController *searchController = [[SearchMessageViewController alloc] initWithConversationId:self.chatGroup.groupId conversationType:EMConversationTypeGroupChat];
        [self.navigationController pushViewController:searchController animated:YES];
    }
    else if (indexPath.row == 6) {
        GroupBansViewController *bansController = [[GroupBansViewController alloc] initWithGroup:self.chatGroup];
        [self.navigationController pushViewController:bansController animated:YES];
    }
}

#pragma mark - EMChooseViewDelegate

- (BOOL)viewController:(EMChooseViewController *)viewController didFinishSelectedSources:(NSArray *)selectedSources
{
    NSInteger maxUsersCount = self.chatGroup.setting.maxUsersCount;
    if (([selectedSources count] + self.chatGroup.occupantsCount) > maxUsersCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.maxUserCount", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
        
        return NO;
    }
    
    [self showHudInView:self.view hint:NSLocalizedString(@"group.addingOccupant", @"add a group member...")];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *source = [NSMutableArray array];
        for (NSString *username in selectedSources) {
            [source addObject:username];
        }
        
        NSString *username = [[EMClient sharedClient] currentUsername];
        NSString *messageStr = [NSString stringWithFormat:NSLocalizedString(@"group.somebodyInvite", @"%@ invites you to join group \'%@\'"), username, weakSelf.chatGroup.subject];
        [[EMClient sharedClient].groupManager asyncAddOccupants:selectedSources toGroup:self.chatGroup.groupId welcomeMessage:messageStr success:^(EMGroup *aGroup) {
            [weakSelf hideHud];
            [weakSelf reloadDataSource];
        } failure:^(EMError *aError) {
            [weakSelf hideHud];
            [weakSelf showHint:aError.errorDescription];
        }];
    });
    
    return YES;
}

- (void)groupBansChanged
{
    [self.dataSource removeAllObjects];
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    [self refreshScrollView];
}

#pragma mark - EMGroupManagerDelegate

- (void)didReceiveAcceptedGroupInvitation:(EMGroup *)aGroup
                                  invitee:(NSString *)aInvitee
{
    if ([aGroup.groupId isEqualToString:self.chatGroup.groupId]) {
        [self fetchGroupInfo];
    }
}

#pragma mark - data

- (void)fetchGroupInfo
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Load data...")];
    [[EMClient sharedClient].groupManager asyncFetchGroupInfo:weakSelf.chatGroup.groupId includeMembersList:YES success:^(EMGroup *aGroup) {
        [weakSelf hideHud];
        weakSelf.chatGroup = aGroup;
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:aGroup.groupId type:EMConversationTypeGroupChat createIfNotExist:YES];
        if ([aGroup.groupId isEqualToString:conversation.conversationId]) {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
            [ext setObject:aGroup.subject forKey:@"subject"];
            [ext setObject:[NSNumber numberWithBool:aGroup.isPublic] forKey:@"isPublic"];
            conversation.ext = ext;
        }
        [weakSelf reloadDataSource];
    } failure:^(EMError *aError) {
        [weakSelf hideHud];
        [weakSelf showHint:NSLocalizedString(@"group.fetchInfoFail", @"failed to get the group details, please try again later")];
    }];
}

- (void)reloadDataSource
{
    [self.dataSource removeAllObjects];
    
    self.occupantType = GroupOccupantTypeMember;
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    if ([self.chatGroup.owner isEqualToString:loginUsername]) {
        self.occupantType = GroupOccupantTypeOwner;
    }
    
    if (self.occupantType != GroupOccupantTypeOwner) {
        for (NSString *str in self.chatGroup.members) {
            if ([str isEqualToString:loginUsername]) {
                self.occupantType = GroupOccupantTypeMember;
                break;
            }
        }
    }
    
    [self.dataSource addObjectsFromArray:self.chatGroup.occupants];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshScrollView];
        [self refreshFooterView];
        [self hideHud];
    });
}

- (void)refreshScrollView
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.scrollView removeGestureRecognizer:_longPress];
    [self.addButton removeFromSuperview];
    
    BOOL showAddButton = NO;
    if (self.occupantType == GroupOccupantTypeOwner) {
        [self.scrollView addGestureRecognizer:_longPress];
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    else if (self.chatGroup.setting.style == EMGroupStylePrivateMemberCanInvite && self.occupantType == GroupOccupantTypeMember) {
        [self.scrollView addSubview:self.addButton];
        showAddButton = YES;
    }
    
    int tmp = ([self.dataSource count] + 1) % kColOfRow;
    int row = (int)([self.dataSource count] + 1) / kColOfRow;
    row += tmp == 0 ? 0 : 1;
    self.scrollView.tag = row;
    self.scrollView.frame = CGRectMake(10, 20, self.tableView.frame.size.width - 20, row * kContactSize);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, row * kContactSize);
    
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    
    int i = 0;
    int j = 0;
    BOOL isEditing = self.addButton.hidden ? YES : NO;
    BOOL isEnd = NO;
    for (i = 0; i < row; i++) {
        for (j = 0; j < kColOfRow; j++) {
            NSInteger index = i * kColOfRow + j;
            if (index < [self.dataSource count]) {
                NSString *username = [self.dataSource objectAtIndex:index];
                ContactView *contactView = [[ContactView alloc] initWithFrame:CGRectMake(j * kContactSize, i * kContactSize, kContactSize, kContactSize)];
                contactView.index = i * kColOfRow + j;
                contactView.image = [UIImage imageNamed:@"chatListCellHead.png"];
                contactView.remark = username;
                if (![username isEqualToString:loginUsername]) {
                    contactView.editing = isEditing;
                }
                
                __weak typeof(self) weakSelf = self;
                [contactView setDeleteContact:^(NSInteger index) {
                    [weakSelf showHudInView:weakSelf.view hint:NSLocalizedString(@"group.removingOccupant", @"deleting member...")];
                    NSArray *occupants = [NSArray arrayWithObject:[weakSelf.dataSource objectAtIndex:index]];
                    [[EMClient sharedClient].groupManager asyncRemoveOccupants:occupants fromGroup:weakSelf.chatGroup.groupId success:^(EMGroup *aGroup) {
                        [weakSelf hideHud];
                        weakSelf.chatGroup = aGroup;
                        [weakSelf.dataSource removeObjectAtIndex:index];
                        [weakSelf refreshScrollView];
                    } failure:^(EMError *aError) {
                        [weakSelf hideHud];
                        [weakSelf showHint:aError.errorDescription];
                    }];
                }];
                
                [self.scrollView addSubview:contactView];
            }
            else{
                if(showAddButton && index == self.dataSource.count)
                {
                    self.addButton.frame = CGRectMake(j * kContactSize + 5, i * kContactSize + 10, kContactSize - 10, kContactSize - 10);
                }
                
                isEnd = YES;
                break;
            }
        }
        
        if (isEnd) {
            break;
        }
    }
    
    [self.tableView reloadData];
}

- (void)refreshFooterView
{
    if (self.occupantType == GroupOccupantTypeOwner) {
        [_exitButton removeFromSuperview];
        [_footerView addSubview:self.dissolveButton];
    }
    else{
        [_dissolveButton removeFromSuperview];
        [_footerView addSubview:self.exitButton];
    }
}

#pragma mark - action

- (void)tapView:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded)
    {
        if (self.addButton.hidden) {
            [self setScrollViewEditing:NO];
        }
    }
}

- (void)deleteContactBegin:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
        for (ContactView *contactView in self.scrollView.subviews)
        {
            CGPoint locaton = [longPress locationInView:contactView];
            if (CGRectContainsPoint(contactView.bounds, locaton))
            {
                if ([contactView isKindOfClass:[ContactView class]]) {
                    if ([contactView.remark isEqualToString:loginUsername]) {
                        return;
                    }
                    _selectedContact = contactView;
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"delete", @"deleting member..."), NSLocalizedString(@"friend.block", @""), nil];
                    [sheet showInView:self.view];
                }
            }
        }
    }
}

- (void)setScrollViewEditing:(BOOL)isEditing
{
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    
    for (ContactView *contactView in self.scrollView.subviews)
    {
        if ([contactView isKindOfClass:[ContactView class]]) {
            if ([contactView.remark isEqualToString:loginUsername]) {
                continue;
            }
            
            [contactView setEditing:isEditing];
        }
    }
    
    self.addButton.hidden = isEditing;
}

- (void)addContact:(id)sender
{
    ContactSelectionViewController *selectionController = [[ContactSelectionViewController alloc] initWithBlockSelectedUsernames:self.chatGroup.occupants];
    selectionController.delegate = self;
    [self.navigationController pushViewController:selectionController animated:YES];
}

- (void)clearAction
{
    __weak typeof(self) weakSelf = self;
    
    [EMAlertView showAlertWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                            message:NSLocalizedString(@"confirmDeleteMessage", @"Messages will not be able to be retrived")
                    completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
                        if (buttonIndex == 1) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"RemoveAllMessages" object:weakSelf.chatGroup.groupId];
                        }
                    }
                  cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                  otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
    
}

- (void)dissolveAction
{
    __weak typeof(self) weakSelf = self;
    
    [self showHudInView:self.view hint:NSLocalizedString(@"group.destroy", @"dissolution of the group")];
  
    [[EMClient sharedClient].groupManager asyncDestroyGroup:self.chatGroup.groupId success:^(EMGroup *aGroup) {
        [weakSelf hideHud];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
    } failure:^(EMError *aError) {
        [weakSelf hideHud];
        [weakSelf showHint:NSLocalizedString(@"group.destroyFail", @"dissolution of group failure")];
    }];
}

- (void)exitAction
{
    __weak typeof(self) weakSelf = self;
    
    [self showHudInView:self.view hint:NSLocalizedString(@"group.leave", @"Leave the group")];
    
    [[EMClient sharedClient].groupManager asyncLeaveGroup:self.chatGroup.groupId success:^(EMGroup *aGroup) {
        [weakSelf hideHud];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ExitGroup" object:nil];
    } failure:^(EMError *aError) {
        [weakSelf hideHud];
        [weakSelf showHint:NSLocalizedString(@"group.leaveFail", @"exit the group failure")];
    }];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger index = _selectedContact.index;
    
    if (buttonIndex == 0)
    {
        //delete
        _selectedContact.deleteContact(index);
    }
    else if (buttonIndex == 1)
    {
        //add to black list
        [self showHudInView:self.view hint:NSLocalizedString(@"group.ban.adding", @"Adding to black list..")];
        NSArray *occupants = [NSArray arrayWithObject:[self.dataSource objectAtIndex:_selectedContact.index]];
        __weak ChatGroupDetailViewController *weakSelf = self;
        [[EMClient sharedClient].groupManager asyncBlockOccupants:occupants fromGroup:self.chatGroup.groupId success:^(EMGroup *aGroup) {
            [weakSelf hideHud];
            weakSelf.chatGroup = aGroup;
            [weakSelf.dataSource removeObjectAtIndex:index];
            [weakSelf refreshScrollView];
        } failure:^(EMError *aError) {
            [weakSelf hideHud];
            [weakSelf showHint:aError.errorDescription];
        }];
    }
    _selectedContact = nil;
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _selectedContact = nil;
}


#pragma mark - action

- (void)pushSwitchChanged:(id)sender
{
    // Only None Group Owner can block messages
    if (self.isOwner) {
        self.pushSwitch.on = YES;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Push Service Setting"
                                                                       message:@"Only none group owner can turn off push notification"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    [self isIgnoreGroup:![self.pushSwitch isOn]];
    [self.tableView reloadData];
}

- (void)blockSwitchChanged:(id)sender
{
    // Only None Group Owner can block messages
    if (self.isOwner) {
        self.blockSwitch.on = NO;
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Block Messages Setting"
                                                                       message:@"Only none group owner can block messages"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        return;
    }
    
    if (self.blockSwitch.isOn != self.chatGroup.isBlocked) {
        
        __weak typeof(self) weakSelf = self;
        
        [self showHudInView:self.view hint:NSLocalizedString(@"group.setting.save", @"Saving Properties")];
        
        if (self.blockSwitch.isOn) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[EMClient sharedClient].groupManager asyncBlockGroup:self.chatGroup.groupId success:^(EMGroup *aGroup) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf hideHud];
                        
                        [weakSelf showHint:NSLocalizedString(@"group.setting.success", @"Settings Saved")];
                    });
                } failure:^(EMError *aError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf hideHud];
                        
                        if (aError) {
                            [weakSelf showHint:NSLocalizedString(@"group.setting.fail", @"Setting Failed")];
                        }
                    });
                }];
            });
        }
        else {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[EMClient sharedClient].groupManager asyncUnblockGroup:self.chatGroup.groupId success:^(EMGroup *aGroup) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf hideHud];
                        
                        [weakSelf showHint:NSLocalizedString(@"group.setting.success", @"Settings Saved")];
                    });
                } failure:^(EMError *aError) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf hideHud];
                        
                        if (aError) {
                            [weakSelf showHint:NSLocalizedString(@"group.setting.fail", @"Setting Failed")];
                        }
                    });
                }];
            });
        }
    }
    
    if (self.pushSwitch.isOn != self.chatGroup.isPushNotificationEnabled) {
        [self isIgnoreGroup:!self.pushSwitch.isOn];
    }
}

#pragma mark - private

- (void)isIgnoreGroup:(BOOL)isIgnore
{
    [self showHudInView:self.view hint:NSLocalizedString(@"group.setting.save", @"set properties")];
    
    __weak ChatGroupDetailViewController *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [[EMClient sharedClient].groupManager asyncIgnoreGroupPush:weakSelf.chatGroup.groupId ignore:isIgnore success:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf hideHud];
                
                [weakSelf showHint:NSLocalizedString(@"group.setting.success", @"set success")];
            });
        } failure:^(EMError *aError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [weakSelf hideHud];
                
                if (aError) {
                    [weakSelf showHint:NSLocalizedString(@"group.setting.fail", @"set failure")];
                }
            });
        }];
    });
}

@end
