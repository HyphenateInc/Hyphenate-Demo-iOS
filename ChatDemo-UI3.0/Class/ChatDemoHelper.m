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

#import "ChatDemoHelper.h"

#import "AppDelegate.h"
#import "FriendRequestViewController.h"
#import "MBProgressHUD.h"

#if DEMO_CALL == 1

#import "CallViewController.h"

@interface ChatDemoHelper()<EMCallManagerDelegate>
{
    NSTimer *_callTimer;
}

@end

#endif

static ChatDemoHelper *helper = nil;

@implementation ChatDemoHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[ChatDemoHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[EMClient sharedClient] removeDelegate:self];
    [[EMClient sharedClient].groupManager removeDelegate:self];
    [[EMClient sharedClient].contactManager removeDelegate:self];
    [[EMClient sharedClient].roomManager removeDelegate:self];
    [[EMClient sharedClient].chatManager removeDelegate:self];
    
#if DEMO_CALL == 1
    [[EMClient sharedClient].callManager removeDelegate:self];
#endif
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
#if DEMO_CALL == 1
    [[EMClient sharedClient].callManager setVideoAdaptive:YES];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
#endif
}


#pragma mark - Data

- (void)asyncPushOptions
{
    [[EMClient sharedClient] asyncGetPushOptionsFromServer:^(EMPushOptions *aOptions) {
    } failure:^(EMError *aError) {
    }];
}

- (void)asyncGroupFromServer
{
    [[EMClient sharedClient].groupManager loadAllMyGroupsFromDB];
    
    [[EMClient sharedClient].groupManager asyncGetMyGroupsFromServer:^(NSArray *aList) {
        
        if (self.contactViewVC) {
            [self.contactViewVC reloadGroupView];
        }
        
    } failure:^(EMError *aError) {
    }];
}

- (void)asyncConversationFromDB
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *conversationsFromDB = [[EMClient sharedClient].chatManager loadAllConversationsFromDB];
        
        [conversationsFromDB enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
            if(!conversation.latestMessage){
                [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId deleteMessages:NO];
            }
        }];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_conversationUpdated object:conversations];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_unreadMessageCountUpdated object:conversations];
        });
    });
}


#pragma mark - EMClientDelegate

- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
    [self.mainVC networkChanged:connectionState];
}

- (void)didAutoLoginWithError:(EMError *)error
{
    if (error) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"login.errorAutoLogin", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil, nil];
        alertView.tag = 100;
        
        [alertView show];
    }
    else if([[EMClient sharedClient] isConnected]){
        
        UIView *view = self.mainVC.view;
        
        [MBProgressHUD showHUDAddedTo:view animated:YES];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            BOOL flag = [[EMClient sharedClient] dataMigrationTo3];
            if (flag) {
                [self asyncGroupFromServer];
                [self asyncConversationFromDB];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:view animated:YES];
            });
        });
    }
}

- (void)didLoginFromOtherDevice
{
    [self logout];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loggedIntoAnotherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)didRemovedFromServer
{
    [self logout];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    
    [alertView show];
}


#pragma mark - EMChatManagerDelegate

- (void)didUpdateConversationList:(NSArray *)aConversationList
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_unreadMessageCountUpdated object:aConversationList];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_conversationUpdated object:aConversationList];
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveCmdMessages object:aCmdMessages];
}

- (void)didReceiveMessages:(NSArray *)aMessages
{
    BOOL isRefreshCons = YES;
    
    for(EMMessage *message in aMessages){
        
        BOOL needShowNotification = (message.chatType != EMChatTypeChat) ? [self _needShowNotification:message.conversationId] : YES;
        
        if (needShowNotification) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveMessages object:message];
        }
        
        if (!self.chatVC) {
            self.chatVC = [self _getCurrentChatView];
        }
        
        BOOL isSameConversation = NO;
        if (self.chatVC) {
            isSameConversation = [message.conversationId isEqualToString:self.chatVC.conversation.conversationId];
        }
        if (!self.chatVC || !isSameConversation) {

            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveMessages object:message];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_unreadMessageCountUpdated object:nil];

            return;
        }
        
        if (isSameConversation) {
            isRefreshCons = NO;
        }
    }
    
    if (isRefreshCons) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveMessages object:[aMessages objectAtIndex:0]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_unreadMessageCountUpdated object:nil];
    }
}

