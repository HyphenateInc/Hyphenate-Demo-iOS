/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatsSettingViewController.h"
#import "AgoraBlockListViewController.h"

@interface AgoraChatsSettingViewController ()
@property (nonatomic, strong) UISwitch *autoAcceptSitch;
@property (nonatomic) BOOL autoAcceptInvitation;
@property (nonatomic,strong) NSArray *blockList;
@property (nonatomic) BOOL hasBlockList;

@end

@implementation AgoraChatsSettingViewController

- (UISwitch *)autoAcceptSitch
{
    if (!_autoAcceptSitch) {
        _autoAcceptSitch = [[UISwitch alloc] init];
        [_autoAcceptSitch addTarget:self action:@selector(autoAcceptAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _autoAcceptSitch;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavigationBar];
    [self loadOptions];
    
    [self fetchBlockList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fetchBlockList];
}

#pragma mark private method
- (void)loadOptions
{
    AgoraChatOptions *options = [[AgoraChatClient sharedClient] options];
    _autoAcceptInvitation = options.isAutoAcceptGroupInvitation;
    [self.autoAcceptSitch setOn:_autoAcceptInvitation animated:YES];
    [self.tableView reloadData];
}

- (void)autoAcceptAction:(UISwitch *)sender
{
    AgoraChatOptions *options = [[AgoraChatClient sharedClient] options];
    options.isAutoAcceptGroupInvitation = sender.isOn;
}


- (void)fetchBlockList {
    [[AgoraChatClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        NSLog(@"%s aList :%@",__func__,aList);
        
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.blockList = aList;
                self.hasBlockList = aList.count > 0 ? YES : NO;
                [self.tableView reloadData];
            });
        }
    }];
    
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.hasBlockList ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ChatsCell";
    AgoraChatCustomBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        
        cell = [[AgoraChatCustomBaseCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    if (self.hasBlockList) {
        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"setting.chats.acceptInvitation", @"Accept group invites automatically");
            self.autoAcceptSitch.frame = CGRectMake(tableView.frame.size.width - 65, 8, 50, 30);
            [cell.contentView addSubview:self.autoAcceptSitch];
        }

        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"setting.chats.blockedUsers", @"Blocked Users");
        }
        
    }else {
        cell.textLabel.text = NSLocalizedString(@"setting.chats.acceptInvitation", @"Accept group invites automatically");
        self.autoAcceptSitch.frame = CGRectMake(tableView.frame.size.width - 65, 8, 50, 30);
        [cell.contentView addSubview:self.autoAcceptSitch];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hasBlockList && indexPath.row == 1) {
        AgoraBlockListViewController *vc = [[AgoraBlockListViewController alloc] init];
        vc.blockList = self.blockList;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
