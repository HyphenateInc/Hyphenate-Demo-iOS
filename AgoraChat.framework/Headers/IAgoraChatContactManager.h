/*!
 *  \~chinese
 *  @header IAgoraChatContactManager.h
 *  @abstract 联系人相关操作协议类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IAgoraChatContactManager.h
 *  @abstract The protocol defines the operations of contact
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "AgoraChatCommonDefs.h"
#import "AgoraChatContactManagerDelegate.h"

@class AgoraChatError;

/*!
 *  \~chinese
 *  好友相关操作
 *
 *  \~english
 *  Contact Management
 */
@protocol IAgoraChatContactManager <NSObject>

@required

#pragma mark - Delegate

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Delegate to be add
 *  @param aQueue     (optional) The queue of calling delegate methods. Pass in nil to run on main thread.
 */
- (void)addDelegate:(id<AgoraChatContactManagerDelegate>)aDelegate
      delegateQueue:(dispatch_queue_t)aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 *  @param aDelegate  Delegate
 */
- (void)removeDelegate:(id)aDelegate;


#pragma mark - Contact Operations

/*!
 *  \~chinese
 *  获取本地存储的所有好友
 *
 *  @result 好友列表<NSString>
 *
 *  \~english
 *  Get all contacts from local database
 *
 *  @result Contact NSArray<NSString>
 */
- (NSArray *)getContacts;

/*!
 *  \~chinese
 *  从服务器获取所有的好友
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get all contacts from the server
 *
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)getContactsFromServerWithCompletion:(void (^)(NSArray *aList, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从服务器获取所有的好友
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param pError 错误信息
 *
 *  @result 好友列表<NSString>
 *
 *  \~english
 *  Get all the contacts from the server
 *
 *  Synchronization method will block the current thread
 *
 *  @param pError Error
 *
 *  @result Contact NSArray<NSString>
 */
- (NSArray *)getContactsFromServerWithError:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  添加好友
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername  要添加的用户
 *  @param aMessage   邀请信息
 *
 *  @result 错误信息
 *
 *  \~english
 *  Add a contact with invitation message
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername  The user to add
 *  @param aMessage   (optional) Invitation message. Pass in nil to ignore.
 *
 *  @result Error
 */
- (AgoraChatError *)addContact:(NSString *)aUsername
                message:(NSString *)aMessage;

/*!
 *  \~chinese
 *  添加好友
 *
 *  @param aUsername        要添加的用户
 *  @param aMessage         邀请信息
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Add a contact
 *
 *  @param aUsername        The user to be added
 *  @param aMessage         Friend request message
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)addContact:(NSString *)aUsername
           message:(NSString *)aMessage
        completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  删除好友
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 要删除的好友
 *  @param aIsDeleteConversation 是否删除会话
 *
 *  @result 错误信息
 *
 *  \~english
 *  Delete a contact
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername                The user to delete
 *  @param aIsDeleteConversation    whether to keep the assoicated conversation and messages
 *
 *  @result Error
 */
- (AgoraChatError *)deleteContact:(NSString *)aUsername
      isDeleteConversation:(BOOL)aIsDeleteConversation;

/*!
 *  \~chinese
 *  删除好友
 *
 *  @param aUsername                要删除的好友
 *  @param aIsDeleteConversation    是否删除会话
 *  @param aCompletionBlock         完成的回调
 *
 *  \~english
 *  Delete a contact
 *
 *  @param aUsername                The user to be deleted
 *  @param aIsDeleteConversation    Delete the conversation or not
 *  @param aCompletionBlock         The callback block of completion
 *
 */
- (void)deleteContact:(NSString *)aUsername
 isDeleteConversation:(BOOL)aIsDeleteConversation
           completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  同意加好友的申请
 *
 *  @param aUsername        申请者
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Apporove a friend request
 *
 *  @param aUsername        User who initiated the friend request
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)approveFriendRequestFromUser:(NSString *)aUsername
                          completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  拒绝加好友的申请
 *
 *  @param aUsername        申请者
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Decline a friend request
 *
 *  @param aUsername        User who initiated the friend request
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)declineFriendRequestFromUser:(NSString *)aUsername
                          completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;


#pragma mark - Blacklist Operations

/*!
 *  \~chinese
 *  从本地获取黑名单列表
 *
 *  @result 黑名单列表<NSString>
 *
 *  \~english
 *  Get the blacklist of blocked users from local database
 *
 *  @result NSArray<NSString>  blacklist usernames
 */
- (NSArray *)getBlackList;

