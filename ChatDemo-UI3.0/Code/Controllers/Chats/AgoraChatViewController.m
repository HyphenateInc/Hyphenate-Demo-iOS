/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AgoraChatToolBar.h"
#import "AgoraLocationViewController.h"
#import "AgoraChatBaseCell.h"
#import "AgoraMessageReadManager.h"
#import "AgoraCDDeviceManager.h"
#import "AgoraSDKHelper.h"
#import "AgoraGroupInfoViewController.h"
#import "AgoraConversationModel.h"
#import "AgoraMessageModel.h"
#import "AgoraNotificationNames.h"

#import "AgoraChatroomInfoViewController.h"
#import "UIViewController+HUD.h"
#import "NSObject+AgoraAlertView.h"
#import "AgoraChatToolBar.h"
#import "AgoraChatRecallCell.h"
#import <AVKit/AVKit.h>

static NSString *recallCellIndentifier = @"recallCellIndentifier";

@interface AgoraChatViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,AgoraLocationViewDelegate,AgoraChatManagerDelegate, AgoraChatroomManagerDelegate,AgoraChatBaseCellDelegate,UIActionSheetDelegate, UITableViewDelegate, UITableViewDataSource,AgoraChatToolBarNewDelegate>


@property (strong, nonatomic) AgoraChatToolBar *chatToolBar;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UIImagePickerController *imagePickerController;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *camButton;
@property (strong, nonatomic) UIButton *photoButton;
@property (strong, nonatomic) UIButton *detailButton;
@property (strong, nonatomic) NSIndexPath *longPressIndexPath;

@property (strong, nonatomic) AgoraConversation *currentConversation;
@property (strong, nonatomic) AgoraMessageModel *prevAudioModel;
//need delete Conversation
@property (assign, nonatomic) BOOL isDeleteConversation;


@end

@implementation AgoraChatViewController

- (instancetype)initWithConversationId:(NSString*)conversationId conversationType:(AgoraConversationType)type
{
    self = [super init];
    if (self) {
        _currentConversation = [[AgoraChatClient sharedClient].chatManager getConversation:conversationId type:type createIfNotExist:YES];
        [_currentConversation markAllMessagesAsRead:nil];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endChatWithConversationId:) name:KAgora_END_CHAT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAllMessages:) name:KNOTIFICATIONNAME_DELETEALLMESSAGE object:nil];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    [self setupSubviews];
    
    [self tableViewDidTriggerHeaderRefresh];
    [self _setupNavigationBar];

    [[AgoraChatClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    
    
    if (_currentConversation.type == AgoraConversationTypeChatRoom) {
        [self _joinChatroom:_currentConversation.conversationId];
    }
}


- (void)setupSubviews {
    [self.tableView addSubview:self.refresh];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.chatToolBar];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.chatToolBar.mas_top);

    }];
    
    [self.chatToolBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.mas_equalTo(91);
        make.bottom.equalTo(self.view);
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (AgoraMessageModel *model in self.messages) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:NO]) {
            [unreadMessages addObject:model.message];
        }
    }
    if ([unreadMessages count]) {
        [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
    }
    [_currentConversation markAllMessagesAsRead:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(removeGroupsNotification:)
                                                 name:KAgora_RAgoraOVEGROUP_NOTIFICATION
                                               object:nil];
}

- (void)dealloc
{
    // delete the conversation if no message found
    if (_currentConversation.latestMessage == nil) {
        [[AgoraChatClient sharedClient].chatManager deleteConversation:_currentConversation.conversationId isDeleteMessages:YES completion:nil];
    }
    
    [[AgoraChatClient sharedClient].chatManager removeDelegate:self];
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:KAgora_RAgoraOVEGROUP_NOTIFICATION
                                                  object:nil];
}

#pragma mark - Private Layout Views

