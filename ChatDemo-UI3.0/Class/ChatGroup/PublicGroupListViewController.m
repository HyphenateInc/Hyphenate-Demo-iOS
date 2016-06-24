/************************************************************
  *  * Hyphenate   
  * __________________ 
  * Copyright (C) 2016 Hyphenate Inc. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of Hyphenate Inc.

  */

#import "PublicGroupListViewController.h"

#import "EMSearchBar.h"
#import "SRRefreshView.h"
#import "EMSearchDisplayController.h"
#import "PublicGroupDetailViewController.h"
#import "RealtimeSearchUtil.h"
#import "EMCursorResult.h"
#import "BaseTableViewCell.h"

typedef NS_ENUM(NSInteger, GettingMoreFooterViewState){
    eGettingMoreFooterViewStateInitial,
    eGettingMoreFooterViewStateIdle,
    eGettingMoreFooterViewStateGetting,
    eGettingMoreFooterViewStateComplete,
    eGettingMoreFooterViewStateFailed
};

@interface GettingMoreFooterView : UIView
@property (nonatomic) GettingMoreFooterViewState state;
@property (strong, nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) UILabel *label;
@end

@implementation GettingMoreFooterView
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.hidesWhenStopped = YES;
        _activity.hidden = YES;
        [self addSubview:_activity];
        
        _label = [[UILabel alloc] init];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = NSLocalizedString(@"noMoreData", @"No more data");
        _label.hidden = YES;
        [self addSubview:_label];
        
        _state = eGettingMoreFooterViewStateInitial;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _label.frame = self.bounds;
    
    CGSize size = self.frame.size;
    _activity.center = CGPointMake(size.width / 2, size.height / 2);
}

- (void)setState:(GettingMoreFooterViewState)state
{
    _state = state;
    switch (_state) {
        case eGettingMoreFooterViewStateInitial:
            _activity.hidden = YES;
            _label.hidden = YES;
            break;
        case eGettingMoreFooterViewStateIdle:
            _activity.hidden = YES;
            _label.hidden = YES;
            break;
        case eGettingMoreFooterViewStateGetting:
            _activity.hidden = NO;
            [_activity startAnimating];
            _label.hidden = YES;
            break;
        case eGettingMoreFooterViewStateComplete:
            _activity.hidden = YES;
            _label.hidden = NO;
            _label.text = NSLocalizedString(@"noMoreData", @"No more data");
            break;
        case eGettingMoreFooterViewStateFailed:
            _activity.hidden = YES;
            _label.hidden = NO;
            _label.text = NSLocalizedString(@"loadDataFailed", @"");
            break;
        default:
            break;
    }
}

@end

#define FetchPublicGroupsPageSize   50

@interface PublicGroupListViewController ()<UISearchBarDelegate, UISearchDisplayDelegate, SRRefreshDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;

@property (strong, nonatomic) SRRefreshView *slimeView;
@property (strong, nonatomic) EMSearchBar *searchBar;
@property (strong, nonatomic) EMSearchDisplayController *searchController;
@property (strong, nonatomic) GettingMoreFooterView *footerView;
@property (nonatomic, strong) NSString *cursor;
@property (nonatomic) BOOL isGettingMore;
@end

@implementation PublicGroupListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    self.title = NSLocalizedString(@"title.publicGroup", @"Public group");
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = self.footerView;
    self.tableView.tableHeaderView = self.searchBar;
    [self.tableView addSubview:self.slimeView];
    [self searchController];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;

    [self reloadDataSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    NSMutableArray *publicGroups = [self.dataSource mutableCopy];
    [self.dataSource removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [publicGroups removeAllObjects];
    });
}

#pragma mark - getter

- (SRRefreshView *)slimeView
{
    if (_slimeView == nil) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
    }
    
    return _slimeView;
}

- (GettingMoreFooterView *)footerView
{
    if (!_footerView) {
        CGRect frame = self.view.bounds;
        frame.size.height = 50;
        _footerView = [[GettingMoreFooterView alloc] initWithFrame:frame];
    }
    return _footerView;
}

