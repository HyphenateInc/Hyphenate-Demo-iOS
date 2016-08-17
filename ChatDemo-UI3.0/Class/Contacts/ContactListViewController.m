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

#import "ContactListViewController.h"

#import "ChatViewController.h"
#import "RobotListViewController.h"
#import "AddFriendViewController.h"
#import "FriendRequestViewController.h"
#import "EMSearchBar.h"
#import "EMSearchDisplayController.h"
#import "UserProfileManager.h"
#import "RealtimeSearchUtil.h"
#import "UserProfileManager.h"
#import "EMContactDetailedTableViewCell.h"

@implementation NSString (search)

- (NSString*)showName
{
    return [[UserProfileManager sharedInstance] getNickNameWithUsername:self];
}

@end

@interface ContactListViewController () <UISearchBarDelegate, UISearchDisplayDelegate,BaseTableCellDelegate,UIActionSheetDelegate,EaseUserCellDelegate>
{
    NSIndexPath *_currentLongPressIndex;
}

@property (strong, nonatomic) NSMutableArray *sectionTitles;
@property (strong, nonatomic) NSMutableArray *contactsSource;

@property (nonatomic) NSInteger requestCount;
@property (strong, nonatomic) EMSearchBar *searchBar;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation ContactListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.showRefreshHeader = YES;
    
    _contactsSource = [NSMutableArray array];
    _sectionTitles = [NSMutableArray array];
    
    [self searchController];
    self.searchBar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [self.view addSubview:self.searchBar];
    
    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height);
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor HIGrayLightColor];

    [[UserProfileManager sharedInstance] loadUserProfileInBackgroundOfUser:self.contactsSource saveToLoacal:YES completion:NULL];
    
    [[EMClient sharedClient].chatManager addDelegate:self];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUnreadMessageCount:) name:kNotification_unreadMessageCountUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadRequestCount) name:kNotification_didReceiveRequest object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadRequestCount];
#ifdef ENABLE_GOOGLE_ANALYTICS
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
#endif
}


#pragma mark - getter

- (NSArray *)rightItems
{
    if (_rightItems == nil) {
        UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [addButton setImage:[UIImage imageNamed:@"addContact.png"] forState:UIControlStateNormal];
        [addButton addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
        _rightItems = @[addItem];
    }
    
    return _rightItems;
}

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] init];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search Contacts");
        _searchBar.barTintColor = [UIColor HIGrayLightColor];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        __weak ContactListViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ContactListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            NSString *username = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
            cell.textLabel.text = username;
            cell.username = username;
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSString *username = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            
            NSString *loginUsername = [[EMClient sharedClient] currentUsername];
            
            if (loginUsername && loginUsername.length > 0) {
            
                if ([loginUsername isEqualToString:username]) {
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                                        message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself")
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                    
                    return;
                }
            }
            
            [weakSelf.searchController.searchBar endEditing:YES];
            ChatViewController *chatVC = [[ChatViewController alloc] initWithConversationID:username
                                                                           conversationType:EMConversationTypeChat];
            chatVC.title = [[UserProfileManager sharedInstance] getNickNameWithUsername:username];
            [weakSelf.navigationController pushViewController:chatVC animated:YES];
        }];
    }
    
    return _searchController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count] + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    
    return [[self.dataArray objectAtIndex:(section - 1)] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            
            NSString *CellIdentifier = @"addFriend";
            
            EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            cell.avatarView.image = [UIImage imageNamed:@"notificationIcon"];
            cell.titleLabel.text = @"Requests";
            cell.avatarView.badge = self.requestCount;
            
            return cell;
        }
        
        NSString *CellIdentifier = @"commonCell";
        EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        if (indexPath.row == 1) {
            cell.avatarView.image = [UIImage imageNamed:@"group"];
            cell.titleLabel.text = NSLocalizedString(@"title.group", @"Group");
        }
        else if (indexPath.row == 2) {
            cell.avatarView.image = [UIImage imageNamed:@"group"];
            cell.titleLabel.text = NSLocalizedString(@"title.robotlist",@"robot list");
        }
        return cell;
    }
    else
    {
        NSString *cellIdentifier = [EMContactDetailedTableViewCell cellIdentifier];
        EMContactDetailedTableViewCell *cell = (EMContactDetailedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];

        if (!cell) {
            [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([EMContactDetailedTableViewCell class]) bundle:nil] forCellReuseIdentifier:cellIdentifier];
            cell = (EMContactDetailedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        }
        cell.userModel = nil;
        cell.profileInfoContainer.layer.cornerRadius = 10;
        cell.profileInfoContainer.layer.masksToBounds = YES;
        
        NSArray *userSection = [self.dataArray objectAtIndex:(indexPath.section - 1)];
        
        EaseUserModel *userModel = [userSection objectAtIndex:indexPath.row];
        UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:userModel.username];
        if (profileEntity) {
            userModel.avatarURLPath = profileEntity.imageUrl;
            userModel.nickname = profileEntity.nickname ? profileEntity.nickname : profileEntity.username;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.userModel = userModel;
        
        return cell;
    }
}