- (void)_setupNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    if (_currentConversation.type == AgoraConversationTypeChat) {
//        self.navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.photoButton],[[UIBarButtonItem alloc] initWithCustomView:self.camButton]];
        self.navigationItem.rightBarButtonItem = nil;
        [AgoraUserInfoManagerHelper fetchUserInfoWithUserIds:@[_currentConversation.conversationId] completion:^(NSDictionary * _Nonnull userInfoDic) {
            AgoraUserInfo *userInfo = userInfoDic[_currentConversation.conversationId];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.title = userInfo.nickName ?:userInfo.userId;
            });
        }];
        
    } else if (_currentConversation.type == AgoraConversationTypeGroupChat) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.detailButton];
        self.title = [[AgoraConversationModel alloc] initWithConversation:self.currentConversation].title;
    } else if (_currentConversation.type == AgoraConversationTypeChatRoom) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.detailButton];
        self.title = [[AgoraConversationModel alloc] initWithConversation:self.currentConversation].title;
    }
}

#pragma mark - getter and setter
- (AgoraChatToolBar *)chatToolBar {
    if (_chatToolBar == nil) {
        _chatToolBar = [[AgoraChatToolBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 180.0)];
        _chatToolBar.delegate = self;
    }
    return _chatToolBar;
}

- (AgoraChatBaseTableview *)tableView {
    if (!_tableView) {
        _tableView = [[AgoraChatBaseTableview alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.dataSource = self;
        [_tableView registerClass:[AgoraChatRecallCell class] forCellReuseIdentifier:recallCellIndentifier];
    }
    return _tableView;
}

- (NSString*)conversationId
{
    return _currentConversation.conversationId;
}

- (UIButton*)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 50, 50);
        _backButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"Icon_Back"] forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UIButton*)camButton
{
    if (_camButton == nil) {
        _camButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _camButton.frame = CGRectMake(0, 0, 25, 12);
        [_camButton setImage:[UIImage imageNamed:@"iconVideo"] forState:UIControlStateNormal];
        [_camButton addTarget:self action:@selector(makeVideoCall) forControlEvents:UIControlEventTouchUpInside];
    }
    return _camButton;
}