#pragma mark - EMGroupManagerDelegate

- (void)didReceiveLeavedGroup:(EMGroup *)aGroup
                       reason:(EMGroupLeaveReason)aReason
{
    NSString *str = nil;
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        str = [NSString stringWithFormat:@"Your are kicked out from group: %@ [%@]", aGroup.subject, aGroup.groupId];
    } else if (aReason == EMGroupLeaveReasonDestroyed) {
        str = [NSString stringWithFormat:@"Group: %@ [%@] is destroyed", aGroup.subject, aGroup.groupId];
    }
    
    if (str.length > 0) {
        TTAlertNoTitle(str);
    }
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.mainVC.navigationController.viewControllers];
    ChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]] && [aGroup.groupId isEqualToString:[(ChatViewController *)viewController conversation].conversationId])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    if (chatViewContrller)
    {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [self.mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [self.mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
}

- (void)didReceiveJoinGroupApplication:(EMGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason
{
    if (!aGroup || !aApplicant) {
        return;
    }
    
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.joinRequest", @"%@ requested to join the group\'%@\'"), aApplicant, aGroup.subject];
    }
    else {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.joinRequestWithName", @"%@ requested to join the group\'%@\'：%@"), aApplicant, aGroup.subject, aReason];
    }
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":aGroup.subject, @"groupId":aGroup.groupId, @"username":aApplicant, @"groupname":aGroup.subject, @"applyMessage":aReason, @"requestType":[NSNumber numberWithInteger:HIRequestTypeJoinGroup]}];
    
    [[FriendRequestViewController shareController] addNewRequest:requestDict];
   
    if (self.mainVC) {
        
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
#endif
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveRequest object:requestDict];
}

- (void)didJoinedGroup:(EMGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:[NSString stringWithFormat:@"%@ invite you to group: %@ [%@]", aInviter, aGroup.subject, aGroup.groupId] delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    
    [alertView show];
}

- (void)didReceiveDeclinedJoinGroup:(NSString *)aGroupId
                             reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.joinRequestDeclined", @"be refused to join the group\'%@\'"), aGroupId];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:aReason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
   
    [alertView show];
}

- (void)didReceiveAcceptedJoinGroup:(EMGroup *)aGroup
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed to join the group of \'%@\'"), aGroup.subject];
   
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
   
    [alertView show];
}

- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if (!aGroupId || !aInviter) {
        return;
    }
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":@"", @"groupId":aGroupId, @"username":aInviter, @"groupname":@"", @"applyMessage":aMessage, @"requestType":[NSNumber numberWithInteger:HIRequestTypeReceivedGroupInvitation]}];
    
    [[FriendRequestViewController shareController] addNewRequest:requestDict];
    
    if (self.mainVC) {
        
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
#endif
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveRequest object:requestDict];
}

#pragma mark - EMContactManagerDelegate

