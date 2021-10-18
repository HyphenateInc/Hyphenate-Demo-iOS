//
//  AgoraPublicGroupsNewViewController.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraPublicGroupsViewController.h"
#import "AgoraGroupCell.h"
#import "AgoraRefreshFootViewCell.h"

#define KPUBLICGROUP_PAGE_COUNT    50

static NSString *footerCellIdentifier = @"AgoraRefreshFootViewCell";
static NSString *publicCellIdentifier = @"AgoraGroup_Public_Cell";


typedef NS_ENUM(NSUInteger, AgoraFetchPublicGroupState) {
    AgoraFetchPublicGroupState_Normal    = 0,
    AgoraFetchPublicGroupState_Loading,
    AgoraFetchPublicGroupState_Nomore
};


@interface AgoraPublicGroupsViewController ()<AgoraGroupUIProtocol>
{
    BOOL _isSearching;
}

@property (nonatomic, strong) NSMutableArray<AgoraGroupModel *> *publicGroups;
@property (nonatomic, strong) NSMutableArray<AgoraGroupModel *> *searchResults;
@property (nonatomic, strong) NSMutableArray<NSString *> *applyedGroups;
@property (nonatomic, strong) AgoraGroupModel *requestGroupModel;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic, assign) BOOL isEmptySearchKey;
@property (nonatomic, assign) BOOL isShowSearchResult;
@property (nonatomic, strong) NSIndexPath *selectIndexPath;;


@end

@implementation AgoraPublicGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:publicCellIdentifier bundle:nil] forCellReuseIdentifier:publicCellIdentifier];
    self.isEmptySearchKey = YES;
    [self fetchApplyedGroups];
    [self fetchPublicGroups];
}


#pragma mark - Load Data
- (void)fetchApplyedGroups {
    NSArray *joinedGroups = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
    for (AgoraChatGroup *group in joinedGroups) {
        [self.applyedGroups addObject:group.groupId];
    }
}

- (void)fetchPublicGroups {

    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[AgoraChatClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:_cursor pageSize:KPUBLICGROUP_PAGE_COUNT completion:^(AgoraChatCursorResult *aResult, AgoraChatError *aError) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [self tableViewDidFinishTriggerHeader:YES];
        
        if (!aError) {
            NSArray *groups = [self getGroupsWithResultList:aResult.list];
            if ([_cursor isEqualToString:@""]) {
                self.showRefreshFooter = NO;
                self.publicGroups = [groups mutableCopy];
            }else {
                [self.publicGroups addObjectsFromArray:groups];
            }
            weakSelf.cursor = aResult.cursor;
            [weakSelf.tableView reloadData];
        }
    }];
}

- (NSArray *)getGroupsWithResultList:(NSArray *)list {
    NSMutableArray *tGroups = NSMutableArray.new;
    for (AgoraChatGroup *group in list) {
        AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
        if (model) {
            [tGroups addObject:model];
        }
    }
    return [tGroups copy];
}


- (void)updateUI {
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(_requestGroupModel) {
            [weakSelf.applyedGroups addObject:_requestGroupModel.group.groupId];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadRowsAtIndexPaths:@[self.selectIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                _requestGroupModel = nil;
            });
        }
    });

}

#pragma mark - Join Public Group
- (void)joinToPublicGroup:(NSString *)groupId {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager joinPublicGroup:groupId
                                               completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                                                   [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                   if (!aError) {
                                                       [weakSelf updateUI];
                                                   }
                                                   else {
                                                       NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
                                                       [weakSelf showAlertWithMessage:msg];
                                                   }
                                               }
     ];
}

- (void)requestToJoinPublicGroup:(NSString *)groupId message:(NSString *)message {
    WEAK_SELF
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow
                         animated:YES];
    [[AgoraChatClient sharedClient].groupManager requestToJoinPublicGroup:groupId
                                                           message:message
                                                        completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
                                                            if (!aError) {
                                                                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

                                                                [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];

                                                                [weakSelf updateUI];
                                                            }
                                                            else {
                                                                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];

                                                                NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
                                                                [weakSelf showAlertWithMessage:msg];
                                                            }
                                                        }];
}

- (void)showAlertView {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"group.joinPublicGroupMessage", "Requesting message") message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {

    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
       
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *messageTextField = alertController.textFields.firstObject;
        [self requestToJoinPublicGroup:_requestGroupModel.group.groupId message:messageTextField.text];

    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"%s self.isShowSearchResult:%@ _searchResults.count:%@",__func__,@(self.isShowSearchResult),@(_searchResults.count));
    if (self.isShowSearchResult) {
        return _searchResults.count;
    }
    return _publicGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AgoraGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:publicCellIdentifier];
    AgoraGroupModel *model = nil;
    if (self.isShowSearchResult) {
        model = _searchResults[indexPath.row];
    }else {
        model = _publicGroups[indexPath.row];
    }
    cell.isRequestedToJoinPublicGroup = [_applyedGroups containsObject:model.group.groupId];
    cell.model = model;
    cell.delegate = self;
    return cell;
}


#pragma mark - AgoraGroupUIProtocol
- (void)joinPublicGroup:(AgoraGroupModel *)groupModel {
    _requestGroupModel = groupModel;
    if (self.isShowSearchResult) {
        NSUInteger index = [self.searchResults indexOfObject:groupModel];
        self.selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }else {
        NSUInteger index = [self.publicGroups indexOfObject:groupModel];
        self.selectIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
    }
    if (groupModel.group.setting.style == AgoraChatGroupStylePublicOpenJoin) {
        [self joinToPublicGroup:groupModel.group.groupId];
    }
    else {
        [self showAlertView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y >= MAX(0, scrollView.contentSize.height - scrollView.frame.size.height) + 50) {
        if (_isSearching) {
            return;
        }
        [self fetchPublicGroups];
    }
}


#pragma mark - public refresh
- (void)tableViewDidTriggerHeaderRefresh
{
    if (_isSearching) {
        [self tableViewDidFinishTriggerHeader:YES];
        [self.tableView reloadData];
        return;
    }
    _cursor = @"";
    [self fetchPublicGroups];
}

- (void)tableViewDidTriggerFooterRefresh
{
    if (_isSearching) {
        return;
    }
    [self fetchPublicGroups];
}


#pragma mark getter and setter
- (NSMutableArray<AgoraGroupModel *> *)publicGroups {
    if (!_publicGroups) {
        _publicGroups = [NSMutableArray array];
    }
    return _publicGroups;
}

- (NSMutableArray<NSString *> *)applyedGroups {
    if (!_applyedGroups) {
        _applyedGroups = [NSMutableArray array];
    }
    return _applyedGroups;
}

- (NSMutableArray<AgoraGroupModel *> *)searchResults {
    if (!_searchResults) {
        _searchResults = [NSMutableArray array];
    }
    return _searchResults;
}


- (void)setSearchResultArray:(NSArray *)resultArray isEmptySearchKey:(BOOL)isEmptySearchKey{
    _searchResults = [resultArray mutableCopy];
    _isEmptySearchKey = isEmptySearchKey;
    
    [self.tableView reloadData];
}

- (void)setSearchState:(BOOL)isSearching {
    _isSearching = isSearching;
    if (!_isSearching) {
        [_searchResults removeAllObjects];
    }
}

- (BOOL)isShowSearchResult {
    return  _isSearching && !self.isEmptySearchKey;
}

@end

