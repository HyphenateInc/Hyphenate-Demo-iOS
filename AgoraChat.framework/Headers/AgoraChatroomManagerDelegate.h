/*!
 *  \~chinese 
 *  @header AgoraChatroomManagerDelegate.h
 *  @abstract 此协议定义了聊天室相关的回调
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatroomManagerDelegate.h
 *  @abstract This protocol defined the callbacks of chatroom
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 *  被踢出聊天室的原因
 *
 *  \~english
 *  The casuse for kicking a user out of a chatroom
 */
typedef enum{
    AgoraChatroomBeKickedReasonBeRemoved = 0,  /*! \~chinese 被管理员移出聊天室 \~english Removed by chatroom owner  */
    AgoraChatroomBeKickedReasonDestroyed,      /*! \~chinese 聊天室被销毁 \~english Chatroom has been destroyed */
    AgoraChatroomBeKickedReasonOffline,      /*! \~chinese 当前账号离线 \~english Account offline */
}AgoraChatroomBeKickedReason;

@class AgoraChatroom;

/*!
 *  \~chinese
 *  聊天室相关的回调
 *
 *  \~english
 *  Callbacks of chatroom
 */
@protocol AgoraChatroomManagerDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  有用户加入聊天室
 *
 *  @param aChatroom    加入的聊天室
 *  @param aUsername    加入者
 *
 *  \~english
 *  Delegate method will be invoked when a user joins a chatroom.
 *
 *  @param aChatroom    Joined chatroom
 *  @param aUsername    The user who joined chatroom
 */
- (void)userDidJoinChatroom:(AgoraChatroom *)aChatroom
                       user:(NSString *)aUsername;

/*!
 *  \~chinese
 *  有用户离开聊天室
 *
 *  @param aChatroom    离开的聊天室
 *  @param aUsername    离开者
 *
 *  \~english
 *  Delegate method will be invoked when a user leaves a chatroom.
 *
 *  @param aChatroom    Left chatroom
 *  @param aUsername    The user who leaved chatroom
 */
- (void)userDidLeaveChatroom:(AgoraChatroom *)aChatroom
                        user:(NSString *)aUsername;

/*!
 *  \~chinese
 *  被踢出聊天室
 *
 *  @param aChatroom    被踢出的聊天室
 *  @param aReason      被踢出聊天室的原因
 *
 *  \~english
 *  Delegate method will be invoked when a user is dismissed from a chat room
 *
 *  @param aChatroom    aChatroom
 *  @param aReason      The reason of dismissing user from the chat room
 */
- (void)didDismissFromChatroom:(AgoraChatroom *)aChatroom
                        reason:(AgoraChatroomBeKickedReason)aReason;

/*!
 *  \~chinese
 *  有成员被加入禁言列表
 *
 *  @param aChatroom        聊天室
 *  @param aMutedMembers    被禁言的成员
 *  @param aMuteExpire      禁言失效时间，暂时不可用
 *
 *  \~english
 *  Users are added to the mute list
 *
 *  @param aChatroom        Chatroom
 *  @param aMutedMembers    Users to be added
 *  @param aMuteExpire      Mute expire, not available at this time
 */
- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire;

/*!
 *  \~chinese
 *  有成员被移出禁言列表
 *
 *  @param aChatroom        聊天室
 *  @param aMutedMembers    移出禁言列表的成员
 *
 *  \~english
 *  Users are removed from the mute list
 *
 *  @param aChatroom        Chatroom
 *  @param aMutedMembers    Users to be removed
 */
- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes;

/*!
 *  \~chinese
 *  有成员被加入白名单
 *
 *  @param aChatroom        聊天室
 *  @param aMembers         被加入白名单的成员
 *
 *  \~english
 *  Users are added to the white list
 *
 *  @param aChatroom        Chatroom
 *  @param aMutedMembers    Users to be added
 */
- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom
             addedWhiteListMembers:(NSArray *)aMembers;