- (UIButton*)photoButton
{
    if (_photoButton == nil) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectMake(0, 0, 25, 15);
        [_photoButton setImage:[UIImage imageNamed:@"iconCall"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(makeAudioCall) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIButton*)detailButton
{
    if (_detailButton == nil) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailButton.frame = CGRectMake(0, 0, 44, 44);
        [_detailButton setImage:[UIImage imageNamed:@"icon_info"] forState:UIControlStateNormal];
        [_detailButton addTarget:self action:@selector(enterDetailView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _detailButton;
}

- (UIImagePickerController *)imagePickerController
{
    if (_imagePickerController == nil) {
        _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePickerController.allowsEditing = NO;
        _imagePickerController.delegate = self;
    }
    return _imagePickerController;
}

- (NSMutableArray*)messages
{
    if (_messages == nil) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

- (UIRefreshControl*)refresh
{
    if (_refresh == nil) {
        _refresh = [[UIRefreshControl alloc] init];
        _refresh.tintColor = [UIColor lightGrayColor];
        [_refresh addTarget:self action:@selector(_loadMoreMessage) forControlEvents:UIControlEventValueChanged];
    }
    return _refresh;
}

#pragma mark - Notification Method

- (void)removeGroupsNotification:(NSNotification *)notification {
    [self.navigationController popToViewController:self animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AgoraMessageModel *model = [self.messages objectAtIndex:indexPath.row];
    AgoraChatDemoWeakRemind type = AgoraChatDemoWeakRemindMsgTime;

    NSString *cellIdentifier = [AgoraChatBaseCell cellIdentifierForMessageModel:model];
    AgoraChatBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[AgoraChatBaseCell alloc] initWithMessageModel:model];
        cell.delegate = self;
    }
    
    AgoraChatRecallCell *recallCell = (AgoraChatRecallCell *)[tableView dequeueReusableCellWithIdentifier:recallCellIndentifier];
        
    NSString *cellString = nil;
    BOOL isRecallMsg = [model.message.ext[MSG_EXT_RECALL] boolValue];
    
    if (isRecallMsg) {
        if ([model.message.from isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
            cellString = @"您撤回一条消息";
        } else {
            cellString = @"对方撤回一条消息";
        }
        type = AgoraChatDemoWeakRemindSystemHint;
        [recallCell updateCellWithType:type withContent:cellString];
        return recallCell;
        
    }else {
        [cell setMessageModel:model];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AgoraMessageModel *model = [self.messages objectAtIndex:indexPath.row];
    return [AgoraChatBaseCell heightForMessageModel:model];
}

#pragma mark - AgoraChatToolBarDelegate

- (void)chatToolBarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.25 animations:^{
        [self.chatToolBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(91+toHeight);
      }];
    }];
    [self _scrollViewToBottom:NO];
}

- (void)didSendText:(NSString *)text
{
    Message *message = [AgoraSDKHelper initTextMessage:text
                                                   to:_currentConversation.conversationId
                                             chatType:[self _messageType]
                                           messageExt:nil];
    [self _sendMessage:message];
}

- (void)didSendAudio:(NSString *)recordPath duration:(NSInteger)duration
{
    Message *message = [AgoraSDKHelper initVoiceMessageWithLocalPath:recordPath
                                                        displayName:@"audio"
                                                           duration:duration
                                                                 to:_currentConversation.conversationId
                                                        chatType:[self _messageType]
                                                         messageExt:nil];
    [self _sendMessage:message];
}

- (void)didTakePhotos
{
    [self.chatToolBar endEditing:YES];
#if TARGET_IPHONE_SIMULATOR
    
#elif TARGET_OS_IPHONE
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
#endif

}

- (void)didSelectPhotos
{
    [self.chatToolBar endEditing:YES];
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.imagePickerController animated:YES completion:NULL];
}

- (void)didSelectLocation
{
    [self.chatToolBar endEditing:YES];
    AgoraLocationViewController *locationViewController = [[AgoraLocationViewController alloc] init];
    locationViewController.delegate = self;
    [self.navigationController pushViewController:locationViewController animated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        Message *message = [AgoraSDKHelper initVideoMessageWithLocalURL:mp4
                                                           displayName:@"video.mp4"
                                                              duration:0
                                                                    to:_currentConversation.conversationId
                                                              chatType:[self _messageType]
                                                            messageExt:nil];
        [self _sendMessage:message];
        
    }else{
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            Message *message = [AgoraSDKHelper initImageData:data
                                                displayName:@"image.png"
                                                         to:_currentConversation.conversationId
                                                   chatType:[self _messageType]
                                                 messageExt:nil];
            [self _sendMessage:message];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data.length > 10 * 1000 * 1000) {
                                // Warning - large image size
                            }
                            if (data != nil) {
                                Message *message = [AgoraSDKHelper initImageData:data
                                                                    displayName:@"image.png"
                                                                             to:_currentConversation.conversationId
                                                                    chatType:[self _messageType]
                                                                     messageExt:nil];
                                [self _sendMessage:message];
                            } else {
                                // Warning - large image size
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        if (fileData.length > 10 * 1000 * 1000) {
                            // Warning - large image size
                        }
                        Message *message = [AgoraSDKHelper initImageData:fileData
                                                            displayName:@"image.png"
                                                                     to:_currentConversation.conversationId
                                                               chatType:[self _messageType]
                                                             messageExt:nil];
                        [self _sendMessage:message];
                    }
                } failureBlock:NULL];
            }
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePickerController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AgoraLocationViewDelegate