- (void)didReceiveAgreedFromUsername:(NSString *)aUsername
{
    NSString *msgstr = [NSString stringWithFormat:@"%@ accepted friend request", aUsername];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgstr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeclinedFromUsername:(NSString *)aUsername
{
    NSString *msgstr = [NSString stringWithFormat:@"%@ declined friend request", aUsername];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:msgstr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"ok") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)didReceiveDeletedFromUsername:(NSString *)aUsername
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.mainVC.navigationController.viewControllers];
    
    ChatViewController *chatViewContrller = nil;
    
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]] && [aUsername isEqualToString:[(ChatViewController *)viewController conversation].conversationId])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    
    if (chatViewContrller)
    {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [self.mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [self.mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
    
    [self.mainVC showHint:[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"delete", @"delete"), aUsername]];
   
    [_contactViewVC reloadDataSource];
}

- (void)didReceiveAddedFromUsername:(NSString *)aUsername
{
    [_contactViewVC reloadDataSource];
}

- (void)didReceiveFriendInvitationFromUsername:(NSString *)aUsername
                                       message:(NSString *)aMessage
{
    if (!aUsername) {
        return;
    }
    
    if (!aMessage) {
        aMessage = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ added you as a friend"), aUsername];
    }
    
    NSMutableDictionary *requestDict = [NSMutableDictionary dictionaryWithDictionary:@{@"title":aUsername, @"username":aUsername, @"applyMessage":aMessage, @"requestType":[NSNumber numberWithInteger:HIRequestTypeFriend]}];
  
    [[FriendRequestViewController shareController] addNewRequest:requestDict];
   
    if (self.mainVC) {
                
#if !TARGET_IPHONE_SIMULATOR
        [self.mainVC playSoundAndVibration];
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            UILocalNotification *notification = [[UILocalNotification alloc] init];
            notification.fireDate = [NSDate date];
            notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"friend.somebodyAddWithName", @"%@ added you as a friend"), aUsername];
            notification.alertAction = NSLocalizedString(@"open", @"Open");
            notification.timeZone = [NSTimeZone defaultTimeZone];
        }
#endif
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotification_didReceiveRequest object:requestDict];
}

#pragma mark - EMChatroomManagerDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{

}


#pragma mark - EMCallManagerDelegate

#if DEMO_CALL == 1

- (void)didReceiveCallIncoming:(EMCallSession *)aSession
{
    if(self.callSession && self.callSession.status != EMCallSessionStatusDisconnected){
        [[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonBusy];
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonFailed];
    }
    
    self.callSession = aSession;
    
    if(self.callSession){
        
        [self startCallTimer];
        
        self.callController = [[CallViewController alloc] initWithSession:self.callSession isCaller:NO status:NSLocalizedString(@"call.established", "Call connection established")];
        self.callController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self.mainVC presentViewController:self.callController animated:NO completion:nil];
    }
}

- (void)didReceiveCallConnected:(EMCallSession *)aSession
{
    if ([aSession.sessionId isEqualToString:self.callSession.sessionId]) {
        self.callController.statusLabel.text = NSLocalizedString(@"call.established", "Establish call");
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
    }
}

- (void)didReceiveCallAccepted:(EMCallSession *)aSession
{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        [[EMClient sharedClient].callManager endCall:aSession.sessionId reason:EMCallEndReasonFailed];
    }
    
    if ([aSession.sessionId isEqualToString:self.callSession.sessionId]) {
        
        [self stopCallTimer];
        
        NSString *connectStr = aSession.connectType == EMCallConnectTypeRelay ? @"Relay connection" : @"Direct connection";
        self.callController.statusLabel.text = [NSString stringWithFormat:@"%@", connectStr];
        
        self.callController.timeLabel.hidden = NO;
        
        [self.callController startTimer];
        
        [self.callController showCallInfo];
        
        self.callController.cancelButton.hidden = NO;
        self.callController.rejectButton.hidden = YES;
        self.callController.answerButton.hidden = YES;
    }
}

- (void)didReceiveCallTerminated:(EMCallSession *)aSession
                          reason:(EMCallEndReason)aReason
                           error:(EMError *)aError
{
    if ([aSession.sessionId isEqualToString:self.callSession.sessionId]) {
        
        [self stopCallTimer];
        
        self.callSession = nil;
        
        [self.callController close];
        self.callController = nil;
        
        if (aReason != EMCallEndReasonHangup) {
            
            NSString *reasonStr = @"";
            
            switch (aReason) {
                case EMCallEndReasonNoResponse:
                    reasonStr = NSLocalizedString(@"call.noResponse", @"NO response");
                    break;
                case EMCallEndReasonDecline:
                    reasonStr = NSLocalizedString(@"call.rejected", @"Reject the call");
                    break;
                case EMCallEndReasonBusy:
                    reasonStr = NSLocalizedString(@"call.inProgress", @"In the call...");
                    break;
                case EMCallEndReasonFailed:
                    reasonStr = NSLocalizedString(@"call.connectFailed", @"Connect failed");
                    break;
                default:
                    break;
            }
            
            if (aError) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:reasonStr delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
            }
        }
    }
}

