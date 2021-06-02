/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraContactsViewController.h"
#import "AgoraContactListSectionHeader.h"
#import "AgoraAddContactViewController.h"
#import "AgoraContactInfoViewController.h"
#import "AgoraChatroomsViewController.h"
#import "AgoraGroupTitleCell.h"
#import "AgoraContactCell.h"
#import "AgoraUserModel.h"
#import "AgoraApplyManager.h"
#import "AgoraGroupsViewController.h"
#import "AgoraApplyRequestCell.h"
#import "AgoraChatDemoHelper.h"
#import "AgoraRealtimeSearchUtils.h"
#import "NSArray+AgoraSortContacts.h"

#define KAgora_CONTACT_BASICSECTION_NUM  3

@interface AgoraContactsViewController ()<UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactRequests;
@property (nonatomic, strong) NSMutableArray *groupNotifications;

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation AgoraContactsViewController
{
    NSMutableArray *_sectionTitles;
    NSMutableArray *_searchSource;
    NSMutableArray *_searchResults;
    BOOL _isSearchState;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    self.tableView.sectionIndexColor = BrightBlueColor;
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self setupNavigationItem:self.navigationItem];
    [self reloadGroupNotifications];
    [self reloadContactRequests];
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)setupNavigationItem:(UINavigationItem *)navigationItem {

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"Icon_Add"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(addContactAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [navigationItem setRightBarButtonItems:@[rightBar]];
    
    navigationItem.titleView = self.searchBar;
}

- (void)tableViewDidTriggerHeaderRefresh {
    if (_isSearchState) {
        [self tableViewDidFinishTriggerHeader:YES];
        return;
    }
    
    WEAK_SELF
    [[AgoraChatClient sharedClient].contactManager getContactsFromServerWithCompletion:^(NSArray *aList, AgoraError *aError) {
        if (aError == nil) {
            [weakSelf tableViewDidFinishTriggerHeader:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
                [weakSelf updateContacts:aList];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [weakSelf.tableView reloadData];
                });
            });
        
        }
        else {
            [weakSelf tableViewDidFinishTriggerHeader:YES];
        }
    }];
}

- (void)loadContactsFromServer
{
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)reloadContacts {
    NSArray *bubbyList = [[AgoraChatClient sharedClient].contactManager getContacts];
    [self updateContacts:bubbyList];
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        [weakSelf.tableView reloadData];
        [weakSelf.refreshControl endRefreshing];
    });
}

- (void)reloadContactRequests {
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSArray *contactApplys = [[AgoraApplyManager defaultManager] contactApplys];
        weakSelf.contactRequests = [NSMutableArray arrayWithArray:contactApplys];
        [weakSelf.tableView reloadData];
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    });
}

- (void)reloadGroupNotifications {
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSArray *groupApplys = [[AgoraApplyManager defaultManager] groupApplys];
        weakSelf.groupNotifications = [NSMutableArray arrayWithArray:groupApplys];
        [weakSelf.tableView reloadData];
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    });
}

- (void)updateContacts:(NSArray *)bubbyList {
    NSArray *blockList = [[AgoraChatClient sharedClient].contactManager getBlackList];
    NSMutableArray *contacts = [NSMutableArray arrayWithArray:bubbyList];
    for (NSString *blockId in blockList) {
        [contacts removeObject:blockId];
    }
    [self sortContacts:contacts];
    
}

- (void)sortContacts:(NSArray *)contacts {
    if (contacts.count == 0) {
        self.contacts = [@[] mutableCopy];
        _sectionTitles = [@[] mutableCopy];
        _searchSource = [@[] mutableCopy];
        return;
    }
    
    NSMutableArray *sectionTitles = nil;
    NSMutableArray *searchSource = nil;
    NSArray *sortArray = [NSArray sortContacts:contacts
                                 sectionTitles:&sectionTitles
                                  searchSource:&searchSource];
    [self.contacts removeAllObjects];
    [self.contacts addObjectsFromArray:sortArray];
    _sectionTitles = [NSMutableArray arrayWithArray:sectionTitles];
    _searchSource = [NSMutableArray arrayWithArray:searchSource];
}


#pragma mark - Lazy Method
- (NSMutableArray *)contacts {
    if (!_contacts) {
        _contacts = [NSMutableArray array];
    }
    return _contacts;
}

- (NSMutableArray *)contactRequests {
    if (!_contactRequests) {
        _contactRequests = [NSMutableArray array];
    }
    return _contactRequests;
}

- (NSMutableArray *)groupNotifications {
    if (!_groupNotifications) {
        _groupNotifications = [NSMutableArray array];
    }
    return _groupNotifications;
}
    