- (UISearchBar *)searchBar
{
    if (_searchBar == nil) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
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
        
        __weak PublicGroupListViewController *weakSelf = self;
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            static NSString *CellIdentifier = @"ContactListCell";
            BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            EMGroup *group = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            NSString *imageName = group.isPublic ? @"group" : @"group";
            cell.imageView.image = [UIImage imageNamed:imageName];
            cell.textLabel.text = group.subject;
            
            return cell;
        }];
        
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return 50;
        }];
        
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            
            EMGroup *group = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            PublicGroupDetailViewController *detailController = [[PublicGroupDetailViewController alloc] initWithGroupId:group.groupId];
            detailController.title = group.subject;
            [weakSelf.navigationController pushViewController:detailController animated:YES];
        }];
    }
    
    return _searchController;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";
    BaseTableViewCell *cell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"group"];
    if (group.subject && group.subject.length > 0) {
        cell.textLabel.text = group.subject;
    }
    else {
        cell.textLabel.text = group.groupId;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    EMGroup *group = [self.dataSource objectAtIndex:indexPath.row];
    PublicGroupDetailViewController *detailController = [[PublicGroupDetailViewController alloc] initWithGroupId:group.groupId];
    detailController.title = group.subject;
    [self.navigationController pushViewController:detailController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_isGettingMore && indexPath.row == ([self.dataSource count] - 1) && [_cursor length])
    {
        __weak typeof(self) weakSelf = self;
        self.footerView.state = eGettingMoreFooterViewStateGetting;
        _isGettingMore = YES;
        [[EMClient sharedClient].groupManager asyncGetPublicGroupsFromServerWithCursor:self.cursor pageSize:FetchPublicGroupsPageSize success:^(EMCursorResult *aCursor) {
            weakSelf.isGettingMore = NO;
            [weakSelf.dataSource addObjectsFromArray:aCursor.list];
            [weakSelf.tableView reloadData];
            weakSelf.cursor = aCursor.cursor;
            if ([aCursor.cursor length])
            {
                weakSelf.footerView.state = eGettingMoreFooterViewStateIdle;
            }
            else
            {
                weakSelf.footerView.state = eGettingMoreFooterViewStateComplete;
            }
        } failure:^(EMError *aError) {
            weakSelf.isGettingMore = NO;
            weakSelf.footerView.state = eGettingMoreFooterViewStateFailed;
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
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataSource searchText:(NSString *)searchText collationStringSelector:@selector(subject) resultBlock:^(NSArray *results) {
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
    
    if ([self.searchController.resultsSource count]) {
        return;
    }
    else
    {
        __block EMGroup *foundGroup= nil;
        [self.dataSource enumerateObjectsUsingBlock:^(EMGroup *group, NSUInteger idx, BOOL *stop){
            if ([group.groupId isEqualToString:searchBar.text])
            {
                foundGroup = group;
                *stop = YES;
            }
        }];
        
        if (foundGroup)
        {
            [self.searchController.resultsSource removeAllObjects];
            [self.searchController.resultsSource addObject:foundGroup];
            [self.searchController.searchResultsTableView reloadData];
        }
        else
        {
            __weak typeof(self) weakSelf = self;
            [self showHudInView:self.view hint:NSLocalizedString(@"searching", @"Searching")];
            [[EMClient sharedClient].groupManager asyncSearchPublicGroupWithId:searchBar.text success:^(EMGroup *aGroup) {
                [weakSelf hideHud];
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObject:aGroup];
                [weakSelf.searchController.searchResultsTableView reloadData];
            } failure:^(EMError *aError) {
                [weakSelf hideHud];
                [weakSelf showHint:NSLocalizedString(@"notFound", @"Can't found")];
            }];
        }
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - UISearchDisplayDelegate

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.tableView.tableHeaderView = nil;
    self.tableView.tableHeaderView = self.searchBar;
}

#pragma mark - SRRefreshDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_slimeView scrollViewDidEndDraging];
}

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self reloadDataSource];
    [_slimeView endRefresh];
}

#pragma mark - data

- (void)reloadDataSource
{
    [self hideHud];
    [self showHudInView:self.view hint:NSLocalizedString(@"loadData", @"Loading data...")];
    _cursor = nil;
    
    __weak typeof(self) weakSelf = self;
    [[EMClient sharedClient].groupManager asyncGetPublicGroupsFromServerWithCursor:self.cursor pageSize:FetchPublicGroupsPageSize success:^(EMCursorResult *aCursor) {
        [weakSelf hideHud];
        [weakSelf.dataSource removeAllObjects];
        [weakSelf.dataSource addObjectsFromArray:aCursor.list];
        [weakSelf.tableView reloadData];
        weakSelf.cursor = aCursor.cursor;
        if ([aCursor.cursor length])
        {
            weakSelf.footerView.state = eGettingMoreFooterViewStateIdle;
        }
        else
        {
            weakSelf.footerView.state = eGettingMoreFooterViewStateComplete;
        }
    } failure:^(EMError *aError) {
        [weakSelf hideHud];
        weakSelf.footerView.state = eGettingMoreFooterViewStateFailed;
    }];
}

@end
