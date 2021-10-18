/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatsViewController.h"

#import "UIViewController+DismissKeyboard.h"
#import "AgoraRealtimeSearchUtil.h"
#import "AgoraChatViewController.h"
#import "AgoraConversationModel.h"
#import "AgoraNotificationNames.h"
#import "AgoraChatsCell.h"


NSString *CellIdentifier = @"AgoraChatsCellIdentifier";

@interface AgoraChatsViewController () <AgoraChatManagerDelegate, AgoraChatGroupManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>
{
    BOOL _isSearchState;
}

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *searchSource;
@property (strong, nonatomic) UIView *networkStateView;
@property (assign, nonatomic) BOOL hasLaunched;

@end

@implementation AgoraChatsViewController
- (instancetype)init {
    self  = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConversationNotify) name:KAgora_UPDATE_CONVERSATIONS object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endChatWithConversationId) name:KAgora_END_CHAT object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight;
    _isSearchState = NO;
    
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)queryHasLaunch {
    
    NSUserDefaults *userDefault = NSUserDefaults.standardUserDefaults;
    BOOL hasLaunched = [userDefault boolForKey:[AgoraChatClient.sharedClient currentUsername]];
    if(!hasLaunched) {
        self.hasLaunched = hasLaunched;
        [userDefault setBool:YES forKey:[AgoraChatClient.sharedClient currentUsername]];
        [userDefault synchronize];
    }else {
        self.hasLaunched = hasLaunched;
    }
    
    
    NSLog(@"\n%s \n[AgoraChatClient.sharedClient currentUsername]:%@ \nhasLaunched:%@",__func__,[AgoraChatClient.sharedClient currentUsername],@(self.hasLaunched));

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self registerNotifications];
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unregisterNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark private method
- (void)registerNotifications{
    [self unregisterNotifications];
    [[AgoraChatClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
}

- (void)unregisterNotifications{
    [[AgoraChatClient sharedClient].chatManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
}


- (void)updateUIAfterLeaveGroupWithConversationId:(NSString *)conversationId {
    [[AgoraChatClient sharedClient].chatManager deleteConversation:conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, AgoraChatError *aError) {
        if (aError == nil) {
            [self tableViewDidTriggerHeaderRefresh];
        }
    }];
}


#pragma mark NSNotification
- (void)updateConversationNotify {
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return [self.searchSource count];
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        AgoraChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = (AgoraChatsCell*)[[[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:nil options:nil] firstObject];
        }
        AgoraConversationModel *model = [self.searchSource objectAtIndex:indexPath.row];
        [(AgoraChatsCell*)cell setConversationModel:model];
        
        return cell;
    }
    
    AgoraChatsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[AgoraChatsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    AgoraConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
    [(AgoraChatsCell*)cell setConversationModel:model];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AgoraConversationModel *model = [self.dataSource objectAtIndex:indexPath.row];
        WEAK_SELF
        [[AgoraChatClient sharedClient].chatManager deleteConversation:model.conversation.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, AgoraChatError *aError) {
            [weakSelf.dataSource removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AgoraConversationModel *model = nil;
    if (_isSearchState) {
        model = [self.searchSource objectAtIndex:indexPath.row];
    } else {
        model = [self.dataSource objectAtIndex:indexPath.row];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];

    AgoraChatViewController *chatViewController = [[AgoraChatViewController alloc] initWithConversationId:model.conversation.conversationId conversationType:model.conversation.type];
    chatViewController.leaveGroupBlock = ^{
        [self updateUIAfterLeaveGroupWithConversationId:model.conversation.conversationId];
    };
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

#pragma marl - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    self.tableView.userInteractionEnabled = NO;
    return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.tableView.userInteractionEnabled = YES;
    if (searchBar.text.length == 0) {
        [self.searchSource removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    WEAK_SELF
    [[AgoraRealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchSource removeAllObjects];
                [weakSelf.searchSource addObjectsFromArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    self.tableView.userInteractionEnabled = YES;
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[AgoraRealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
    _isSearchState = NO;
    [self.tableView reloadData];
}


#pragma mark - action

- (void)tableViewDidTriggerHeaderRefresh
{
    [self queryHasLaunch];
    
    if (self.hasLaunched) {
        [self fetchDataFromLocal];
    }else {
        [self fetchDataFromServer];
    }
}

- (void)fetchDataFromLocal {
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *conversations = [[AgoraChatClient sharedClient].chatManager getAllConversations];
        NSArray* sorted = [weakSelf _sortConversationList:conversations];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *cArray = NSMutableArray.new;
            NSLog(@"\n%s  =====================currentUsername:%@",__func__,AgoraChatClient.sharedClient.currentUsername);

            for (AgoraChatConversation *conversation in sorted) {
                AgoraConversationModel *model = [[AgoraConversationModel alloc] initWithConversation:conversation];
                NSLog(@"%s conversation.conversationId:%@",__func__,conversation.conversationId);

                [cArray addObject:model];
            }
            self.dataSource = cArray;
            [self tableViewDidFinishTriggerHeader:YES];
            [weakSelf.tableView reloadData];
        });
    });
}


- (void)fetchDataFromServer {
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[AgoraChatClient sharedClient].chatManager getConversationsFromServer:^(NSArray *aCoversations, AgoraChatError *aError) {
            NSArray* sorted = [weakSelf _sortConversationList:aCoversations];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *cArray = NSMutableArray.new;

                for (AgoraChatConversation *conversation in sorted) {
                    AgoraConversationModel *model = [[AgoraConversationModel alloc] initWithConversation:conversation];

                    [cArray addObject:model];
                }
                self.dataSource = cArray;

                [self tableViewDidFinishTriggerHeader:YES];
                [weakSelf.tableView reloadData];
            });
        }];
    });
}