- (void)sendLocationLatitude:(double)latitude
                   longitude:(double)longitude
                  andAddress:(NSString *)address
{
    Message *message = [AgoraSDKHelper initLocationMessageWithLatitude:latitude
                                                            longitude:longitude
                                                              address:address
                                                                   to:_currentConversation.conversationId
                                                          chatType:[self _messageType]
                                                           messageExt:nil];
    [self _sendMessage:message];
}

#pragma mark - AgoraChatBaseCellDelegate

- (void)didHeadImagePressed:(AgoraMessageModel *)model
{
    
}

- (void)didImageCellPressed:(AgoraMessageModel *)model
{
    if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
    }
    ImageMessageBody *body = (ImageMessageBody*)model.message.body;
    if (model.message.direction == MessageDirectionSend && body.localPath.length > 0) {
        UIImage *image = [UIImage imageWithContentsOfFile:body.localPath];
        [[AgoraMessageReadManager shareInstance] showBrowserWithImages:@[image]];
    } else {
        [[AgoraMessageReadManager shareInstance] showBrowserWithImages:@[[NSURL URLWithString:body.remotePath]]];
    }
}

- (void)didAudioCellPressed:(AgoraMessageModel *)model
{
    VoiceMessageBody *body = (VoiceMessageBody*)model.message.body;
    AgoraDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == AgoraDownloadStatusDownloading) {
        return;
    } else if (downloadStatus == AgoraDownloadStatusFailed) {
        [[AgoraChatClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:nil];
        return;
    }
    
    if (body.type == MessageBodyTypeVoice) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        }
        
        BOOL isPrepare = YES;
        if (_prevAudioModel == nil) {
            _prevAudioModel= model;
            model.isPlaying = YES;
        } else if (_prevAudioModel == model){
            model.isPlaying = NO;
            _prevAudioModel = nil;
            isPrepare = NO;
        } else {
            _prevAudioModel.isPlaying = NO;
            model.isPlaying = YES;
        }
        [self.tableView reloadData];
        
        if (isPrepare) {
            WEAK_SELF
            _prevAudioModel = model;
            [[AgoraCDDeviceManager sharedInstance] enableProximitySensor];
            [[AgoraCDDeviceManager sharedInstance] asyncPlayingWithPath:body.localPath completion:^(NSError *error) {
                [weakSelf.tableView reloadData];
                [[AgoraCDDeviceManager sharedInstance] disableProximitySensor];
                model.isPlaying = NO;
            }];
        }
        else{
            [[AgoraCDDeviceManager sharedInstance] disableProximitySensor];
//            _isPlayingAudio = NO;
        }
    }
}

- (void)didVideoCellPressed:(AgoraMessageModel*)model
{
    VideoMessageBody *videoBody = (VideoMessageBody *)model.message.body;
    if (videoBody.downloadStatus == AgoraDownloadStatusSuccessed) {
        if ([self _shouldSendHasReadAckForMessage:model.message read:YES]) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        }
        NSURL *videoURL = [NSURL fileURLWithPath:videoBody.localPath];
        AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
        playerViewController.player = [AVPlayer playerWithURL:videoURL];
        playerViewController.videoGravity = AVLayerVideoGravityResizeAspect;
        playerViewController.showsPlaybackControls = YES;
        playerViewController.modalPresentationStyle = 0;
        [self presentViewController:playerViewController animated:YES completion:^{
            [playerViewController.player play];
        }];
        
        
    } else if (videoBody.downloadStatus == AgoraDownloadStatusDownloading) {
        return;
    } else {
        [[AgoraChatClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(Message *message, AgoraError *error) {
        }];
    }
}