#pragma mark - Table view delegate

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionTitles;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else {
        return 22;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UIView *contentView = [[UIView alloc] init];
    [contentView setBackgroundColor:[UIColor HIGrayLightColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    label.backgroundColor = [UIColor clearColor];
    [label setText:[self.sectionTitles objectAtIndex:(section - 1)]];
    [contentView addSubview:label];
    
    return contentView;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    if (section == 0) {
        if (row == 0) {
            [self.navigationController pushViewController:[FriendRequestViewController shareController] animated:YES];
        }
        else if (row == 1)
        {
            if (_groupController == nil) {
                _groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            }
            else{
                [_groupController reloadDataSource];
            }
            GroupListViewController *groupController = [[GroupListViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:groupController animated:YES];
        }
        else if (row == 2) {
            RobotListViewController *robot = [[RobotListViewController alloc] init];
            [self.navigationController pushViewController:robot animated:YES];
        }
    }
    else {
        
        EaseUserModel *userModel = [[self.dataArray objectAtIndex:section - 1] objectAtIndex:row];
        
        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
        
        if (loginUsername && loginUsername.length > 0) {
            
            if ([loginUsername isEqualToString:userModel.username]) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt")
                                                                    message:NSLocalizedString(@"friend.notChatSelf", @"can't talk to yourself")
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                                          otherButtonTitles:nil, nil];
                
                [alertView show];
                
                return;
            }
        }
        
        ChatViewController *chatController = [[ChatViewController alloc] initWithConversationID:userModel.username
                                                                               conversationType:EMConversationTypeChat];
        
        chatController.title = userModel.nickname.length > 0 ? userModel.nickname : userModel.username;
        
        [self.navigationController pushViewController:chatController animated:YES];
        
        // reset read count
        userModel.unreadMessageCount = 0;
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if (indexPath.section == 0) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *loginUsername = [[EMClient sharedClient] currentUsername];
        EaseUserModel *model = [[self.dataArray objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
        if ([model.username isEqualToString:loginUsername]) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"friend.notDeleteSelf", @"can't delete self") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
            
            return;
        }
        
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager deleteContact:model.username completion:^(NSString *aUsername, EMError *aError) {
            ContactListViewController *strongSelf = weakself;
            if (!aError) {
                [[EMClient sharedClient].chatManager deleteConversation:model.username isDeleteMessages:YES completion:nil];
                if (strongSelf) {
                    if ([strongSelf.dataArray count] >= indexPath.section && [strongSelf.dataArray[indexPath.section - 1] count] > indexPath.row) {
                        [strongSelf.dataArray[indexPath.section - 1] removeObjectAtIndex:indexPath.row];
                        bool deleteSection = NO;
                        if ([strongSelf.dataArray[indexPath.section - 1] count] == 0) {
                            [strongSelf.dataArray removeObjectAtIndex:indexPath.section - 1];
                            deleteSection = YES;
                        }
                        [strongSelf.contactsSource removeObject:model.username];
                        [strongSelf.tableView beginUpdates];
                        if (deleteSection) {
                            [strongSelf.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        else {
                            [strongSelf.tableView  deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                        }
                        [strongSelf.tableView endUpdates];
                    }
                }
            }
            else if (strongSelf) {
                [strongSelf showHint:[NSString stringWithFormat:NSLocalizedString(@"deleteFailed", @"Delete failed:%@"), aError.errorDescription]];
                [strongSelf.tableView reloadData];
            }
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.contactsSource searchText:(NSString *)searchText collationStringSelector:@selector(showName) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - BaseTableCellDelegate

- (void)cellImageViewLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row >= 1) {
        return;
    }
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    EaseUserModel *model = [[self.dataArray objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
    if ([model.username isEqualToString:loginUsername])
    {
        return;
    }
    
    _currentLongPressIndex = indexPath;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel")
                                               destructiveButtonTitle:NSLocalizedString(@"friend.block", @"")
                                                    otherButtonTitles:nil, nil];
    
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - action

- (void)addContactAction
{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    [self.navigationController pushViewController:addController animated:YES];
}

#pragma mark - private data

- (void)sortDataArray:(NSArray *)usernameList
{
    [self.dataArray removeAllObjects];
    [self.sectionTitles removeAllObjects];
    NSMutableArray *contactsSource = [NSMutableArray array];
    
    NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
    for (NSString *username in usernameList) {
        if (![blockList containsObject:username]) {
            [contactsSource addObject:username];
        }
    }
    
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    [self.sectionTitles addObjectsFromArray:[indexCollation sectionTitles]];
    
    NSInteger highSection = [self.sectionTitles count];
    NSMutableArray *sortedArray = [NSMutableArray arrayWithCapacity:highSection];
    for (int i = 0; i < highSection; i++) {
        NSMutableArray *sectionArray = [NSMutableArray arrayWithCapacity:1];
        [sortedArray addObject:sectionArray];
    }
    
    for (NSString *username in contactsSource) {
        EaseUserModel *model = [[EaseUserModel alloc] initWithUsername:username];
        if (model) {
            model.avatarImage = [UIImage imageNamed:@"user"];
            model.nickname = [[UserProfileManager sharedInstance] getNickNameWithUsername:username];
            
            NSString *firstLetter = [EaseChineseToPinyin pinyinFromChineseString:[[UserProfileManager sharedInstance] getNickNameWithUsername:username]];
            NSInteger section = [indexCollation sectionForObject:[firstLetter substringToIndex:1] collationStringSelector:@selector(uppercaseString)];
            
            NSMutableArray *array = [sortedArray objectAtIndex:section];
            [array addObject:model];
        }
    }
    
    for (int i = 0; i < [sortedArray count]; i++) {
        NSArray *array = [[sortedArray objectAtIndex:i] sortedArrayUsingComparator:^NSComparisonResult(EaseUserModel *obj1, EaseUserModel *obj2) {
            NSString *firstLetter1 = [EaseChineseToPinyin pinyinFromChineseString:obj1.username];
            firstLetter1 = [[firstLetter1 substringToIndex:1] uppercaseString];
            
            NSString *firstLetter2 = [EaseChineseToPinyin pinyinFromChineseString:obj2.username];
            firstLetter2 = [[firstLetter2 substringToIndex:1] uppercaseString];
            
            return [firstLetter1 caseInsensitiveCompare:firstLetter2];
        }];
        
        
        [sortedArray replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithArray:array]];
    }
    
    for (NSInteger i = [sortedArray count] - 1; i >= 0; i--) {
        NSArray *array = [sortedArray objectAtIndex:i];
        if ([array count] == 0) {
            [sortedArray removeObjectAtIndex:i];
            [self.sectionTitles removeObjectAtIndex:i];
        }
    }
    
    [self.dataArray addObjectsFromArray:sortedArray];
    [self.tableView reloadData];
}

#pragma mark - EaseUserCellDelegate

- (void)cellLongPressAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row >= 1) {
        return;
    }
    NSString *loginUsername = [[EMClient sharedClient] currentUsername];
    EaseUserModel *model = [[self.dataArray objectAtIndex:(indexPath.section - 1)] objectAtIndex:indexPath.row];
    if ([model.username isEqualToString:loginUsername])
    {
        return;
    }
    
    _currentLongPressIndex = indexPath;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") destructiveButtonTitle:NSLocalizedString(@"friend.block", @"") otherButtonTitles:nil, nil];
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && _currentLongPressIndex) {
        
        EaseUserModel *model = [[self.dataArray objectAtIndex:(_currentLongPressIndex.section - 1)] objectAtIndex:_currentLongPressIndex.row];
        
        [self showHudInView:self.view hint:NSLocalizedString(@"wait", @"Pleae wait...")];
        
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager addUserToBlackList:model.username completion:^(NSString *aUsername, EMError *aError) {
            [weakself hideHud];
            if (!aError) {
                [weakself reloadDataSource];
            }
            else {
                [weakself showHint:aError.errorDescription];
            }
        }];
    }
    _currentLongPressIndex = nil;
}

#pragma mark - data

- (void)updateUnreadMessageCount:(NSNotification *)notification
{
    
}

- (void)messagesDidReceive:(NSArray *)aMessages
{
    BOOL isUpdated = NO;
    
    for (EMMessage *message in aMessages) {
        EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:message.conversationId
                                                                                       type:(EMConversationType)message.chatType
                                                                           createIfNotExist:NO];
        
        
        for (NSArray *array in self.dataArray) {
            
            for (EaseUserModel *userModel in array) {
                
                NSString *nickname = userModel.nickname;
                NSString *username = userModel.username;
                
                if ([nickname isEqualToString:message.conversationId]) {
                    userModel.unreadMessageCount = conversation.unreadMessagesCount;
                    isUpdated = YES;
                    break;
                }
                else if ([username isEqualToString:message.conversationId]) {
                    userModel.unreadMessageCount = conversation.unreadMessagesCount;
                    isUpdated = YES;
                    break;
                }
            }
        }
    }
    
    if (isUpdated) {
        [self.tableView reloadData];
    }    
}


- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
        if (!aError) {
            NSArray *usernameList = aList;
            [[EMClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, EMError *aError) {
                ContactListViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    if (!aError) {
                        [strongSelf.contactsSource removeAllObjects];
                        [strongSelf.contactsSource addObjectsFromArray:usernameList];
                        
                        [strongSelf sortDataArray:self.contactsSource];
                        [strongSelf tableViewDidFinishTriggerHeader:YES reload:NO];
                    }
                    else {
                        [strongSelf showHint:[NSString stringWithFormat:@"Failed to get blacklist from server - %@", aError.errorDescription]];
                        [strongSelf reloadDataSource];
                        [strongSelf tableViewDidFinishTriggerHeader:YES reload:NO];
                    }
                }
            }];
        }
        else {
            ContactListViewController *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf showHint:aError.errorDescription];
                [strongSelf reloadDataSource];
                [strongSelf tableViewDidFinishTriggerHeader:YES reload:NO];
            }
        }
    }];
}