/*!
 *  \~chinese
 *  从服务器获取黑名单列表
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get the blacklist from the server
 *
 *  @param aCompletionBlock The callback block of completion
 *
 *  @result aList<NSString> blacklist usernames
 */
- (void)getBlackListFromServerWithCompletion:(void (^)(NSArray *aList, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从服务器获取黑名单列表
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param pError 错误信息
 *
 *  @result 黑名单列表<NSString>
 *
 *  \~english
 *  Get the blacklist from the server
 *
 *  Synchronization method will block the current thread
 *
 *  @param pError   Error
 *
 *  @result NSArray<NSString>
 */
- (NSArray *)getBlackListFromServerWithError:(AgoraChatError **)pError;


/*!
 *  \~chinese
 *  将用户加入黑名单
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 要加入黑名单的用户
 *
 *  @result 错误信息
 *
 *  \~english
 *  Add a user to blacklist
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername Block user
 *
 *  @result Error
 */
- (AgoraChatError *)addUserToBlackList:(NSString *)aUsername;


/*!
 *  \~chinese
 *  将用户加入黑名单
 *
 *  @param aUsername        要加入黑名单的用户
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Add a user to blacklist
 *
 *  @param aUsername        Block user
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)addUserToBlackList:(NSString *)aUsername
                completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  将用户移出黑名单
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 要移出黑名单的用户
 *
 *  @result 错误信息
 *
 *  \~english
 *  Remove user out of blacklist
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername Unblock user
 *
 *  @result Error
 */
- (AgoraChatError *)removeUserFromBlackList:(NSString *)aUsername;

/*!
 *  \~chinese
 *  将用户移出黑名单
 *
 *  @param aUsername        要移出黑名单的用户
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Remove a user from blacklist
 *
 *  @param aUsername        Unblock user
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)removeUserFromBlackList:(NSString *)aUsername
                     completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  同意加好友的申请
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 申请者
 *
 *  @result 错误信息
 *
 *  \~english
 *  Accept a friend request
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername User who initiated the friend request
 *
 *  @result Error
 */
- (AgoraChatError *)acceptInvitationForUsername:(NSString *)aUsername;

/*!
 *  \~chinese
 *  拒绝加好友的申请
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 申请者
 *
 *  @result 错误信息
 *
 *  \~english
 *  Decline a friend request
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername User who initiated the friend request
 *
 *  @result Error
 *
 * Please use the new method 
 * - (void)declineFriendRequestFromUser:(NSString *)aUsername
 *                           completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;
 */
- (AgoraChatError *)declineInvitationForUsername:(NSString *)aUsername;

#pragma mark - Other platform

/*!
 *  \~chinese
 *  获取当前账号在其他平台(Windows或者Web)登录的id列表
 *  id使用方法类似于好友username
 *
 *  @param pError   错误信息
 *
 *  @result     id列表
 *
 *  \~english
 *  Get the id list of the current account on another platform (Windows or Web)
 *  Id usage is similar to friend username
 *
 *  @param pError   Error
 *
 *  @result NSArray<NSString>
 *
 */
- (NSArray *)getSelfIdsOnOtherPlatformWithError:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  获取当前账号在其他平台(Windows或者Web)登录的id列表
 *  id使用方法类似于好友username
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get the id list of the current account on another platform (Windows or Web)
 *  Id usage is similar to friend username
 *
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)getSelfIdsOnOtherPlatformWithCompletion:(void (^)(NSArray *aList, AgoraChatError *aError))aCompletionBlock;


#pragma mark - EM_DEPRECATED_IOS
/*!
 *  \~chinese
 *  将用户加入黑名单
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 要加入黑名单的用户
 *  @param aBoth     是否同时屏蔽发给对方的消息
 *
 *  @result 错误信息
 *
 *  \~english
 *  Add a user to blacklist
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername Block user
 *  @param aBoth     if aBoth is YES, then hide user and block messages from blocked user; if NO, then hide user from blocked user
 *
 *  @result Error
 */
- (AgoraChatError *)addUserToBlackList:(NSString *)aUsername
               relationshipBoth:(BOOL)aBoth EM_DEPRECATED_IOS(3_2_3, 3_6_2, "Use -[IAgoraChatContactManager addUserToBlackList:] instead");


#pragma mark - EM_DEPRECATED_IOS 3.2.3

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Delegate
 */
- (void)addDelegate:(id<AgoraChatContactManagerDelegate>)aDelegate EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -[IAgoraChatContactManager addDelegate:delegateQueue:] instead");

#pragma mark - EM_DEPRECATED_IOS < 3.2.3

/*!
 *  \~chinese
 *  从数据库获取所有的好友
 *
 *  @result 好友列表<NSString>
 *
 *  \~english
 *  Get all the friends from the DB
 *
 *  @result Contact NSArray<NSString>
 */
- (NSArray *)getContactsFromDB __deprecated_msg("Use -getContacts instead");

/*!
 *  \~chinese
 *  从数据库获取黑名单列表
 *
 *  @result 黑名单列表<NSString>
 *
 *  \~english
 *  Get the blacklist from the DB
 *
 *  @result NSArray<NSString>
 */
- (NSArray *)getBlackListFromDB __deprecated_msg("Use -getBlackList instead");

/*!
 *  \~chinese
 *  从服务器获取所有的好友
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Get all the friends from the server
 *
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncGetContactsFromServer:(void (^)(NSArray *aList))aSuccessBlock
                           failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -getContactsFromServerWithCompletion: instead");

/*!
 *  \~chinese
 *  添加好友
 *
 *  @param aUsername        要添加的用户
 *  @param aMessage         邀请信息
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Add a contact
 *
 *  @param aUsername        The user to add
 *  @param aMessage         Friend invitation message
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncAddContact:(NSString *)aUsername
                message:(NSString *)aMessage
                success:(void (^)())aSuccessBlock
                failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -addContact:message:completion: instead");

/*!
 *  \~chinese
 *  删除好友
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername 要删除的好友
 *
 *  @result 错误信息
 *
 *  \~english
 *  Delete a contact
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername The user to delete
 *
 *  @result Error
 */
- (AgoraChatError *)deleteContact:(NSString *)aUsername __deprecated_msg("Use -deleteContact:username:isDeleteConversation: instead");


/*!
 *  \~chinese
 *  删除好友
 *
 *  @param aUsername        要删除的好友
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Delete a contact
 *
 *  @param aUsername        The user to be deleted
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)deleteContact:(NSString *)aUsername
           completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock __deprecated_msg("Use -deleteContact:username:isDeleteConversation: instead");

/*!
 *  \~chinese
 *  删除好友
 *
 *  @param aUsername            要删除的好友
 *  @param aSuccessBlock        成功的回调
 *  @param aFailureBlock        失败的回调
 *
 *  \~english
 *  Delete friend
 *
 *  @param aUsername        The user to be delete
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncDeleteContact:(NSString *)aUsername
                   success:(void (^)())aSuccessBlock
                   failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -deleteContact:completion: instead");

/*!
 *  \~chinese
 *  从服务器获取黑名单列表
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Get the blacklist from the server
 *
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncGetBlackListFromServer:(void (^)(NSArray *aList))aSuccessBlock
                            failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -getBlackListFromServerWithCompletion: instead");

/*!
 *  \~chinese
 *  将用户加入黑名单
 *
 *  @param aUsername        要加入黑名单的用户
 *  @param aBoth                 是否同时屏蔽发给对方的消息
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Add user to blacklist
 *
 *  @param aUsername        The user to add
 *  @param aBoth            Whether block messages from me to the user which is added to the black list
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncAddUserToBlackList:(NSString *)aUsername
               relationshipBoth:(BOOL)aBoth
                        success:(void (^)())aSuccessBlock
                        failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -addUserToBlackList:completion: instead");

/*!
 *  \~chinese
 *  将用户移出黑名单
 *
 *  @param aUsername        要移出黑名单的用户
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Remove user from blacklist
 *
 *  @param aUsername        The user to remove from blacklist
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncRemoveUserFromBlackList:(NSString *)aUsername
                             success:(void (^)())aSuccessBlock
                             failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -removeUserFromBlackList:completion: instead");

/*!
 *  \~chinese
 *  同意加好友的申请
 *
 *  @param aUsername        申请者
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Agree invitation
 *
 *  @param aUsername        Applicant
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncAcceptInvitationForUsername:(NSString *)aUsername
                                 success:(void (^)())aSuccessBlock
                                 failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -approveFriendRequestFromUser:completion: instead");

/*!
 *  \~chinese
 *  拒绝加好友的申请
 *
 *  @param aUsername        申请者
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Decline invitation
 *
 *  @param aUsername        Applicant
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncDeclineInvitationForUsername:(NSString *)aUsername
                                  success:(void (^)())aSuccessBlock
                                  failure:(void (^)(AgoraChatError *aError))aFailureBlock __deprecated_msg("Use -declineFriendRequestFromUser:completion: instead");

@end