- (UISearchBar *)searchBar {
    if (!_searchBar) {
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

#pragma mark - Action Method

- (void)addContactAction {
    AgoraAddContactViewController *addContactVc = [[AgoraAddContactViewController alloc] initWithNibName:@"AgoraAddContactViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addContactVc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_isSearchState) {
        return 1;
    }
    return KAgora_CONTACT_BASICSECTION_NUM + _sectionTitles.count;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _sectionTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index + KAgora_CONTACT_BASICSECTION_NUM;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearchState) {
        return _searchResults.count;
    }
    switch (section) {
        case 0:
            return _groupNotifications.count;
        case 1:
            return _contactRequests.count;
        case 2:
            return 2;
    }
    NSArray *array = _contacts[section - KAgora_CONTACT_BASICSECTION_NUM];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        NSString *cellIdentify = @"AgoraContactCell";
        AgoraContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (AgoraContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"AgoraContactCell" owner:self options:nil] lastObject];
        }
        cell.model = _searchResults[indexPath.row];
        return cell;
    }
    
    if (indexPath.section > 2) {
        NSString *cellIdentify = @"AgoraContactCell";
        AgoraContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (AgoraContactCell *)[[[NSBundle mainBundle] loadNibNamed:@"AgoraContactCell" owner:self options:nil] lastObject];
        }
        AgoraUserModel *model = nil;
        if (_contacts.count > indexPath.section-KAgora_CONTACT_BASICSECTION_NUM) {
            NSArray *sectionList = _contacts[indexPath.section-KAgora_CONTACT_BASICSECTION_NUM];
            if (sectionList.count > indexPath.row) {
                model = sectionList[indexPath.row];
            }
        }
        cell.model = model;
        return cell;
    }
    if (indexPath.section == 2) {
        NSString *cellIdentify = @"AgoraGroupTitle_Cell";
        cellIdentify = @"AgoraGroupTitle_Cell";
        AgoraGroupTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (!cell) {
            cell = (AgoraGroupTitleCell *)[[[NSBundle mainBundle] loadNibNamed:@"AgoraGroupTitleCell" owner:self options:nil] lastObject];
        }
        if (indexPath.row == 0) {
            cell.titleLabel.text = NSLocalizedString(@"common.groups", @"Groups");
        } else if (indexPath.row == 1) {
            cell.titleLabel.text = NSLocalizedString(@"common.chatrooms", @"Chat Rooms");
        }
        
        return cell;
    }
    
    NSString *cellIdentifier = @"AgoraApplyRequestCell";
    AgoraApplyRequestCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    AgoraApplyModel *model = nil;
    if (indexPath.section == 0) {
        model = _groupNotifications[indexPath.row];
    }
    else {
        model = _contactRequests[indexPath.row];
    }
    WEAK_SELF
    cell.declineApply = ^(AgoraApplyModel *model) {
        if (model.style == AgoraApplyStyle_contact) {
            [weakSelf reloadContactRequests];
        }
        else {
            [weakSelf reloadGroupNotifications];
        }
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    };
    cell.acceptApply = ^(AgoraApplyModel *model) {
        if (model.style == AgoraApplyStyle_contact) {
            [weakSelf reloadContactRequests];
        }
        else {
            [weakSelf reloadGroupNotifications];
        }
        [[AgoraChatDemoHelper shareHelper] setupUntreatedApplyCount];
    };
    cell.model = model;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 2 && !_isSearchState) {
        if (indexPath.row == 0) {
            AgoraGroupsViewController *groupsVc = [[AgoraGroupsViewController alloc] initWithNibName:@"AgoraGroupsViewController" bundle:nil];
            [self.navigationController pushViewController:groupsVc animated:YES];
        } else if (indexPath.row == 1) {
            AgoraChatroomsViewController *chatroomsVC = [[AgoraChatroomsViewController alloc] init];
            [self.navigationController pushViewController:chatroomsVC animated:YES];
        }
        
        return;
    }
    
    AgoraUserModel * model = nil;
    if (_isSearchState) {
        model = _searchResults[indexPath.row];
    }
    else if (indexPath.section >= KAgora_CONTACT_BASICSECTION_NUM) {
        NSArray *sectionContacts = _contacts[indexPath.section-KAgora_CONTACT_BASICSECTION_NUM];
        model = sectionContacts[indexPath.row];
    }
    if (model) {
        AgoraContactInfoViewController *contactInfoVc = [[AgoraContactInfoViewController alloc] initWithUserModel:model];
        contactInfoVc.addBlackListBlock = ^{
            [self reloadContacts];
        };
        contactInfoVc.deleteContactBlock = ^{
            [self reloadContacts];
        };
        [self.navigationController pushViewController:contactInfoVc animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isSearchState) {
        return 50.0f;
    }
    if (indexPath.section < KAgora_CONTACT_BASICSECTION_NUM - 1) {
        return 60.0f;
    }
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isSearchState) {
        return 0;
    }
    
    switch (section) {
        case 0:
            if (self.groupNotifications.count) {
                return 40.0f;
            }
            break;
        case 1:
            if (self.contactRequests.count) {
                return 40.0f;
            }
            break;
        case 2:
            if (self.contactRequests.count || self.groupNotifications.count) {
                return 20.0;
            }
            break;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    AgoraContactListSectionHeader *sectionHeader = [[[NSBundle mainBundle] loadNibNamed:@"AgoraContactListSectionHeader"
                                                                               owner:self
                                                                             options:nil] firstObject];
    NSUInteger unhandelCount = 0;
    switch (section) {
        case 0:
            unhandelCount = _groupNotifications.count;
            break;
        case 1:
            unhandelCount = _contactRequests.count;
            break;
        default:
            break;
    }
    [sectionHeader updateInfo:unhandelCount section:section];
    return sectionHeader;
}

#pragma mark



- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    _isSearchState = YES;
    self.tableView.userInteractionEnabled = NO;
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    self.tableView.userInteractionEnabled = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.tableView.userInteractionEnabled = YES;
    if (searchBar.text.length == 0) {
        [_searchResults removeAllObjects];
        [self.tableView reloadData];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchWithSource:_searchSource searchString:searchText resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchResults = [NSMutableArray arrayWithArray:results];
                [weakSelf.tableView reloadData];
            });
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    [searchBar setShowsCancelButton:NO animated:NO];
    [searchBar resignFirstResponder];
    [[AgoraRealtimeSearchUtils defaultUtil] realtimeSearchDidFinish];
    _isSearchState = NO;
    self.tableView.scrollEnabled = !_isSearchState;
    [self.tableView reloadData];
}

@end
