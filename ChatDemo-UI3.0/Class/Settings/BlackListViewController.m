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

#import "BlackListViewController.h"

#import "BaseTableViewCell.h"
#import "SRRefreshView.h"

#import "ChatDemoHelper.h"

@interface BlackListViewController () <UITableViewDataSource, UITableViewDelegate, SRRefreshDelegate>

@property (strong, nonatomic) NSMutableArray *dataSource;
@property (strong, nonatomic) NSMutableArray *sectionTitles;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) SRRefreshView *slimeView;

@end

@implementation BlackListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.dataSource = [NSMutableArray array];
        self.sectionTitles = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.title = NSLocalizedString(@"friend.black", @"Black List");
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    
    self.slimeView = [[SRRefreshView alloc] init];
    self.slimeView.delegate = self;
    self.slimeView.upInset = 0;
    self.slimeView.slimeMissWhenGoingBack = YES;
    self.slimeView.slime.bodyColor = [UIColor grayColor];
    self.slimeView.slime.skinColor = [UIColor grayColor];
    self.slimeView.slime.lineWith = 1;
    self.slimeView.slime.shadowBlur = 4;
    self.slimeView.slime.shadowColor = [UIColor grayColor];
    [self.tableView addSubview:self.slimeView];
    
    [self.slimeView setLoadingWithexpansion];
    
    [self loadBlacklistData];
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
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    self.slimeView.delegate = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.dataSource count] > 0) {
        return 1;
    }
    else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"blacklistCell";
    
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *username = [self.dataSource objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:@"chatListCellHead.png"];
    cell.textLabel.text = username;
    cell.username = username;
    
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *username = [self.dataSource objectAtIndex:indexPath.row];
        __weak typeof(self) weakself = self;
        [[EMClient sharedClient].contactManager asyncRemoveUserFromBlackList:username success:^{
            [[ChatDemoHelper shareHelper].contactViewVC reloadDataSource];
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        } failure:^(EMError *aError) {
            [weakself showHint:aError.errorDescription];
        }];
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 22;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *contentView = [[UIView alloc] init];
//    [contentView setBackgroundColor:[UIColor HIPrimaryColor]];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
//    label.backgroundColor = [UIColor whiteColor];
//    
//    if (self.sectionTitles.count > 0) {
//        label.text = [self.sectionTitles objectAtIndex:section];
//    }
//    
//    [contentView addSubview:label];
//    
//    return contentView;
//}
//
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray * existTitles = [NSMutableArray array];
//    for (int i = 0; i < [self.sectionTitles count]; i++) {
//        if ([[self.dataSource objectAtIndex:i] count] > 0) {
//            [existTitles addObject:[self.sectionTitles objectAtIndex:i]];
//        }
//    }
//    return existTitles;
//}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - scrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.slimeView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.slimeView scrollViewDidEndDraging];
}


#pragma mark - slimeRefresh delegate

- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [self loadBlacklistData];
}


#pragma mark - data

- (void)loadBlacklistData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [self.dataSource removeAllObjects];
        
        [[EMClient sharedClient].contactManager asyncGetBlackListFromServer:^(NSArray *aList) {
            
            [self.dataSource addObjectsFromArray:aList];

            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                [self.slimeView endRefresh];
            });
        } failure:^(EMError *aError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.tableView reloadData];
                
                [self.slimeView endRefresh];
            });
        }];
        
        

    });
}


@end