- (void)didLocationCellPressed:(AgoraMessageModel*)model
{
    LocationMessageBody *body = (LocationMessageBody*)model.message.body;
    AgoraLocationViewController *locationController = [[AgoraLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(body.latitude, body.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)didCellLongPressed:(AgoraChatCustomBaseCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    AgoraMessageModel *model = [self.messages objectAtIndex:indexPath.row];
    if (model.message.body.type == MessageBodyTypeText) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"chat.cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"chat.copy", @"Copy"),NSLocalizedString(@"chat.delete", @"Delete"), nil];
        sheet.tag = 1000;
        [sheet showInView:self.view];
        _longPressIndexPath = indexPath;
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:NSLocalizedString(@"chat.cancel", @"Cancel")
                                             destructiveButtonTitle:nil
                                                  otherButtonTitles:NSLocalizedString(@"chat.delete", @"Delete"), nil];
        sheet.tag = 1001;
        [sheet showInView:self.view];
        _longPressIndexPath = indexPath;
    }
}

- (void)didResendButtonPressed:(AgoraMessageModel*)model
{
    WEAK_SELF
    [self.tableView reloadData];
    [[AgoraChatClient sharedClient].chatManager resendMessage:model.message progress:nil completion:^(Message *message, AgoraError *error) {
        NSLog(@"%@",error.errorDescription);
        [weakSelf.tableView reloadData];
    }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1000) {
        if (buttonIndex == 0) {
            if (_longPressIndexPath && _longPressIndexPath.row > 0) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                if (_longPressIndexPath.row > 0) {
                    AgoraMessageModel *model = [self.messages objectAtIndex:_longPressIndexPath.row];
                    if (model.message.body.type == MessageBodyTypeText) {
                        TextMessageBody *body = (TextMessageBody*)model.message.body;
                        pasteboard.string = body.text;
                    }
                }
                _longPressIndexPath = nil;
            }
        } else if (buttonIndex == 1){
            if (_longPressIndexPath && _longPressIndexPath.row >= 0) {
                AgoraMessageModel *model = [self.messages objectAtIndex:_longPressIndexPath.row];
                NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
                [self.currentConversation deleteMessageWithId:model.message.messageId error:nil];
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
                if (_longPressIndexPath.row - 1 >= 0) {
                    id nextMessage = nil;
                    id prevMessage = [self.messages objectAtIndex:(_longPressIndexPath.row - 1)];
                    if (_longPressIndexPath.row + 1 < [self.messages count]) {
                        nextMessage = [self.messages objectAtIndex:(_longPressIndexPath.row + 1)];
                    }
                    if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                        [indexs addIndex:_longPressIndexPath.row - 1];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
                    }
                }
                [self.messages removeObjectsAtIndexes:indexs];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            _longPressIndexPath = nil;
        }
    } else if (actionSheet.tag == 1001) {
        if (buttonIndex == 0){
            if (_longPressIndexPath) {
                AgoraMessageModel *model = [self.messages objectAtIndex:_longPressIndexPath.row];
                NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:_longPressIndexPath.row];
                [self.currentConversation deleteMessageWithId:model.message.messageId error:nil];
                NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:_longPressIndexPath, nil];;
                if (_longPressIndexPath.row - 1 >= 0) {
                    id nextMessage = nil;
                    id prevMessage = [self.messages objectAtIndex:(_longPressIndexPath.row - 1)];
                    if (_longPressIndexPath.row + 1 < [self.messages count]) {
                        nextMessage = [self.messages objectAtIndex:(_longPressIndexPath.row + 1)];
                    }
                    if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                        [indexs addIndex:_longPressIndexPath.row - 1];
                        [indexPaths addObject:[NSIndexPath indexPathForRow:(_longPressIndexPath.row - 1) inSection:0]];
                    }
                }
                [self.messages removeObjectsAtIndexes:indexs];
                [self.tableView beginUpdates];
                [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView endUpdates];
            }
            _longPressIndexPath = nil;
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    _longPressIndexPath = nil;
}

#pragma mark - action