/*!
 *  \~chinese
 *  有成员被移出白名单
 *
 *  @param aChatroom        聊天室
 *  @param aMembers         被移出白名单的成员
 *
 *  \~english
 *  Users are removed from the white list
 *
 *  @param aChatroom        Chatroom
 *  @param aMutedMembers    Users to be removed
 */
- (void)chatroomWhiteListDidUpdate:(AgoraChatroom *)aChatroom
           removedWhiteListMembers:(NSArray *)aMembers;



/*!
*  \~chinese
*  聊天室全部禁言状态变化
*
*  @param aChatroom        聊天室
*  @param aMuted           是否被全部禁言
*
*  \~english
*  Group members are all muted
*
*  @param aChatroom        Chatroom
*  @param aMuted           All member muted
*/
- (void)chatroomAllMemberMuteChanged:(AgoraChatroom *)aChatroom
                    isAllMemberMuted:(BOOL)aMuted;

/*!
 *  \~chinese
 *  有成员被加入管理员列表
 *
 *  @param aChatroom    聊天室
 *  @param aAdmin       加入管理员列表的成员
 *
 *  \~english
 *  User is added to the admin list
 *
 *  @param aChatroom    Chatroom
 *  @param aAdmin       User to be added
 */
- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin;

/*!
 *  \~chinese
 *  有成员被移出管理员列表
 *
 *  @param aChatroom    聊天室
 *  @param aAdmin       移出管理员列表的成员
 *
 *  \~english
 *  User is removed to the admin list
 *
 *  @param aChatroom    Chatroom
 *  @param aAdmin       User to be removed
 */
- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin;

/*!
 *  \~chinese
 *  聊天室创建者有更新
 *
 *  @param aChatroom    聊天室
 *  @param aNewOwner    新群主
 *  @param aOldOwner    旧群主
 *
 *  \~english
 *  Owner is updated
 *
 *  @param aChatroom    Chatroom
 *  @param aNewOwner    New Owner
 *  @param aOldOwner    Old Owner
 */
- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner;

/*!
 *  \~chinese
 *  聊天室公告有更新
 *
 *  @param aChatroom        聊天室
 *  @param aAnnouncement    公告
 *
 *  \~english
 *  Announcement is updated
 *
 *  @param aChatroom        Chatroom
 *  @param aAnnouncement    Announcement
 */
- (void)chatroomAnnouncementDidUpdate:(AgoraChatroom *)aChatroom
                         announcement:(NSString *)aAnnouncement;

#pragma mark - Deprecated methods

/*!
 *  \~chinese
 *  有用户加入聊天室
 *
 *  @param aChatroom    加入的聊天室
 *  @param aUsername    加入者
 *
 *  \~english
 *  Delegate method will be invoked when a user joins a chat room
 *
 *  @param aChatroom    Joined chatroom
 *  @param aUsername    The user who joined chatroom
 */
- (void)didReceiveUserJoinedChatroom:(AgoraChatroom *)aChatroom
                            username:(NSString *)aUsername __deprecated_msg("Use -userDidJoinChatroom:user:");

/*!
 *  \~chinese
 *  有用户离开聊天室
 *
 *  @param aChatroom    离开的聊天室
 *  @param aUsername    离开者
 *
 *  \~english
 *  A user leaved chatroom
 *
 *  @param aChatroom    Leaved chatroom
 *  @param aUsername    The user who leaved chatroom
 */
- (void)didReceiveUserLeavedChatroom:(AgoraChatroom *)aChatroom
                            username:(NSString *)aUsername __deprecated_msg("Use -userDidLeaveChatroom:reason:");

/*!
 *  \~chinese
 *  被踢出聊天室
 *
 *  @param aChatroom    被踢出的聊天室
 *  @param aReason      被踢出聊天室的原因
 *
 *  \~english
 *  User was kicked out from a chatroom
 *
 *  @param aChatroom    The chatroom which user was kicked out from
 *  @param aReason      The reason of user was kicked out
 */
- (void)didReceiveKickedFromChatroom:(AgoraChatroom *)aChatroom
                              reason:(AgoraChatroomBeKickedReason)aReason __deprecated_msg("Use -didDismissFromChatroom:reason:");
@end
