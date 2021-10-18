/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatDemoHelper.h"
#import "AgoraApplyManager.h"
#import <UserNotifications/UserNotifications.h>
#import "AgoraGroupsViewController.h"
#import "AgoraChatViewController.h"
#import "AgoraGroupInfoViewController.h"
#import "AgoraNotificationNames.h"

static AgoraChatDemoHelper *helper = nil;

@implementation AgoraChatDemoHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[AgoraChatDemoHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[AgoraChatClient sharedClient] removeDelegate:self];
    [[AgoraChatClient sharedClient].chatManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
    [[AgoraChatClient sharedClient].contactManager removeDelegate:self];
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
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
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
}


#pragma mark - public

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[AgoraApplyManager defaultManager] unHandleApplysCount];
    if (_contactsVC) {
        if (unreadCount > 0) {
            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}

#pragma mark - AgoraChatClientDelegate

- (void)autoLoginDidCompleteWithError:(AgoraChatError *)aError {
    if (!aError) {
        [_contactsVC reloadGroupNotifications];
        [_contactsVC reloadContactRequests];
        [_contactsVC reloadContacts];
    }
}

#pragma mark - AgoraChatManagerDelegate

- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    if (_mainVC) {
        [_mainVC setupUnreadMessageCount];
    }
    if (_chatsVC) {
        [_chatsVC tableViewDidTriggerHeaderRefresh];
    }
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    if (_mainVC) {
        [_mainVC setupUnreadMessageCount];
    }
    if (_chatsVC) {
        [_chatsVC tableViewDidTriggerHeaderRefresh];
    }
}


#pragma mark - AgoraContactManagerDelegate

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"message.friendapply.agree", @"%@ agreed to add friends to apply"), aUsername];
    [self showAlertWithMessage:msgstr];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"message.friendapply.refuse", @"%@ refuse to add friends to apply"), aUsername];
    [self showAlertWithMessage:msgstr];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSString *msg = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common.delete", @"Delete"), aUsername];
    [self showAlertWithMessage:msg];
    if (_contactsVC) {
        [_contactsVC reloadContacts];
    }
}

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    if (_contactsVC) {
        [_contactsVC reloadContacts];
    }
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
    if (!aUsername) {
        return;
    }
    
    if (!aMessage) {
        aMessage = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
    }
    
    if (![[AgoraApplyManager defaultManager] isExistingRequest:aUsername
                                                    groupId:nil
                                                 applyStyle:AgoraApplyStyle_contact])
    {
        AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
        model.applyHyphenateId = aUsername;
        model.applyNickName = aUsername;
        model.reason = aMessage;
        model.style = AgoraApplyStyle_contact;
        [[AgoraApplyManager defaultManager] addApplyRequest:model];
    }
    
    if (self.mainVC && helper) {
        [helper setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            if (NSClassFromString(@"UNUserNotificationCenter")) {
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.sound = [UNNotificationSound defaultSound];
                content.body =[NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate] * 1000] stringValue] content:content trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date];
                notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
                notification.alertAction = NSLocalizedString(@"common.open", @"Open");
                notification.timeZone = [NSTimeZone defaultTimeZone];
            }
        }
#endif
    }
    [_contactsVC reloadContactRequests];
}

#pragma mark - AgoraChatGroupManagerDelegate

- (void)didLeaveGroup:(AgoraChatGroup *)aGroup
               reason:(AgoraChatGroupLeaveReason)aReason {
    NSString *msgstr = nil;
    if (aReason == AgoraChatGroupLeaveReasonBeRemoved) {
        msgstr = [NSString stringWithFormat:@"Your are kicked out from group: %@ [%@]", aGroup.subject, aGroup.groupId];
    } else if (aReason == AgoraChatGroupLeaveReasonDestroyed) {
        msgstr = [NSString stringWithFormat:@"Group: %@ [%@] is destroyed", aGroup.subject, aGroup.groupId];
    }
    
    if (msgstr.length > 0) {
        [self showAlertWithMessage:msgstr];
    }
    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:_mainVC.navigationController.viewControllers];
    AgoraChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers) {
        if ([viewController isKindOfClass:[AgoraChatViewController class]] && [aGroup.groupId isEqualToString:[(AgoraChatViewController*)viewController conversationId]]) {
            chatViewContrller = viewController;
            break;
        }
    }
    
    if (chatViewContrller) {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [_mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [_mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
}

- (void)joinGroupRequestDidReceive:(AgoraChatGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {
    if (!aGroup || !aUsername) {
        return;
    }
    
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), aUsername, aGroup.subject];
    }
    else{
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), aUsername, aGroup.subject, aReason];
    }
    
    if (![[AgoraApplyManager defaultManager] isExistingRequest:aUsername
                                                    groupId:aGroup.groupId
                                                 applyStyle:AgoraApplyStyle_joinGroup])
    {
        AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
        model.applyHyphenateId = aUsername;
        model.applyNickName = aUsername;
        model.groupId = aGroup.groupId;
        model.groupSubject = aGroup.subject;
        model.groupMemberCount = aGroup.occupantsCount;
        model.reason = aReason;
        model.style = AgoraApplyStyle_joinGroup;
        [[AgoraApplyManager defaultManager] addApplyRequest:model];
    }
    
    if (self.mainVC && helper) {
        [helper setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
#endif
    }
    
    if (_contactsVC) {
        [_contactsVC reloadGroupNotifications];
    }
}