- (void)tableViewDidTriggerHeaderRefresh
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [_currentConversation loadMessagesStartFromId:nil
                                         count:20
                               searchDirection:MessageSearchDirectionUp
                                    completion:^(NSArray *aMessages, AgoraError *aError) {
                                        if (!aError) {
                                            [weakSelf.messages removeAllObjects];
                                            for (Message * message in aMessages) {
                                                [weakSelf _addMessageToDataSource:message];
                                            }
                                            [weakSelf.refresh endRefreshing];
                                            [weakSelf.tableView reloadData];
                                            [weakSelf _scrollViewToBottom:NO];
                                        }
                                    }];
    });
}

- (void)makeVideoCall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.currentConversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
}

- (void)makeAudioCall
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.currentConversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
}

- (void)enterDetailView
{
    if (_currentConversation.type == AgoraConversationTypeGroupChat) {
        AgoraGroupInfoViewController *groupInfoViewController = [[AgoraGroupInfoViewController alloc] initWithGroupId:_currentConversation.conversationId];
        groupInfoViewController.updateGroupNameBlock = ^(NSString *groupName) {
            self.title = groupName;
        };
        [self.navigationController pushViewController:groupInfoViewController animated:YES];
    } else if (_currentConversation.type == AgoraConversationTypeChatRoom) {
        AgoraChatroomInfoViewController *infoController = [[AgoraChatroomInfoViewController alloc] initWithChatroomId:self.currentConversation.conversationId];
        [self.navigationController pushViewController:infoController animated:YES];
    }
}

- (void)backAction
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_UPDATEUNREADCOUNT object:nil];
    if (_currentConversation.type == AgoraConversationTypeChatRoom) {
        [self showHudInView:[UIApplication sharedApplication].keyWindow hint:NSLocalizedString(@"chatroom.leaving", @"Leaving the chatroom...")];
        WEAK_SELF
        [[AgoraChatClient sharedClient].roomManager leaveChatroom:_currentConversation.conversationId completion:^(AgoraError *aError) {
            [weakSelf hideHud];
            if (aError) {
                [self showAlertWithMessage:[NSString stringWithFormat:@"Leave chatroom '%@' failed [%@]", weakSelf.currentConversation.conversationId, aError.errorDescription] ];
            }
            [weakSelf.navigationController popToViewController:self animated:YES];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    } else {
        if (self.leaveGroupBlock && self.isDeleteConversation) {
            self.leaveGroupBlock();
        }
        
        [self.navigationController popToViewController:self animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deleteAllMessages:(id)sender
{
    if (self.messages.count == 0) {
        return;
    }
    
    if ([sender isKindOfClass:[NSNotification class]]) {
        NSString *groupId = (NSString *)[(NSNotification *)sender object];
        BOOL isDelete = [groupId isEqualToString:self.currentConversation.conversationId];
        if (self.currentConversation.type != AgoraConversationTypeChat && isDelete) {
            [self.currentConversation deleteAllMessages:nil];
            [self.messages removeAllObjects];
            
            [self.tableView reloadData];
        }
    }
}

- (void)endChatWithConversationId:(NSNotification *)aNotification
{
    id obj = aNotification.object;
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *conversationId = (NSString *)obj;
        if ([conversationId length] > 0 && [conversationId isEqualToString:self.conversationId]) {
            self.isDeleteConversation = YES;
            [self backAction];
        }
    } else if ([obj isKindOfClass:[AgoraChatroom class]] && self.currentConversation.type == AgoraConversationTypeChatRoom) {
        AgoraChatroom *chatroom = (AgoraChatroom *)obj;
        if ([chatroom.chatroomId isEqualToString:self.conversationId]) {
            [self.navigationController popToViewController:self animated:YES];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - GestureRecognizer

- (void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.view endEditing:YES];
    }
}

#pragma mark - private

- (void)_joinChatroom:(NSString *)aChatroomId
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"chatroom.joining", @"Joining the chatroom")];
    [[AgoraChatClient sharedClient].roomManager joinChatroom:aChatroomId completion:^(AgoraChatroom *aChatroom, AgoraError *aError) {
        [self hideHud];
        if (aError) {
            if (aError.code == AgoraErrorChatroomAlreadyJoined) {
                [[AgoraChatClient sharedClient].roomManager leaveChatroom:aChatroomId completion:nil];
            }
            
            [weakSelf showAlertWithMessage:[NSString stringWithFormat:NSLocalizedString(@"chatroom.joinFailed",@"join chatroom \'%@\' failed"), aChatroomId]];
            [weakSelf backAction];
        } else {
            NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:weakSelf.currentConversation.ext];
            [ext setObject:aChatroom.subject forKey:@"subject"];
            weakSelf.currentConversation.ext = ext;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
        }
    }];
}

