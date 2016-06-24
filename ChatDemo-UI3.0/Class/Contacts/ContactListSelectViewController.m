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

#import "ContactListSelectViewController.h"

#import "ChatViewController.h"
#import "UserProfileManager.h"

@interface ContactListSelectViewController () <EMUserListViewControllerDelegate,EMUserListViewControllerDataSource>

@end

@implementation ContactListSelectViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
    self.dataSource = self;
    
    self.title = NSLocalizedString(@"title.chooseContact", @"select the contact");
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - EMUserListViewControllerDelegate

- (void)userListViewController:(EaseUsersListViewController *)userListViewController
            didSelectUserModel:(id<IUserModel>)userModel
{

    if (self.messageModel) {
        if (self.messageModel.bodyType == EMMessageBodyTypeText) {
            EMMessage *message = [EaseSDKHelper sendTextMessage:self.messageModel.text to:userModel.username messageType:EMChatTypeChat messageExt:self.messageModel.message.ext];
            __weak typeof(self) weakself = self;
            [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
                if (!aError) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationID:userModel.username conversationType:EMConversationTypeChat];
                    chatController.title = userModel.nickname.length != 0 ? [userModel.nickname copy] : [userModel.username copy];
                    if ([array count] >= 3) {
                        [array removeLastObject];
                        [array removeLastObject];
                    }
                    [array addObject:chatController];
                    [weakself.navigationController setViewControllers:array animated:YES];
                } else {
                    [self showHudInView:self.view hint:NSLocalizedString(@"forwardFail", @"")];
                }
            }];
        } else if (self.messageModel.bodyType == EMMessageBodyTypeImage) {

            [self showHudInView:self.view hint:NSLocalizedString(@"forwarding", @"Forwarding...")];
            
            UIImage *image = self.messageModel.image;
            if (image) {
                image = [UIImage imageWithContentsOfFile:self.messageModel.fileLocalPath];
            }
            EMMessage *message= [EaseSDKHelper sendImageMessageWithImage:image to:userModel.username messageType:EMChatTypeChat messageExt:self.messageModel.message.ext];
            
            [[EMClient sharedClient].chatManager asyncSendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                if (!error) {
                    NSMutableArray *array = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
                    ChatViewController *chatController = [[ChatViewController alloc] initWithConversationID:userModel.username conversationType:EMConversationTypeChat];
                    chatController.title = userModel.nickname.length != 0 ? userModel.nickname : userModel.username;
                    if ([array count] >= 3) {
                        [array removeLastObject];
                        [array removeLastObject];
                    }
                    [array addObject:chatController];
                    [self.navigationController setViewControllers:array animated:YES];
                } else {
                    [self showHudInView:self.view hint:NSLocalizedString(@"forwardFail", @"")];
                }
            }];
        }
    }
}

#pragma mark - EMUserListViewControllerDataSource

- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                           modelForusername:(NSString *)username
{
    id<IUserModel> model = nil;
    model = [[EaseUserModel alloc] initWithUsername:username];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.username];
    if (profileEntity) {
        model.nickname= profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
        model.avatarURLPath = profileEntity.imageUrl;
    }
    return model;
}

- (id<IUserModel>)userListViewController:(EaseUsersListViewController *)userListViewController
                   userModelForIndexPath:(NSIndexPath *)indexPath
{
    id<IUserModel> model = nil;
    model = [self.dataArray objectAtIndex:indexPath.row];
    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.username];
    if (profileEntity) {
        model.nickname= profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
        model.avatarURLPath = profileEntity.imageUrl;
    }
    return model;
}

@end
