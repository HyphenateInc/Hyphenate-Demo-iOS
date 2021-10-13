//
//  AgoraBlackListViewController.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBlockListViewController.h"
#import "AgoraBlackListCell.h"

static NSString *cellIndentifier = @"AgoraBlackListCellIndentifier";

@interface AgoraBlockListViewController ()

@end

@implementation AgoraBlockListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[AgoraBlackListCell class] forCellReuseIdentifier:cellIndentifier];
    [self.tableView reloadData];
}



#pragma mark private method
- (void)updateUI {
    [[AgoraChatClient sharedClient].contactManager getBlackListFromServerWithCompletion:^(NSArray *aList, AgoraChatError *aError) {
        if (aError == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self tableViewDidFinishTriggerHeader:YES];
                self.blockList = aList;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AgoraSettingBlackListDidChange" object:nil];
                
                [self.tableView reloadData];
            });
        }else {
            [self tableViewDidFinishTriggerHeader:YES];
        }
    }];
}

- (void)unBlockWithUserId:(NSString *)userId {
    [[AgoraChatClient sharedClient].contactManager removeUserFromBlackList:userId completion:^(NSString *aUsername, AgoraChatError *aError) {
        if (aError == nil) {
            [self updateUI];
        }else {
            [self showAlertWithMessage:NSLocalizedString(@"contact.unblockFailure", @"Unblock failure")];
        }
    }];
}

- (void)tableViewDidTriggerHeaderRefresh {
    [self updateUI];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.blockList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraBlackListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier forIndexPath:indexPath];
    [cell updateCellWithObj:self.blockList[indexPath.row]];
    cell.unBlockCompletion = ^(NSString * _Nonnull unBlockUserId) {
        [self unBlockWithUserId:unBlockUserId];
    };
    
    return cell;
}


@end