- (void)_sendMessage:(Message*)message
{
    [self _addMessageToDataSource:message];
    [self.tableView reloadData];
    WEAK_SELF
    [[AgoraChatClient sharedClient].chatManager sendMessage:message progress:nil completion:^(Message *message, AgoraError *error) {
        [weakSelf.tableView reloadData];
    }];
    [self _scrollViewToBottom:YES];
}

- (void)_addMessageToDataSource:(Message*)message
{
    AgoraMessageModel *model = [[AgoraMessageModel alloc] initWithMessage:message];
    __block AgoraUserInfo *userInfo = nil;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [AgoraUserInfoManagerHelper fetchUserInfoWithUserIds:@[message.from] completion:^(NSDictionary * _Nonnull userInfoDic) {
        userInfo = userInfoDic[message.from];
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    model.userInfo = userInfo;
    [self.messages addObject:model];
}

- (void)_scrollViewToBottom:(BOOL)animated
{
    if(_messages.count > 0){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC * 100), dispatch_get_main_queue(), ^{
            NSIndexPath *indexpath = [NSIndexPath indexPathForRow:_messages.count-1 inSection:0];
            [_tableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        });
    }
}

- (void)_loadMoreMessage
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *messageId = nil;
        if ([weakSelf.messages count] > 0) {
            AgoraMessageModel *model = [weakSelf.messages objectAtIndex:0];
            messageId = model.message.messageId;
        }
        [_currentConversation loadMessagesStartFromId:messageId
                                         count:20
                               searchDirection:MessageSearchDirectionUp
                                    completion:^(NSArray *aMessages, AgoraError *aError) {
                                        if (!aError) {
                                            [aMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                                AgoraMessageModel *model = [[AgoraMessageModel alloc] initWithMessage:(Message*)obj];
                                                [weakSelf.messages insertObject:model atIndex:0];
                                            }];
                                            [weakSelf.refresh endRefreshing];
                                            [weakSelf.tableView reloadData];
                                        }
                                    }];
    });
}

- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *dataPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer", NSHomeDirectory()];
        NSFileManager *fm = [NSFileManager defaultManager];
        if(![fm fileExistsAtPath:dataPath]){
            [fm createDirectoryAtPath:dataPath
          withIntermediateDirectories:YES
                           attributes:nil
                                error:nil];
        }
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", dataPath, (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        Message *message = messages[i];
        BOOL isSend = [self _shouldSendHasReadAckForMessage:message
                                                      read:isRead];
        if (isSend) {
            [unreadMessages addObject:message];
        }
    }
    if ([unreadMessages count]) {
        for (Message *message in unreadMessages) {
            [[AgoraChatClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

- (BOOL)_shouldSendHasReadAckForMessage:(Message *)message
                                  read:(BOOL)read
{
    NSString *account = [[AgoraChatClient sharedClient] currentUsername];
    if (message.chatType != AgoraChatTypeChat || message.isReadAcked || [account isEqualToString:message.from] || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)) {
        return NO;
    }
    
    MessageBody *body = message.body;
    if (((body.type == MessageBodyTypeVideo) ||
         (body.type == MessageBodyTypeVoice) ||
         (body.type == MessageBodyTypeImage)) &&
        !read) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        isMark = NO;
    }
    return isMark;
}

- (AgoraChatType)_messageType
{
    AgoraChatType type = AgoraChatTypeChat;
    switch (_currentConversation.type) {
        case AgoraConversationTypeChat:
            type = AgoraChatTypeChat;
            break;
        case AgoraConversationTypeGroupChat:
            type = AgoraChatTypeGroupChat;
            break;
        case AgoraConversationTypeChatRoom:
            type = AgoraChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

#pragma mark - AgoraChatManagerDelegate

- (void)messagesDidReceive:(NSArray *)aMessages
{
    for (Message *message in aMessages) {
        if ([self.currentConversation.conversationId isEqualToString:message.conversationId]) {
            [self _addMessageToDataSource:message];
            [self _sendHasReadResponseForMessages:@[message]
                                           isRead:NO];
            if ([self _shouldMarkMessageAsRead]) {
                [self.currentConversation markMessageAsReadWithId:message.messageId error:nil];
            }
        }
    }
    [self.tableView reloadData];
    [self _scrollViewToBottom:YES];
}

- (void)messageAttachmentStatusDidChange:(Message *)aMessage
                                   error:(AgoraError *)aError
{
    if ([self.currentConversation.conversationId isEqualToString:aMessage.conversationId]) {
        [self.tableView reloadData];
    }
}

- (void)messagesDidRead:(NSArray *)aMessages
{
    for (Message *message in aMessages) {
        if ([self.currentConversation.conversationId isEqualToString:message.conversationId]) {
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    NSLog(@"%s aMessages:%@",__func__,aMessages);

    [aMessages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Message *msg = (Message *)obj;
        NSLog(@"%s msg.ext:%@",__func__,msg.ext);

        [self.messages enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[AgoraMessageModel class]]) {
                AgoraMessageModel *model = (AgoraMessageModel *)obj;
                if ([model.message.messageId isEqualToString:msg.messageId]) {
                    Message *message = [[Message alloc] initWithConversationID:msg.conversationId from:msg.from to:msg.to body:msg.body ext:@{MSG_EXT_RECALL:@(YES)}];
                    message.chatType = (AgoraChatType)self.currentConversation.type;
                    message.isRead = YES;
                    message.messageId = msg.messageId;
                    message.localTime = msg.localTime;
                    message.timestamp = msg.timestamp;
                    [self.currentConversation insertMessage:message error:nil];
                    AgoraMessageModel *replaceModel = [[AgoraMessageModel alloc] initWithMessage:message];
                    replaceModel.isRecall = YES;
                    NSLog(@"%s message.messageId:%@ :%@",__func__,replaceModel.message.messageId,@(replaceModel.isRecall));
                    [self.messages replaceObjectAtIndex:idx withObject:replaceModel];
            }
           }
        }];
    }];

    [self.tableView reloadData];
}


#pragma mark - AgoraChatManagerChatroomDelegate

- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom
                       user:(NSString *)aUsername
{
    [self showHint:[NSString stringWithFormat:NSLocalizedString(@"chatroom.join", @"\'%@\'join chatroom\'%@\'"), aUsername, aChatroom.chatroomId]];
}

- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom
                        user:(NSString *)aUsername
{
    [self showHint:[NSString stringWithFormat:NSLocalizedString(@"chatroom.leave.hint", @"\'%@\'leave chatroom\'%@\'"), aUsername, aChatroom.chatroomId]];
}

- (void)didDismissFromChatroom:(AgoraChatroom *)aChatroom
                        reason:(AgoraChatroomBeKickedReason)aReason
{
    if ([_currentConversation.conversationId isEqualToString:aChatroom.chatroomId])
    {
        [self showHint:[NSString stringWithFormat:NSLocalizedString(@"chatroom.remove", @"be removed from chatroom\'%@\'"), aChatroom.chatroomId]];
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


@end