//- (void)updateMessageCount
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
//        
//        NSArray* sorted = [conversations sortedArrayUsingComparator:
//                           ^(EMConversation *obj1, EMConversation* obj2){
//                               EMMessage *message1 = [obj1 latestMessage];
//                               EMMessage *message2 = [obj2 latestMessage];
//                               if(message1.timestamp > message2.timestamp) {
//                                   return(NSComparisonResult)NSOrderedAscending;
//                               }else {
//                                   return(NSComparisonResult)NSOrderedDescending;
//                               }
//                           }];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            [self.dataArray removeAllObjects];
//            
//            for (EMConversation *converstion in sorted) {
//                
//                EaseConversationModel *model = nil;
//                
//                if (self.dataSource && [self.dataSource respondsToSelector:@selector(conversationListViewController:modelForConversation:)]) {
//                    model = [self.dataSource conversationListViewController:self
//                                                       modelForConversation:converstion];
//                }
//                else {
//                    model = [[EaseConversationModel alloc] initWithConversation:converstion];
//                }
//                
//                if (model) {
//                    [self.dataArray addObject:model];
//                }
//            }
//            
//            [self.tableView reloadData];
//            
//            [self tableViewDidFinishTriggerHeader:YES reload:NO];
//        });
//    });
//}

#pragma mark - public

- (void)reloadDataSource
{
    [self.dataArray removeAllObjects];
    [self.contactsSource removeAllObjects];
    
    self.contactsSource = [[[EMClient sharedClient].contactManager getContacts] mutableCopy];
    
    [self sortDataArray:self.contactsSource];
    
    [self.tableView reloadData];
}

- (void)reloadRequestCount
{
    self.requestCount = [[[FriendRequestViewController shareController] dataSource] count];
    
    [self.tableView reloadData];
}

- (void)reloadGroupView
{
    [self reloadRequestCount];
    
    if (_groupController) {
        [_groupController reloadDataSource];
    }
}

- (void)addFriendAction
{
    AddFriendViewController *addController = [[AddFriendViewController alloc] initWithStyle:UITableViewStylePlain];
    
    [self.navigationController pushViewController:addController animated:YES];
}

@end