- (void)didJoinGroup:(AgoraChatGroup *)aGroup
             inviter:(NSString *)aInviter
             message:(NSString *)aMessage
{
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"group.invite", @"%@ invite you to group: %@ [%@]"), aInviter, aGroup.subject, aGroup.groupId];
    [self showAlertWithMessage:msgstr];
    NSArray *vcArray = _mainVC.navigationController.viewControllers;
    AgoraGroupsViewController *groupsVc = nil;
    for (UIViewController *vc in vcArray) {
        if ([vc isKindOfClass:[AgoraGroupsViewController class]]) {
            groupsVc = (AgoraGroupsViewController *)vc;
            break;
        }
    }
    if (groupsVc) {
        [groupsVc loadGroupsFromCache];
    }
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
    [self showAlertWithMessage:aReason];
}

- (void)joinGroupRequestDidApprove:(AgoraChatGroup *)aGroup
{
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed to join the group of \'%@\'"), aGroup.subject];
    [self showAlertWithMessage:msgstr];
}

- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage
{
    if (!aGroupId || !aInviter) {
        return;
    }

    [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:aGroupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        if (![[AgoraApplyManager defaultManager] isExistingRequest:aInviter
                                                        groupId:aGroupId
                                                     applyStyle:AgoraApplyStyle_groupInvitation])
        {
            AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
            model.groupId = aGroupId;
            model.groupSubject = aGroup.subject;
            model.applyHyphenateId = aInviter;
            model.applyNickName = aInviter;
            model.reason = aMessage;
            model.style = AgoraApplyStyle_groupInvitation;
            [[AgoraApplyManager defaultManager] addApplyRequest:model];
        }
        
        if (self.mainVC && helper) {
            [helper setupUntreatedApplyCount];
        }
        
        if (self.contactsVC) {
            [self.contactsVC reloadGroupNotifications];
        }
    }];
}

- (void)groupInvitationDidDecline:(AgoraChatGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.declineInvitation", @"%@ decline to join the group [%@]"), aInvitee, aGroup.subject];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupInvitationDidAccept:(AgoraChatGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.acceptInvitation", @"%@ has agreed to join the group [%@]"), aInvitee, aGroup.subject];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSMutableString *msg = [NSMutableString stringWithString:NSLocalizedString(@"group.mute.added", @"Added to mute list:")];
    for (NSString *username in aMutedMembers) {
        [msg appendFormat:@" %@", username];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSMutableString *msg = [NSMutableString stringWithString:NSLocalizedString(@"group.mute.removed", @"Removed from mute list:")];
    for (NSString *username in aMutedMembers) {
        [msg appendFormat:@" %@", username];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.memberToAdmin", @"%@ is upgraded to administrator"), aAdmin];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.AdminToMember", @"%@ is downgraded to members"), aAdmin];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupOwnerDidUpdate:(AgoraChatGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.owner.updated", @"The group owner changed from %@ to %@"), aOldOwner, aNewOwner];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)userDidJoinGroup:(AgoraChatGroup *)aGroup
                    user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.member.joined", @"%@ has joined to the group [%@]"), aUsername, aGroup.subject];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)userDidLeaveGroup:(AgoraChatGroup *)aGroup
                     user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"group.member.leaved", @"%@ has leaved from the group [%@]"), aUsername, aGroup.subject];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)groupAnnouncementDidUpdate:(AgoraChatGroup *)aGroup announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *msg = aAnnouncement == nil ? [NSString stringWithFormat:NSLocalizedString(@"group.clearAnnouncement", @"Group:%@ Announcement is clear"), aGroup.subject] : [NSString stringWithFormat:NSLocalizedString(@"group.updateAnnouncement", @"Group:%@ Announcement: %@"), aGroup.subject, aAnnouncement];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"group.announcementUpdate", @"Group Announcement Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - AgoraChatroomManagerDelegate

- (void)didReceiveKickedFromChatroom:(AgoraChatroom *)aChatroom
                              reason:(AgoraChatroomBeKickedReason)aReason
{
    NSString *roomId = nil;
    if (aReason == AgoraChatroomBeKickedReasonDestroyed) {
        roomId = aChatroom.chatroomId;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_END_CHAT object:roomId];
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSMutableString *msg = [NSMutableString stringWithString:NSLocalizedString(@"chatroom.mute.added", @"Added to mute list:")];
    for (NSString *username in aMutes) {
        [msg appendFormat:@" %@", username];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSMutableString *msg = [NSMutableString stringWithString:NSLocalizedString(@"chatroom.mute.removed", @"Removed from mute list:")];
    for (NSString *username in aMutes) {
        [msg appendFormat:@" %@", username];
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"chatroom.memberToAdmin", @"%@ is upgraded to administrator"), aAdmin];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"chatroom.AdminToMember", @"%@ is downgraded to members"), aAdmin];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"chatroom.owner.updated", @"The chatroom owner changed from %@ to %@"), aOldOwner, aNewOwner];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)chatroomAnnouncementDidUpdate:(AgoraChatroom *)aChatroom announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *msg = aAnnouncement == nil ? [NSString stringWithFormat:NSLocalizedString(@"chatroom.clearAnnouncement", @"Chatroom:%@ Announcement is clear"), aChatroom.subject] : [NSString stringWithFormat:NSLocalizedString(@"chatroom.updateAnnouncement", Chatroom:%@ Announcement: %@), aChatroom.subject, aAnnouncement];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"chatroom.announcementUpdate", @"Chatroom Announcement Update") message:msg delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"Ok") otherButtonTitles:nil, nil];
    [alertView show];
}


@end