- (void)didReceiveCallNetworkChanged:(EMCallSession *)aSession status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.sessionId isEqualToString:self.callSession.sessionId]) {
        [self.callController setNetwork:aStatus];
    }
}

#endif

#pragma mark - public 

#if DEMO_CALL == 1

- (void)makeCall:(NSNotification*)notify
{
    if (notify.object) {
        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] isVideo:[[notify.object objectForKey:@"type"] boolValue]];
    }
}

- (void)startCallTimer
{
    _callTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_cancelCall) userInfo:nil repeats:NO];
}

- (void)stopCallTimer
{
    if (_callTimer == nil) {
        return;
    }
    
    [_callTimer invalidate];
    _callTimer = nil;
}

- (void)_cancelCall
{
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)makeCallWithUsername:(NSString *)aUsername
                     isVideo:(BOOL)aIsVideo
{
    if ([aUsername length] == 0) {
        return;
    }
    
    if (aIsVideo) {
        self.callSession = [[EMClient sharedClient].callManager makeVideoCall:aUsername error:nil];
    }
    else {
        self.callSession = [[EMClient sharedClient].callManager makeVoiceCall:aUsername error:nil];
    }
    
    if (self.callSession) {
        
        [self startCallTimer];
        
        self.callController = [[CallViewController alloc] initWithSession:self.callSession isCaller:YES status:NSLocalizedString(@"call.connecting", @"Connecting...")];

        [self.mainVC presentViewController:self.callController animated:NO completion:nil];
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.initFailed", @"Failed to establish the call") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    [self stopCallTimer];
    
    if (self.callSession) {
        [[EMClient sharedClient].callManager endCall:self.callSession.sessionId reason:aReason];
    }
    
    self.callSession = nil;
    [self.callController close];
    self.callController = nil;
}

- (void)answerCall
{
    if (self.callSession) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:self.callSession.sessionId];
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error.code == EMErrorNetworkUnavailable) {
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                        [alertView show];
                    }
                    else {
                        [self hangupCallWithReason:EMCallEndReasonFailed];
                    }
                });
            }
        });
    }
}

#endif

#pragma mark - private
- (BOOL)_needShowNotification:(NSString *)fromChatter
{
    BOOL ret = YES;
    NSArray *igGroupIds = [[EMClient sharedClient].groupManager getAllIgnoredGroupIds];
    for (NSString *str in igGroupIds) {
        if ([str isEqualToString:fromChatter]) {
            ret = NO;
            break;
        }
    }
    return ret;
}

- (ChatViewController*)_getCurrentChatView
{
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.mainVC.navigationController.viewControllers];
    ChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers)
    {
        if ([viewController isKindOfClass:[ChatViewController class]])
        {
            chatViewContrller = viewController;
            break;
        }
    }
    return chatViewContrller;
}

- (void)login
{
    // Update to latest Hyphenate SDK
    [[EMClient sharedClient] dataMigrationTo3];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_login object:nil];
}

- (void)logout
{
    self.mainVC = nil;
    self.conversationListVC = nil;
    self.chatVC = nil;
    self.contactViewVC = nil;
    
    [[EMClient sharedClient] asyncLogout:NO success:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_logout object:nil];
        });
    } failure:^(EMError *aError) {
        NSLog(@"Error!!! Failed to logout properly");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotification_logout object:nil];
        });
    }];
    
#if DEMO_CALL == 1
    [self hangupCallWithReason:EMCallEndReasonFailed];
#endif
}


@end
