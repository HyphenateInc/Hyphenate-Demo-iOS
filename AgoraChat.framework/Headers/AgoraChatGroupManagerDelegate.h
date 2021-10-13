/*!
 *  \~chinese
 *  @header AgoraChatGroupManagerDelegate.h
 *  @abstract 群组相关的管理协议类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatGroupManagerDelegate.h
 *  @abstract This protocol defined the callbacks of group
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

/*!
 *  \~chinese 
 *  离开群组原因枚举类型
 *
 *  \~english
 *  The reason of user leaving the group type
 */
typedef enum{
    AgoraChatGroupLeaveReasonBeRemoved = 0,    /*! \~chinese 被移除类型  \~english Removed by owner type*/
    AgoraChatGroupLeaveReasonUserLeave,        /*! \~chinese 自己主动离开类型  \~english User leave the group type*/
    AgoraChatGroupLeaveReasonDestroyed,        /*! \~chinese 群组销毁类型  \~english Group has been destroyed type*/
}AgoraChatGroupLeaveReason;

@class AgoraChatGroup;
@class AgoraChatGroupSharedFile;

/*!
 *  \~chinese
 *  群组相关的管理协议类
 *
 *  \~english
 *  Delegate
 */
@protocol AgoraChatGroupManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  用户A邀请用户B入群,用户B接收到该回调
 *
 *  @param aGroupId    群组ID
 *  @param aInviter    邀请者
 *  @param aMessage    邀请信息
 *
 *  \~english
 *  Delegate method will be invoked when receiving a group invitation
 *
 *  After user A invites user B into the group, user B will receive this callback
 *
 *  @param aGroupId    The group ID
 *  @param aInviter    Inviter
 *  @param aMessage    Invitation message
 */
- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage;

/*!
 *  \~chinese
 *  用户B同意用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组实例
 *  @param aInvitee  被邀请者
 *
 *  \~english
 *  Delegate method will be invoked when the group invitation is accepted
 *
 *  After user B accepted user A‘s group invitation, user A will receive this callback
 *
 *  @param aGroup    User joined group
 *  @param aInvitee  Invitee
 */
- (void)groupInvitationDidAccept:(AgoraChatGroup *)aGroup
                         invitee:(NSString *)aInvitee;

/*!
 *  \~chinese
 *  用户B拒绝用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组
 *  @param aInvitee  被邀请者
 *  @param aReason   拒绝理由
 *
 *  \~english
 *  Delegate method will be invoked when the group invitation is declined.
 *
 *  After user B declined user A's group invitation, user A will receive the callback
 *
 *  @param aGroup    Group instance
 *  @param aInvitee  Invitee
 *  @param aReason   Decline reason
 */
