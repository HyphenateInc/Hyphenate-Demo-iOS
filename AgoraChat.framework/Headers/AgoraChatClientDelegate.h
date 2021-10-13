/*!
 *  \~chinese
 *  @header AgoraChatClientDelegate.h
 *  @abstract 协议提供了与账号登录状态相关的回调
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatClientDelegate.h
 *  @abstract The protocol provides callbacks related to account login status
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

/*!
 *  \~chinese 
 *  网络连接状态
 *
 *  \~english 
 *  Network Connection Status
 */
typedef enum {
    AgoraChatConnectionConnected = 0,  /*! *\~chinese 服务器已连接 *\~english Server connected */
    AgoraChatConnectionDisconnected,   /*! *\~chinese 服务器未连接  *\~english Server not connected */
} AgoraChatConnectionState;

@class AgoraChatError;

/*!
 *  \~chinese 
 *  @abstract 协议提供了与账号登录状态相关的回调
 *
 *  \~english 
 *  @abstract This protocol provides a number of utility classes callback
 */
@protocol AgoraChatClientDelegate <NSObject>

@optional

/*!
 *  \~chinese
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  有以下几种情况, 会引起该方法的调用:
 *  1. 登录成功后, 手机无法上网时, 会调用该回调
 *  2. 登录成功后, 网络状态变化时, 会调用该回调
 *
 *  @param aConnectionState 当前状态
 *
 *  \~english
 *  Invoked when server connection state has changed
 *
 *  @param aConnectionState Current state
 */
- (void)connectionStateDidChange:(AgoraChatConnectionState)aConnectionState;

/*!
 *  \~chinese
 *  自动登录完成时的回调
 *
 *  @param aError 错误信息
 *
 *  \~english
 *  Invoked when auto login is completed
 *
 *  @param aError Error
 */
- (void)autoLoginDidCompleteWithError:(AgoraChatError *)aError;

/*!
 *  \~chinese
 *  当前登录账号在其它设备登录时会接收到此回调
 *
 *  \~english
 *  Invoked when current IM account logged into another device
 */
- (void)userAccountDidLoginFromOtherDevice;

/*!
 *  \~chinese
 *  当前登录账号已经被从服务器端删除时会收到该回调
 *
 *  \~english
 *  Invoked when current IM account is removed from server
 */
- (void)userAccountDidRemoveFromServer;

/*!
 *  \~chinese
 *  服务被禁用（自动登录时符合条件会触发）
 *
 *  \~english
 *  Delegate method will be invoked when User is forbidden
 */
- (void)userDidForbidByServer;

/*!
 *  \~chinese
 *  当前登录账号被强制退出时会收到该回调，有以下原因：
 *    1.密码被修改；
 *    2.登录设备数过多；
 *    3.服务被封禁;
 *    4.被强制下线;
 *
 *  \~english
 *  Delegate method will be invoked when current IM account is forced to logout with the following reasons:
 *    1. The password is modified
 *    2. Logged in too many devices
 *    3. User for forbidden
 *    4. Forced offline
 */
- (void)userAccountDidForcedToLogout:(AgoraChatError *)aError;

#pragma mark - Deprecated methods

/*!
 *  \~chinese
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  有以下几种情况, 会引起该方法的调用:
 *  1. 登录成功后, 手机无法上网时, 会调用该回调
 *  2. 登录成功后, 网络状态变化时, 会调用该回调
 *
 *  @param aConnectionState 当前状态
 *
 *  \~english
 *  Connection to the server status changes will receive the callback
 *  
 *  calling the method causes:
 *  1. After successful login, the phone can not access
 *  2. After a successful login, network status change
 *  
 *  @param aConnectionState Current state
 */
- (void)didConnectionStateChanged:(AgoraChatConnectionState)aConnectionState __deprecated_msg("Use -connectionStateDidChange:");

/*!
 *  \~chinese
 *  自动登录完成时的回调
 *
 *  @param aError 错误信息
 *
 *  \~english
 *  Callback Automatic login fails
 *
 *  @param aError Error
 */
- (void)didAutoLoginWithError:(AgoraChatError *)aError __deprecated_msg("Use -autoLoginDidCompleteWithError:");

/*!
 *  \~chinese
 *  当前登录账号在其它设备登录时会接收到此回调
 *
 *  \~english
 *  Will receive this callback when current account login from other device
 */
- (void)didLoginFromOtherDevice __deprecated_msg("Use -userAccountDidLoginFromOtherDevice");

/*!
 *  \~chinese
 *  当前登录账号已经被从服务器端删除时会收到该回调
 *
 *  \~english
 *  Current login account will receive the callback is deleted from the server
 */
- (void)didRemovedFromServer __deprecated_msg("Use -userAccountDidRemoveFromServer");

@end
