/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "EMChatroomMutesViewController.h"

#import "EMMemberCell.h"
#import "UIViewController+HUD.h"
#import "EMNotificationNames.h"

@interface EMChatroomMutesViewController ()

@property (nonatomic, strong) EMChatroom *chatroom;

@end

@implementation EMChatroomMutesViewController

- (instancetype)initWithChatroom:(EMChatroom *)aChatroom
{
    self = [super init];
    if (self) {
        self.chatroom = aChatroom;
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"title.muteList", @"Mute List");
    
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EMMemberCell *cell = (EMMemberCell *)[tableView dequeueReusableCellWithIdentifier:@"EMMemberCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"EMMemberCell" owner:self options:nil] lastObject];
        
        cell.showAccessoryViewInDelete = YES;
    }
    
    cell.imgView.image = [UIImage imageNamed:@"default_avatar"];
    cell.leftLabel.text = [self.dataArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"button.remove", @"Remove");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userName = [self.dataArray objectAtIndex:indexPath.row];

        [self showHudInView:self.view hint:NSLocalizedString(@"hud.wait", @"Pleae wait...")];
        __weak typeof(self) weakSelf = self;
        [[EMClient sharedClient].roomManager unmuteMembers:@[userName] fromChatroom:weakSelf.chatroom.chatroomId completion:^(EMChatroom *aChatroom, EMError *aError) {
            [weakSelf hideHud];
            if (!aError) {
                weakSelf.chatroom = aChatroom;
                [weakSelf.dataArray removeObject:userName];
                [weakSelf.tableView reloadData];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KEM_REFRESH_CHATROOM_INFO object:weakSelf.chatroom];
            }
            else {
                [weakSelf showHint:aError.errorDescription];
            }
        }];
    }
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self fetchBansWithPage:self.page isHeader:YES];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self fetchBansWithPage:self.page isHeader:NO];
}

- (void)fetchBansWithPage:(NSInteger)aPage
                 isHeader:(BOOL)aIsHeader
{
    NSInteger pageSize = 50;
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"hud.load", @"Load data...")];
    [[EMClient sharedClient].roomManager getChatroomMuteListFromServerWithId:self.chatroom.chatroomId pageNumber:aPage pageSize:pageSize completion:^(NSArray *aList, EMError *aError) {
        [weakSelf hideHud];
        [weakSelf tableViewDidFinishTriggerHeader:aIsHeader];
        
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            
            [weakSelf.dataArray addObjectsFromArray:aList];
            [weakSelf.tableView reloadData];
        } else {
            NSString *errorStr = [NSString stringWithFormat:NSLocalizedString(@"group.mute.fetchFail", @"fail to get mutes: %@"), aError.errorDescription];
            [weakSelf showHint:errorStr];
        }
        
        if ([aList count] < pageSize) {
            self.showRefreshFooter = NO;
        } else {
            self.showRefreshFooter = YES;
        }
    }];
}


@end