#pragma mark - AgoraChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)conversationListDidUpdate:(NSArray *)aConversationList
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray* sorted = [self _sortConversationList:aConversationList];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataSource removeAllObjects];
            for (AgoraChatConversation *conversation in sorted) {
                AgoraConversationModel *model = [[AgoraConversationModel alloc] initWithConversation:conversation];
                [weakSelf.dataSource addObject:model];
            }
            [self tableViewDidFinishTriggerHeader:YES];
            [weakSelf.tableView reloadData];
        });
    });
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    NSLog(@"%s aMessages:%@",__func__,aMessages);
    [self tableViewDidTriggerHeaderRefresh];
}

#pragma mark - AgoraChatGroupManagerDelegate

- (void)groupListDidUpdate:(NSArray *)aGroupList
{
    [self tableViewDidTriggerHeaderRefresh];
}


- (void)didLeaveGroup:(AgoraChatGroup *)aGroup reason:(AgoraChatGroupLeaveReason)aReason {
    if (aReason == AgoraChatGroupLeaveReasonDestroyed) {
        NSArray *conversations = [[AgoraChatClient sharedClient].chatManager getAllConversations];
        for (AgoraChatConversation *con in conversations) {
            if ([con.conversationId isEqualToString:aGroup.groupId]) {
                [[AgoraChatClient sharedClient].chatManager deleteConversation:con.conversationId isDeleteMessages:YES completion:^(NSString *aConversationId, AgoraChatError *aError) {
                    [self tableViewDidTriggerHeaderRefresh];
                }];
            }
        }
    }
}

#pragma mark - public 

- (void)setupNavigationItem:(UINavigationItem *)navigationItem
{
    navigationItem.titleView = self.searchBar;
}

- (void)networkChanged:(AgoraChatConnectionState)connectionState
{
    if (connectionState == AgoraChatConnectionDisconnected) {
        self.tableView.tableHeaderView = self.networkStateView;
    } else {
        self.tableView.tableHeaderView = nil;
    }
}

#pragma mark - private

- (NSArray*)_sortConversationList:(NSArray *)aConversationList
{
    NSArray* sorted = [aConversationList sortedArrayUsingComparator:
                       ^(AgoraChatConversation *obj1, AgoraChatConversation * obj2){
                           AgoraChatMessage *message1 = [obj1 latestMessage];
                           AgoraChatMessage *message2 = [obj2 latestMessage];
                           if(message1.timestamp > message2.timestamp) {
                               return(NSComparisonResult)NSOrderedAscending;
                           }else {
                               return(NSComparisonResult)NSOrderedDescending;
                           }
                       }];
    return  sorted;
}

#pragma mark - getter and setter
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];

        _networkStateView.backgroundColor = KermitGreenTwoColor;
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"Icon_error_white"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    return _networkStateView;
}

- (UISearchBar*)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 30)];
        _searchBar.placeholder = NSLocalizedString(@"common.search", @"Search");
        _searchBar.delegate = self;
        _searchBar.showsCancelButton = NO;
        _searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:_searchBar.bounds.size];
        [_searchBar setSearchFieldBackgroundPositionAdjustment:UIOffsetMake(0, 0)];
        [_searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:PaleGrayColor size:_searchBar.bounds.size] forState:UIControlStateNormal];
        _searchBar.tintColor = AlmostBlackColor;
    }
    return _searchBar;
}

- (NSMutableArray*)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (NSMutableArray*)searchSource
{
    if (_searchSource == nil) {
        _searchSource = [NSMutableArray array];
    }
    return _searchSource;
}



@end