- (void)groupInvitationDidDecline:(AgoraChatGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason;

/*!
 *  \~chinese
 *  SDK自动同意了用户A的加B入群邀请后，用户B接收到该回调，需要设置AgoraChatOptions的isAutoAcceptGroupInvitation为YES
 *
 *  @param aGroup    群组实例
 *  @param aInviter  邀请者
 *  @param aMessage  邀请消息
 *
 *  \~english
 *  Delegate method will be invoked after SDK automatically accepted the group invitation
 *
 *  User B will receive this callback after SDK automatically accept user A's group invitation, need set AgoraChatOptions's isAutoAcceptGroupInvitation property to YES
 *
 *  @param aGroup    Group instance
 *  @param aInviter  Inviter
 *  @param aMessage  Invite message
 */
- (void)didJoinGroup:(AgoraChatGroup *)aGroup
             inviter:(NSString *)aInviter
             message:(NSString *)aMessage;

/*!
 *  \~chinese
 *  离开群组收到回调
 *
 *  @param aGroup    群组实例
 *  @param aReason   离开原因
 *
 *  \~english
 *  Delegate method will be invoked when user leaves a group
 *
 *  @param aGroup    Group instance
 *  @param aReason   Leave reason
 */
- (void)didLeaveGroup:(AgoraChatGroup *)aGroup
               reason:(AgoraChatGroupLeaveReason)aReason;

/*!
 *  \~chinese
 *  群组的群主收到用户的入群申请，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup     群组实例
 *  @param aApplicant 申请者
 *  @param aReason    申请者的附属信息
 *
 *  \~english
 *  Delegate method will be invoked when the group owner receives a group request and group's style is AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup     Group instance
 *  @param aUsername  The user initialized the group join request
 *  @param aReason    Applicant's ancillary information
 */
- (void)joinGroupRequestDidReceive:(AgoraChatGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason;

/*!
 *  \~chinese
 *  群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroupId    群组ID
 *  @param aReason     拒绝理由
 *
 *  \~english
 *  Delegate method will be invoked when the group owner declines a join group request
 *
 *  User A will receive this callback after group's owner declined the group request, group's style is AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroupId    Group id
 *  @param aReason     Decline reason
 */
- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason;

/*!
 *  \~chinese
 *  群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup   通过申请的群组
 *
 *  \~english
 *  Delegate method will be invoked when the group owner approves a join group request
 *
 *  User A will receive this callback after group's owner approve the group request, group's style is AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup   Group instance
 */
- (void)joinGroupRequestDidApprove:(AgoraChatGroup *)aGroup;

/*!
 *  \~chinese
 *  群组列表发生变化
 *
 *  @param aGroupList  群组列表<AgoraChatGroup>
 *
 *  \~english
 *  Group List updated
 *
 *  @param aGroupList  Group NSArray<AgoraChatGroup>
 */
- (void)groupListDidUpdate:(NSArray *)aGroupList;


/*!
 *  \~chinese
 *  有成员被加入禁言列表
 *
 *  @param aGroup           群组实例
 *  @param aMutedMembers    被禁言的成员
 *  @param aMuteExpire      禁言失效时间，当前不可用
 *
 *  \~english
 *  Users are added to the mute list
 *
 *  @param aGroup           Group instance
 *  @param aMutedMembers    Users to be added
 *  @param aMuteExpire      Mute expire, not available at this time
 */
- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire;

/*!
 *  \~chinese
 *  有成员被移出禁言列表
 *
 *  @param aGroup             群组实例
 *  @param aMutedMembers    移出禁言列表的成员
 *
 *  \~english
 *  Users are removed from the mute list
 *
 *  @param aGroup           Group instance
 *  @param aMutedMembers    Users to be removed from mute list
 */
- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers;

/*!
 *  \~chinese
 *  有成员被加入白名单
 *
 *  @param aGroup           群组实例
 *  @param aMembers         被加入白名单的成员
 *
 *  \~english
 *  Users are added to the white list
 *
 *  @param aGroup           Group instance
 *  @param aMembers     Users to be added to whiteList
 */
- (void)groupWhiteListDidUpdate:(AgoraChatGroup *)aGroup
          addedWhiteListMembers:(NSArray *)aMembers;

/*!
 *  \~chinese
 *  有成员被移出白名单
 *
 *  @param aGroup             群组实例
 *  @param aMembers         被移出白名单的成员
 *
 *  \~english
 *  Users are removed from the white list
 *
 *  @param aGroup           Group instance
 *  @param aMembers      Users to be removed from whiteList
 */
- (void)groupWhiteListDidUpdate:(AgoraChatGroup *)aGroup
        removedWhiteListMembers:(NSArray *)aMembers;


/*!
*  \~chinese
*  群组全部禁言状态变化
*
*  @param aGroup           群组实例
*  @param aMuted           是否被全部禁言
*
*  \~english
*  Group members are all muted
*
*  @param aGroup           Group instance
*  @param aMuted           Whether all member be muted
*/
- (void)groupAllMemberMuteChanged:(AgoraChatGroup *)aGroup
                 isAllMemberMuted:(BOOL)aMuted;

/*!
 *  \~chinese
 *  有成员被加入管理员列表
 *
 *  @param aGroup    群组实例
 *  @param aAdmin    加入管理员列表的成员
 *
 *  \~english
 *  User is added to the admin list
 *
 *  @param aGroup    Group instance
 *  @param aAdmin    User to be added to adminList
 */
- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin;

/*!
 *  \~chinese
 *  有成员被移出管理员列表
 *
 *  @param aGroup    群组实例
 *  @param aAdmin    移出管理员列表的成员
 *
 *  \~english
 *  User is removed to the admin list
 *
 *  @param aGroup    Group instance
 *  @param aAdmin    User to be removed from adminList
 */
- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin;

/*!
 *  \~chinese
 *  群组所有者有更新
 *
 *  @param aGroup       群组实例
 *  @param aNewOwner    新群主
 *  @param aOldOwner    旧群主
 *
 *  \~english
 *  Owner is updated
 *
 *  @param aGroup       Group instance
 *  @param aNewOwner    New Owner
 *  @param aOldOwner    Old Owner
 */
- (void)groupOwnerDidUpdate:(AgoraChatGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner;

/*!
 *  \~chinese
 *  有用户加入群组
 *
 *  @param aGroup       加入的群组
 *  @param aUsername    加入者
 *
 *  \~english
 *  Delegate method will be invoked when a user joins a group.
 *
 *  @param aGroup       Joined group
 *  @param aUsername    The user who joined group
 */
- (void)userDidJoinGroup:(AgoraChatGroup *)aGroup
                    user:(NSString *)aUsername;

/*!
 *  \~chinese
 *  有用户离开群组
 *
 *  @param aGroup       离开的群组
 *  @param aUsername    离开者
 *
 *  \~english
 *  Delegate method will be invoked when a user leaves a group.
 *
 *  @param aGroup       Left group
 *  @param aUsername    The user who leaved group
 */
- (void)userDidLeaveGroup:(AgoraChatGroup *)aGroup
                     user:(NSString *)aUsername;

/*!
 *  \~chinese
 *  群公告有更新
 *
 *  @param aGroup           群组实例
 *  @param aAnnouncement    群公告
 *
 *  \~english
 *  Delegate method will be invoked when a user update the announcement from a group.
 *
 *  @param aGroup           Group instance
 *  @param aAnnouncement    Group announcement
 */
- (void)groupAnnouncementDidUpdate:(AgoraChatGroup *)aGroup
                      announcement:(NSString *)aAnnouncement;

/*!
 *  \~chinese
 *  有用户上传群共享文件
 *
 *  @param aGroup       群组实例
 *  @param aSharedFile  共享文件
 *
 *  \~english
 *  Delegate method will be invoked when a user upload share file to a group.
 *
 *  @param aGroup       Group instance
 *  @param aSharedFile  Sharefile
 */
- (void)groupFileListDidUpdate:(AgoraChatGroup *)aGroup
               addedSharedFile:(AgoraChatGroupSharedFile *)aSharedFile;

/*!
 *  \~chinese
 *  有用户删除群共享文件
 *
 *  @param aGroup       群组实例
 *  @param aFileId      共享文件ID
 *
 *  \~english
 *  Delegate method will be invoked when a user remove share file from a group.
 *
 *  @param aGroup       Group instance
 *  @param aFileId     Sharefile ID
 */
- (void)groupFileListDidUpdate:(AgoraChatGroup *)aGroup
             removedSharedFile:(NSString *)aFileId;

#pragma mark - Deprecated methods

/*!
 *  \~chinese
 *  用户A邀请用户B入群,用户B接收到该回调
 *
 *  @param aGroupId    群组ID
 *  @param aInviter    邀请者
 *  @param aMessage    邀请信息
 *
 *  \~english
 *  Delegate method will be invoked when user receives a group invitation
 *
 *  After user A invites user B into the group, user B will receive this callback
 *
 *  @param aGroupId    The group ID
 *  @param aInviter    Inviter
 *  @param aMessage    Invite message
 */
- (void)didReceiveGroupInvitation:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage __deprecated_msg("Use -groupInvitationDidReceive:inviter:message: instead");

/*!
 *  \~chinese
 *  用户B同意用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组实例
 *  @param aInvitee  被邀请者
 *
 *  \~english
 *  Delegate method will be invoked when a group invitation is accepted
 *
 *  After user B accepted user A‘s group invitation, user A will receive this callback
 *
 *  @param aGroup    Group instance
 *  @param aInvitee  Invitee
 */
- (void)didReceiveAcceptedGroupInvitation:(AgoraChatGroup *)aGroup
                                  invitee:(NSString *)aInvitee __deprecated_msg("Use -groupInvitationDidAccept:invitee: instead");

/*!
 *  \~chinese
 *  用户B拒绝用户A的入群邀请后，用户A接收到该回调
 *
 *  @param aGroup    群组实例
 *  @param aInvitee  被邀请者
 *  @param aReason   拒绝理由
 *
 *  \~english
 *  Delegate method will be invoked when a group invitation is declined
 *
 *  After user B declined user A's group invitation, user A will receive the callback
 *
 *  @param aGroup    Group instance
 *  @param aInvitee  Invitee
 *  @param aReason   Decline reason
 */
- (void)didReceiveDeclinedGroupInvitation:(AgoraChatGroup *)aGroup
                                  invitee:(NSString *)aInvitee
                                   reason:(NSString *)aReason __deprecated_msg("Use -groupInvitationDidDecline:invitee:reason: instead");

/*!
 *  \~chinese
 *  SDK自动同意了用户A的加B入群邀请后，用户B接收到该回调，需要设置AgoraChatOptions的isAutoAcceptGroupInvitation为YES
 *
 *  @param aGroup    群组实例
 *  @param aInviter  邀请者
 *  @param aMessage  邀请消息
 *
 *  \~english
 *  User B will receive this callback after SDK automatically accept user A's group invitation.
 *  Set AgoraChatOptions's isAutoAcceptGroupInvitation property to YES for this delegate method
 *
 *  @param aGroup    Group instance
 *  @param aInviter  Inviter
 *  @param aMessage  Invite message
 */
- (void)didJoinedGroup:(AgoraChatGroup *)aGroup
               inviter:(NSString *)aInviter
               message:(NSString *)aMessage __deprecated_msg("Use -didJoinGroup:inviter:message: instead");

/*!
 *  \~chinese
 *  离开群组收到的回调
 *
 *  @param aGroup    群组实例
 *  @param aReason   离开原因
 *
 *  \~english
 *  Callback of leave group
 *
 *  @param aGroup    Group instance
 *  @param aReason   Leave reason
 */
- (void)didReceiveLeavedGroup:(AgoraChatGroup *)aGroup
                       reason:(AgoraChatGroupLeaveReason)aReason __deprecated_msg("Use -didLeaveGroup:reason: instead");

/*!
 *  \~chinese
 *  群组的群主收到用户的入群申请，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup     群组实例
 *  @param aApplicant 申请者
 *  @param aReason    申请者的附属信息
 *
 *  \~english
 *  Group's owner receive user's applicaton of joining group, group's style is AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup     Group
 *  @param aApplicant The applicant
 *  @param aReason   Applicant's ancillary information
 */
- (void)didReceiveJoinGroupApplication:(AgoraChatGroup *)aGroup
                             applicant:(NSString *)aApplicant
                                reason:(NSString *)aReason __deprecated_msg("Use -joinGroupRequestDidReceive:user:reason: instead");

/*!
 *  \~chinese
 *  群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroupId    群组ID
 *  @param aReason     拒绝理由
 *
 *  \~english
 *  User A will receive this callback after group's owner declined the join group request
 *
 *  @param aGroupId    Group id
 *  @param aReason     Decline reason
 */
- (void)didReceiveDeclinedJoinGroup:(NSString *)aGroupId
                             reason:(NSString *)aReason __deprecated_msg("Use -joinGroupRequestDidDecline:reason: instead");

/*!
 *  \~chinese
 *  群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup   群组实例
 *
 *  \~english
 *  User A will receive this callback after group's owner accepted it's application, group's style is AgoraChatGroupStylePublicJoinNeedApproval
 *
 *  @param aGroup   Group instance
 */
- (void)didReceiveAcceptedJoinGroup:(AgoraChatGroup *)aGroup __deprecated_msg("Use -joinGroupRequestDidApprove: instead");

/*!
 *  \~chinese
 *  群组列表发生变化
 *
 *  @param aGroupList  群组列表<AgoraChatGroup>
 *
 *  \~english
 *  Group List changed
 *
 *  @param aGroupList  Group list<AgoraChatGroup>
 */
- (void)didUpdateGroupList:(NSArray *)aGroupList __deprecated_msg("Use -groupListDidUpdate: instead");

@end
