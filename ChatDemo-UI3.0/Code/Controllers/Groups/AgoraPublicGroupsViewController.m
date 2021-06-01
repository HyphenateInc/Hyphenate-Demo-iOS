/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraPublicGroupsViewController.h"
#import "AgoraGroupCell.h"
#import "AgoraRefreshFootViewCell.h"

#define KPUBLICGROUP_PAGE_COUNT    50

typedef NS_ENUM(NSUInteger, AgoraFetchPublicGroupState) {
    AgoraFetchPublicGroupState_Normal            =           0,
    AgoraFetchPublicGroupState_Loading,
    AgoraFetchPublicGroupState_Nomore
};


@interface AgoraPublicGroupsViewController ()<AgoraGroupUIProtocol>

@property (nonatomic, strong) NSString *cursor;

@property (nonatomic, copy) AgoraGroupModel *requestGroupModel;

@property (nonatomic, strong) NSMutableArray<NSString *> *applyedDataSource;

@property (nonatomic, assign) AgoraFetchPublicGroupState loadState;

@end

@implementation AgoraPublicGroupsViewController
{
    BOOL _isSearching;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self applyedDataSource];
    [self fetchPublicGroups];
}

- (void)setSearchState:(BOOL)isSearching {
    _isSearching = isSearching;
    if (!_isSearching) {
        [_searchResults removeAllObjects];
    }
}

- (NSMutableArray<AgoraGroupModel *> *)publicGroups {
    if (!_publicGroups) {
        _publicGroups = [NSMutableArray array];
    }
    return _publicGroups;
}

- (NSMutableArray<NSString *> *)applyedDataSource {
    if (!_applyedDataSource) {
        _applyedDataSource = [NSMutableArray array];
        NSArray *joinedGroups = [[AgoraChatClient sharedClient].groupManager getJoinedGroups];
        for (AgoraGroup *group in joinedGroups) {
            [_applyedDataSource addObject:group.groupId];
        }
    }
    return _applyedDataSource;
}

- (NSMutableArray<AgoraGroupModel *> *)searchResults {
    if (!_searchResults) {
        _searchResults = [NSMutableArray array];
    }
    return _searchResults;
}

#pragma mark - Load Data

- (void)fetchPublicGroups {
    _loadState = AgoraFetchPublicGroupState_Loading;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1]
                  withRowAnimation:UITableViewRowAnimationNone];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    [[AgoraChatClient sharedClient].groupManager getPublicGroupsFromServerWithCursor:_cursor pageSize:KPUBLICGROUP_PAGE_COUNT completion:^(AgoraCursorResult *aResult, AgoraError *aError) {
        [MBProgressHUD hideHUDForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if (!aError) {
            weakSelf.cursor = aResult.cursor;
            for (AgoraGroup *group in aResult.list) {
                AgoraGroupModel *model = [[AgoraGroupModel alloc] initWithObject:group];
                if (model) {
                    [weakSelf.publicGroups addObject:model];
                }
            }
            weakSelf.loadState = AgoraFetchPublicGroupState_Normal;
            if (weakSelf.cursor.length == 0) {
                weakSelf.loadState = AgoraFetchPublicGroupState_Nomore;
            }
            [weakSelf.tableView reloadData];
        }
    }];
}

- (void)reloadRequestedApplyDataSource {
    __weak typeof(self) weakSelf = self;

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if(_requestGroupModel) {
            [weakSelf.applyedDataSource addObject:_requestGroupModel.group.groupId];
            NSUInteger index = [weakSelf.publicGroups indexOfObject:_requestGroupModel];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView beginUpdates];
                [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [weakSelf.tableView endUpdates];
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
                                               completion:^(AgoraGroup *aGroup, AgoraError *aError) {
                                                   [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                   if (!aError) {
                                                       [weakSelf reloadRequestedApplyDataSource];
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
                                                        completion:^(AgoraGroup *aGroup, AgoraError *aError) {
                                                            [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                            if (!aError) {
                                                                [weakSelf reloadRequestedApplyDataSource];
                                                            }
                                                            else {
                                                                NSString *msg = NSLocalizedString(@"group.requestFailure", @"Failed to apply to the group");
                                                                [weakSelf showAlertWithMessage:msg];
                                                            }
                                                        }];
}

- (void)popAlertView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.joinPublicGroupMessage", "Requesting message")
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"common.cancel", @"Cancel")
                                              otherButtonTitles:NSLocalizedString(@"common.ok", @"OK"), nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_loadState != AgoraFetchPublicGroupState_Nomore && !_isSearching) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isSearching) {
        return _searchResults.count;
    }
    if (_loadState != AgoraFetchPublicGroupState_Nomore && section == 1) {
        return 1;
    }
    return _publicGroups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        static NSString *cellIdentifier = @"AgoraRefreshFootViewCell";
        AgoraRefreshFootViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
        }
        switch (_loadState) {
            case AgoraFetchPublicGroupState_Normal:
                cell.loadMoreLabel.hidden = NO;
                cell.activity.hidden = YES;
                [cell.activity stopAnimating];
                break;
            case AgoraFetchPublicGroupState_Loading:
                cell.loadMoreLabel.hidden = YES;
                cell.activity.hidden = NO;
                [cell.activity startAnimating];
                break;
            default:
                break;
        }
        return cell;
    }
    
    static NSString *cellIdentifier = @"AgoraGroup_Public_Cell";
    AgoraGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil] lastObject];
    }
    AgoraGroupModel *model = nil;
    if (_isSearching) {
        model = _searchResults[indexPath.row];
    }
    else {
        model = _publicGroups[indexPath.row];
    }
    cell.isRequestedToJoinPublicGroup = [_applyedDataSource containsObject:model.group.groupId];
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

#pragma mark - AgoraGroupUIProtocol

- (void)joinPublicGroup:(AgoraGroupModel *)groupModel {
    _requestGroupModel = groupModel;
    if (groupModel.group.setting.style == AgoraGroupStylePublicOpenJoin) {
        [self joinToPublicGroup:groupModel.group.groupId];
    }
    else {
        [self popAlertView];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y >= MAX(0, scrollView.contentSize.height - scrollView.frame.size.height) + 50) {
        if (_loadState == AgoraFetchPublicGroupState_Normal) {
            [self fetchPublicGroups];
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView cancelButtonIndex] != buttonIndex) {
        UITextField *messageTextField = [alertView textFieldAtIndex:0];
        NSString *messageStr = @"";
        if (messageTextField.text.length > 0) {
            messageStr = messageTextField.text;
        }
        [self requestToJoinPublicGroup:_requestGroupModel.group.groupId message:messageStr];
    }
}


@end
