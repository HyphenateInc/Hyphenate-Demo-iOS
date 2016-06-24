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

#import "ChatViewController.h"

#import "ChatGroupDetailViewController.h"
#import "UserProfileViewController.h"
#import "UserProfileManager.h"
#import "ContactListSelectViewController.h"
#import "ChatDemoHelper.h"

@interface ChatViewController ()<UIAlertViewDelegate, EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,EMClientDelegate>

@property (nonatomic) BOOL isPlayingAudio;

@property (nonatomic, strong) NSMutableDictionary *emotionDic;
@property (nonatomic, strong) UIMenuItem *menuItemCopy;
@property (nonatomic, strong) UIMenuItem *menuItemDelete;
@property (nonatomic, strong) UIMenuItem *menuItemForward;

@end

@implementation ChatViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    
    [self setupBarButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitGroup) name:@"ExitGroup" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(insertCallMessage:) name:@"insertCallMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callOutWithChatter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleCallNotification:) name:@"callControllerClose" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if (self.conversation.type == EMConversationTypeChatRoom)
    {
        NSString *conversationID = self.conversation.conversationId;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            EMError *error = nil;
            [[EMClient sharedClient].roomManager asyncLeaveChatroom:conversationID success:^(EMChatroom *aRoom) {
                
            } failure:^(EMError *aError) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                        message:[NSString stringWithFormat:@"Failed to leave chatroom '%@': [%@]", conversationID, error.errorDescription]
                                                                       delegate:nil
                                                              cancelButtonTitle:NSLocalizedString(@"ok", @"ok")
                                                              otherButtonTitles:nil, nil];
                    [alertView show];
                });
            }];
        });
    }
    
    [[EMClient sharedClient] removeDelegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[GAI sharedInstance].defaultTracker set:kGAIScreenName value:NSStringFromClass(self.class)];
    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    if (self.conversation.type == EMConversationTypeGroupChat) {
        
        if ([[self.conversation.ext objectForKey:@"subject"] length]) {
            self.title = [self.conversation.ext objectForKey:@"subject"];
        }
    }
}

#pragma mark - setup subviews

- (void)setupBarButtonItem
{
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                                          style:UIBarButtonItemStylePlain
                                                                         target:self.navigationController
                                                                         action:@selector(popViewControllerAnimated:)];
    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    
    if (self.conversation.type == EMConversationTypeChat) {
        
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"delete"]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(deleteAllMessages:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    else {
        
        UIBarButtonItem *detailButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tabbar_setting"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(showGroupDetailAction)];
        self.navigationItem.rightBarButtonItem = detailButton;

    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        
        self.messageTimeIntervalTag = -1;
        [self.conversation deleteAllMessages];
        [self.dataArray removeAllObjects];
        [self.messsagesSource removeAllObjects];
        
        [self.tableView reloadData];
    }
}

#pragma mark - EaseMessageViewControllerDelegate

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    if (![object isKindOfClass:[NSString class]]) {
        EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        [self showMenuViewController:cell.bubbleView indexPath:indexPath messageType:cell.model.bodyType];
    }
    
    return YES;
}

- (void)messageViewController:(EaseMessageViewController *)viewController
   didSelectAvatarMessageModel:(id<IMessageModel>)messageModel
{
    UserProfileViewController *userprofile = [[UserProfileViewController alloc] initWithUsername:messageModel.message.from];
    [self.navigationController pushViewController:userprofile animated:YES];
}

#pragma mark - EaseMessageViewControllerDataSource

- (id<IMessageModel>)messageViewController:(EaseMessageViewController *)viewController
                           modelForMessage:(EMMessage *)message
{
    id<IMessageModel> model = nil;
    
    model = [[EaseMessageModel alloc] initWithMessage:message];
    model.avatarImage = [UIImage imageNamed:@"user"];
    model.failImageName = @"imageDownloadFail";

    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:model.nickname];
    if (profileEntity) {
        model.avatarURLPath = profileEntity.imageUrl;
        model.nickname = profileEntity.nickname;
    }
    
    return model;
}

- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emojis = [NSMutableArray array];
  
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emojis addObject:emotion];
    }
    
    EaseEmotion *temp = [emojis objectAtIndex:0];
   
    EaseEmotionManager *managerDefault = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emojis tagImage:[UIImage imageNamed:temp.emotionId]];
    
    NSMutableArray *emotionGifs = [NSMutableArray array];
   
    self.emotionDic = [NSMutableDictionary dictionary];
    
    NSArray *names = @[@"icon_002",@"icon_007",@"icon_010",@"icon_012",@"icon_013",@"icon_018",@"icon_019",@"icon_020",@"icon_021",@"icon_022",@"icon_024",@"icon_027",@"icon_029",@"icon_030",@"icon_035",@"icon_040"];
    
    int index = 0;
    
    for (NSString *name in names) {
        index++;
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:[NSString stringWithFormat:@"em%d",(1000 + index)] emotionThumbnail:[NSString stringWithFormat:@"%@_cover",name] emotionOriginal:[NSString stringWithFormat:@"%@",name] emotionOriginalURL:@"" emotionType:EMEmotionGif];
        [emotionGifs addObject:emotion];
        [_emotionDic setObject:emotion forKey:[NSString stringWithFormat:@"em%d",(1000 + index)]];
    }
    
    EaseEmotionManager *managerGif = [[EaseEmotionManager alloc] initWithType:EMEmotionGif emotionRow:2 emotionCol:4 emotions:emotionGifs tagImage:[UIImage imageNamed:@"icon_002_cover"]];
    
    return @[managerDefault, managerGif];
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion = [self.emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController
                                        easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark - Hyphenate

#pragma mark - EMClientDelegate

- (void)didLoginFromOtherDevice
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

- (void)didRemovedFromServer
{
    if ([self.imagePicker.mediaTypes count] > 0 && [[self.imagePicker.mediaTypes objectAtIndex:0] isEqualToString:(NSString *)kUTTypeMovie]) {
        [self.imagePicker stopVideoCapture];
    }
}

#pragma mark - action

- (void)backAction
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    
    [[ChatDemoHelper shareHelper] setChatVC:nil];
    
    if (self.deleteConversationIfNull) {
        EMMessage *message = [self.conversation latestMessage];
        if (message == nil) {
            [[EMClient sharedClient].chatManager deleteConversation:self.conversation.conversationId deleteMessages:NO];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showGroupDetailAction
{
    [self.view endEditing:YES];
    if (self.conversation.type == EMConversationTypeGroupChat) {
        ChatGroupDetailViewController *detailController = [[ChatGroupDetailViewController alloc] initWithGroupId:self.conversation.conversationId];
        [self.navigationController pushViewController:detailController animated:YES];
    }
}

- (void)deleteAllMessages:(id)sender
{
    if (self.dataArray.count == 0) {
        [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.conversation.conversationId];
        if (self.conversation.type != EMConversationTypeChat && isDelete) {
            self.messageTimeIntervalTag = -1;
            [self.conversation deleteAllMessages];
            [self.messsagesSource removeAllObjects];
            [self.dataArray removeAllObjects];
            
            [self.tableView reloadData];
            [self showHint:NSLocalizedString(@"message.noMessage", @"no messages")];
        }
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Messages?" message:NSLocalizedString(@"confirmDeleteMessage", @"Messages will not be able to be retrived") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"Cancel") otherButtonTitles:NSLocalizedString(@"ok", @"OK"), nil];
        [alertView show];
    }
}

- (void)forwardMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        ContactListSelectViewController *listViewController = [[ContactListSelectViewController alloc] initWithNibName:nil bundle:nil];
        listViewController.messageModel = model;
        [listViewController tableViewDidTriggerHeaderRefresh];
        [self.navigationController pushViewController:listViewController animated:YES];
    }
    
    self.menuIndexPath = nil;
}

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        
        if ([self.dataArray count] == 0) {
            self.messageTimeIntervalTag = -1;
        }
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - notification

- (void)exitGroup
{
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)insertCallMessage:(NSNotification *)notification
{
    id object = notification.object;
    if (object) {
        EMMessage *message = (EMMessage *)object;
        [self addMessageToDataSource:message progress:nil];
        [[EMClient sharedClient].chatManager importMessages:@[message]];
    }
}

- (void)handleCallNotification:(NSNotification *)notification
{
    id object = notification.object;
   
    if ([object isKindOfClass:[NSDictionary class]]) {
        self.isViewDidAppear = NO;
    }
    else {
        self.isViewDidAppear = YES;
    }
}

#pragma mark - private

- (void)showMenuViewController:(UIView *)showInView
                     indexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (self.menuController == nil) {
        self.menuController = [UIMenuController sharedMenuController];
    }
    
    if (self.menuItemDelete == nil) {
        self.menuItemDelete = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (self.menuItemCopy == nil) {
        self.menuItemCopy = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (self.menuItemForward == nil) {
        self.menuItemForward = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"forward", @"Forward") action:@selector(forwardMenuAction:)];
    }
    
    if (messageType == EMMessageBodyTypeText) {
        [self.menuController setMenuItems:@[self.menuItemCopy, self.menuItemDelete, self.menuItemForward]];
    }
    else if (messageType == EMMessageBodyTypeImage){
        [self.menuController setMenuItems:@[self.menuItemDelete, self.menuItemForward]];
    }
    else {
        [self.menuController setMenuItems:@[self.menuItemDelete]];
    }
    
    [self.menuController setTargetRect:showInView.frame inView:showInView.superview];
    [self.menuController setMenuVisible:YES animated:YES];
}

@end
