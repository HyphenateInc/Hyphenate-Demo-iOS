/*!
 *  @header AgoraChatClient.h
 *  @abstract SDK Client
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatClientDelegate.h"
#import "AgoraChatMultiDevicesDelegate.h"
#import "AgoraChatOptions.h"
#import "AgoraChatPushOptions.h"
#import "AgoraChatError.h"

#import "IAgoraChatManager.h"
#import "IAgoraChatContactManager.h"
#import "IAgoraChatGroupManager.h"
#import "IAgoraChatroomManager.h"
#import "IAgoraChatPushManager.h"
#import "IAgoraChatUserInfoManager.h"

#import "AgoraChatDeviceConfig.h"

/*!
 *  \~chinese
 *  服务检查枚举类型
 *
 *  \~english
 *  Type of server check
 */
typedef enum {
    AgoraChatServerCheckAccountValidation = 0,     /*! \~chinese 账号检查类型  \~english Valid account */
    AgoraChatServerCheckGetDNSListFromServer,      /*! \~chinese 获取服务列表检查类型  \~english Check get dns from server */
    AgoraChatServerCheckGetTokenFromServer,        /*! \~chinese 获取token检查类型  \~english Check get token from server */
    AgoraChatServerCheckDoLogin,                   /*! \~chinese 登录检查类型  \~english Check login mode */
    AgoraChatServerCheckDoLogout,                  /*! \~chinese 登出检查类型  \~english Check logout mode */
} AgoraChatServerCheckType;

/*!
 * \~chinese
 *  IM SDK的入口，负责登录登出及连接管理等，由此可以获得其他模块的入口，例如：群组模块
 *  [AgoraChatClient sharedClient].groupManager;
 *
 * \~english
 *  IM SDK Client, entrance of SDK, used to login, logout, and get access IM modules, such as
 *  [AgoraChatClient sharedClient].groupManager;
 */
@interface AgoraChatClient : NSObject
{
    AgoraChatPushOptions *_pushOptions;
}

/*!
 *  \~chinese
 *  SDK版本号
 *
 *  \~english
 *  SDK version
 */
@property (nonatomic, strong, readonly) NSString *version;

/*!
 *  \~chinese
 *  当前登录账号
 *
 *  \~english
 *  Current logged in user's username
 */
@property (nonatomic, strong, readonly) NSString *currentUsername;

/*!
 *  \~chinese
 *  SDK的设置选项
 *
 *  \~english
 *  SDK setting options
 */
@property (nonatomic, strong, readonly) AgoraChatOptions *options;


/*!
 *  \~chinese
 *  聊天模块
 *
 *  \~english
 *  Chat Management
 */
@property (nonatomic, strong, readonly) id<IAgoraChatManager> chatManager;

/*!
 *  \~chinese
 *  好友模块
 *
 *  \~english
 *  Contact Management
 */
@property (nonatomic, strong, readonly) id<IAgoraChatContactManager> contactManager;

/*!
 *  \~chinese
 *  群组模块
 *
 *  \~english
 *  Group Management
 */
@property (nonatomic, strong, readonly) id<IAgoraChatGroupManager> groupManager;

/*!
 *  \~chinese
 *  聊天室模块
 *
 *  \~english
 *  Chat Room Management
 */
@property (nonatomic, strong, readonly) id<IAgoraChatroomManager> roomManager;


/*!
 *  \~chinese
 *  推送模块
 *
 *  \~english
 *  push Management
 */
@property (nonatomic, strong, readonly) id<IAgoraChatPushManager> pushManager;
/*!
 *  \~chinese
 *  SDK是否自动登录上次登录的账号
 *
 *  \~english
 *  If SDK will automatically log into with previously logged in session. If the current login failed, then isAutoLogin attribute will be reset to NO, you need to set it back to YES in order to allow automatic login
 *  1. password changed
 *  2. deactivate, forced logout, etc
 */
@property (nonatomic, readonly) BOOL isAutoLogin;

/*!
 *  \~chinese
 *  用户是否已登录
 *
 *  \~english
 *  If a user logged in
 */
@property (nonatomic, readonly) BOOL isLoggedIn;

/*!
 *  \~chinese
 *  是否连上聊天服务器
 *
 *  \~english
 *  Whether connection  to Hyphenate IM server
 */
@property (nonatomic, readonly) BOOL isConnected;


/*!
 *  \~chinese
 *  当前用户访问环信服务器使用的token
 *
 *  \~english
 *  Current user hyphenate token
 */
@property (nonatomic, readonly) NSString *accessUserToken;

/*!
 *  \~chinese
 *  用户属性模块
 *
 *  \~english
 *  User attribute related
 */
@property (nonatomic, strong, readonly) id<IAgoraChatUserInfoManager> userInfoManager;

/*!
 *  \~chinese
 *  获取SDK实例
 *
 *  \~english
 *  Get SDK singleton instance
 */
+ (instancetype)sharedClient;


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
 *  @param aDelegate  Delegate
 *  @param aQueue     (optional) The queue of calling delegate methods. Pass in nil to run on main thread.
 */
- (void)addDelegate:(id<AgoraChatClientDelegate>)aDelegate
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

/*!
 *  \~chinese
 *  添加多设备回调代理
 *
 *  @param aDelegate  要添加的代理
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add multi-device delegate
 *
 *  @param aDelegate  Delegate
 *  @param aQueue     The queue of calling delegate methods
 */
- (void)addMultiDevicesDelegate:(id<AgoraChatMultiDevicesDelegate>)aDelegate
                  delegateQueue:(dispatch_queue_t)aQueue;

/*!
 *  \~chinese
 *  移除多设备回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove multi devices delegate
 *
 *  @param aDelegate  Delegate
 */
- (void)removeMultiDevicesDelegate:(id<AgoraChatMultiDevicesDelegate>)aDelegate;

#pragma mark - Initialize SDK

/*!
 *  \~chinese
 *  初始化SDK
 *
 *  @param aOptions  SDK配置项
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Initialize the SDK
 *
 *  @param aOptions SDK setting options
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)initializeSDKWithOptions:(AgoraChatOptions *)aOptions;


#pragma mark - Change AppKey

/*!
 *  \~chinese
 *  修改appkey，注意只有在未登录状态才能修改appkey
 *
 *  @param aAppkey  appkey
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Change appkey. Can only change appkey when the user is logged out
 *
 *  @param aAppkey  appkey
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)changeAppkey:(NSString *)aAppkey;


#pragma mark - User Registeration

/*!
 *  \~chinese
 *  注册用户
 *
 *  同步方法，会阻塞当前线程. 不推荐使用，建议后台通过REST注册
 *
 *  @param aUsername  用户名
 *  @param aPassword  密码
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Register a new IM user
 *
 *  To ensure good reliability, registering new IM user via REST API from developer backend is highly recommended
 *
 *  @param aUsername  Username
 *  @param aPassword  Password
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)registerWithUsername:(NSString *)aUsername
                         password:(NSString *)aPassword;

/*!
 *  \~chinese
 *  注册用户
 *
 *  不推荐使用，建议后台通过REST注册
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Register a new IM user
 *
 *  To ensure good reliability, registering new IM user via REST API from developer backend is highly recommended
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)registerWithUsername:(NSString *)aUsername
                    password:(NSString *)aPassword
                  completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;


#pragma mark - Login

/*!
 *  \~chinese
 *  从服务器获取token
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get the token from the server
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)fetchTokenWithUsername:(NSString *)aUsername
                      password:(NSString *)aPassword
                    completion:(void (^)(NSString *aToken, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  密码登录
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername  用户名 不可为空，可以是字母/数字/下划线/横线/英文句号，正则为"^[a-zA-Z0-9_-]+$"，
 *                 其他的都不允许。如果是大写字母会自动转成小写。长度不可超过64个字符长度。
 *  @param aPassword  密码  不可为空，长度不可超过64个字符长度。
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Login with password
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername  Username It cannot be empty, it can be letters/numbers/underscores/horizontals/periods. The regular expression is "^[a-zA-Z0-9_-]+$". Nothing else is allowed. If it is an uppercase letter, it will be automatically converted to lowercase. The length cannot exceed 64 characters in length
 *
 *
 *  @param aPassword  Password  Cannot be empty, and the length cannot exceed 64 characters in length
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)loginWithUsername:(NSString *)aUsername
                      password:(NSString *)aPassword;

/*!
 *  \~chinese
 *  密码登录
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Login with password
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loginWithUsername:(NSString *)aUsername
                 password:(NSString *)aPassword
               completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  token登录，不支持自动登录
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername  用户名
 *  @param aToken     Token
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Login with token. Does not support automatic login
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername  Username
 *  @param aToken     Token
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)loginWithUsername:(NSString *)aUsername
                         token:(NSString *)aToken;

/*!
 *  \~chinese
 *  token登录，不支持自动登录
 *
 *  @param aUsername        用户名
 *  @param aToken           Token
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Login with token. Does not support automatic login
 *
 *  @param aUsername        Username
 *  @param aToken           Token
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loginWithUsername:(NSString *)aUsername
                    token:(NSString *)aToken
               completion:(void (^)(NSString *aUsername, AgoraChatError *aError))aCompletionBlock;

#pragma mark - Logout

/*!
 *  \~chinese
 *  登出
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aIsUnbindDeviceToken 是否解除device token的绑定，解除绑定后设备不会再收到消息推送
 *         如果传入YES, 解除绑定失败，将返回error
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Logout
 *
 *  Synchronization method will block the current thread
 *
 *  @param aIsUnbindDeviceToken Unbind device token to disable Apple Push Notification Service
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)logout:(BOOL)aIsUnbindDeviceToken;

/*!
 *  \~chinese
 *  登出
 *
 *  @param aIsUnbindDeviceToken 是否解除device token的绑定，解除绑定后设备不会再收到消息推送
 *         如果传入YES, 解除绑定失败，将返回error
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Logout
 *
 *  @param aIsUnbindDeviceToken     Whether to unbind the device token, the device will no longer receive push notifications after unbinding, If YES is passed in, unbinding fails and error will be returned
 *  @param aCompletionBlock         The callback of completion block
 *
 */
- (void)logout:(BOOL)aIsUnbindDeviceToken
    completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

#pragma mark - PushKit

/*!
 *  \~chinese
 *  绑定PushKit token
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aPushToken  要绑定的token
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Pushkit token binding is required to enable Apple PushKit Service
 *
 *  Synchronization method will block the current thread
 *
 *  @param aPushToken  pushkit token to bind
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)bindPushKitToken:(NSData *)aPushToken;

/*!
 *  \~chinese
 *  绑定PushKit token
 *
 *  @param aPushToken  要绑定的token
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Pushkit token binding is required to enable Apple PushKit Service
 *
 *  @param aPushToken  pushkit token to bind
 *  @param aCompletionBlock     The callback block of completion
 */
- (void)registerPushKitToken:(NSData *)aPushToken
                  completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  解除PushKit token绑定
 *
 *  同步方法，会阻塞当前线程
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Disable Apple PushKit Service
 *
 *  Synchronization method will block the current thread
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)unBindPushKitToken;

/*!
 *  \~chinese
 *  解除PushKit token绑定
 *
 *  \~english
 *  Disable Apple PushKit Service
 *
 *  @param aCompletionBlock     The callback block of completion
 */
- (void)unRegisterPushKitTokenWithCompletion:(void (^)(AgoraChatError *aError))aCompletionBlock;

#pragma mark - APNs

/*!
 *  \~chinese
 *  绑定device token
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aDeviceToken  要绑定的token
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Device token binding is required to enable Apple Push Notification Service
 *
 *  Synchronization method will block the current thread
 *
 *  @param aDeviceToken  Device token to bind
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)bindDeviceToken:(NSData *)aDeviceToken;

/*!
 *  \~chinese
 *  绑定device token
 *
 *  @param aDeviceToken     要绑定的token
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Device token binding is required to enable Apple push notification service
 *
 *  @param aDeviceToken         Device token to bind
 *  @param aCompletionBlock     The callback block of completion
 */
- (void)registerForRemoteNotificationsWithDeviceToken:(NSData *)aDeviceToken
                                           completion:(void (^)(AgoraChatError *aError))aCompletionBlock;


#pragma mark - Log

/*!
 *  \~chinese
 *  上传日志到服务器
 *
 *  同步方法，会阻塞当前线程
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Upload debugging log to server
 *
 *  Synchronization method will block the current thread
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)uploadLogToServer;

/*!
 *  \~chinese
 *  上传日志到服务器
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Upload debugging log to server
 *
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)uploadDebugLogToServerWithCompletion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  将日志文件压缩成.gz文件，返回gz文件路径。强烈建议方法完成之后删除该压缩文件
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param pError 错误信息
 *
 *  @result NSString 文件路径
 *
 *  \~english
 *  Compress the log file into a .gz file and return the gz file path. Recommend delete the gz file if file is no longer used
 *
 *  Synchronization method will block the current thread
 *
 *  @param pError Error
 *
 *  @result NSString  Filepath
 */
- (NSString *)getLogFilesPath:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  将日志文件压缩成.gz文件，返回gz文件路径。强烈建议方法完成之后删除该压缩文件
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Compress the log file into a .gz file and return the gz file path. Recommend delete the gz file if file is no longer used
 *
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)getLogFilesPathWithCompletion:(void (^)(NSString *aPath, AgoraChatError *aError))aCompletionBlock;

/*!
*  \~chinese
*  输出日志信息到日志文件，需要在SDK初始化之后调用
*
*  @param aLog 要输出的日志信息
*
*  \~english
*  Output log info to log file.You can call this method after the SDK has been initialized.
*
*  @param aLog The log info
*/
- (void)log:(NSString*)aLog;

#pragma mark - Multi Devices

/*!
 *  \~chinese
 *  从服务器获取所有已经登录的设备信息
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param pError           错误信息
 *
 *  @result NSArray 所有已经登录的设备信息列表<AgoraChatDeviceConfig>
 *
 *  \~english
 *  Get all the device information <AgoraChatDeviceConfig> that logged in to the server
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param pError           Error
 *
 *  @result NSArray Information of logged in device <AgoraChatDeviceConfig>
 */
- (NSArray *)getLoggedInDevicesFromServerWithUsername:(NSString *)aUsername
                                             password:(NSString *)aPassword
                                                error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  从服务器获取所有已经登录的设备信息
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get all the device information <AgoraChatDeviceConfig> that logged in to the server
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)getLoggedInDevicesFromServerWithUsername:(NSString *)aUsername
                                        password:(NSString *)aPassword
                                      completion:(void (^)(NSArray *aList, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  强制指定的设备登出
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aDevice          设备信息
 *
 *  @result 错误信息
 *
 *  \~english
 *  Force logout the specified device
 *
 *  device information can be obtained from getLoggedInDevicesFromServerWithUsername:password:error:
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aResource        device resource
 *
 *  @result Error
 */
- (AgoraChatError *)kickDeviceWithUsername:(NSString *)aUsername
                           password:(NSString *)aPassword
                           resource:(NSString *)aResource;



/*!
 *  \~chinese
 *  强制指定的设备登出
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aDevice          设备信息
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Force logout the specified device
 *
 *  device information can be obtained from getLoggedInDevicesFromServerWithUsername:password:error:
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aResource        device resource
 *  @param aCompletionBlock The callback block of completion
 */
- (void)kickDeviceWithUsername:(NSString *)aUsername
                      password:(NSString *)aPassword
                      resource:(NSString *)aResource
                    completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  强制所有的登录设备登出
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Force logout all logged in device for the specified user
 *
 *  Synchronization method will block the current thread
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)kickAllDevicesWithUsername:(NSString *)aUsername
                               password:(NSString *)aPassword;

/*!
 *  \~chinese
 *  强制所有的登录设备登出
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Force all logged in device to logout.
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback block of completion
 */
- (void)kickAllDevicesWithUsername:(NSString *)aUsername
                          password:(NSString *)aPassword
                        completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

#pragma mark - iOS

/*!
 *  \~chinese
 *  iOS专用，数据迁移到SDK3.0
 *
 *  同步方法，会阻塞当前线程
 *
 *  升级到SDK3.0版本需要调用该方法，开发者需要等该方法执行完后再进行数据库相关操作
 *
 *  @result BOOL 是否迁移成功
 *
 *  \~english
 *  Migrate the IM database to the latest SDK version
 *
 *  Synchronization method will block the current thread
 *
 *  @result BOOL Return YES for success
 */
- (BOOL)migrateDatabaseToLatestSDK;

/*!
 *  \~chinese
 *  iOS专用，程序进入后台时，需要调用此方法断开连接
 *
 *  @param aApplication  UIApplication
 *
 *  \~english
 *  Disconnect from server when app enters background
 *
 *  @param aApplication  UIApplication
 */
- (void)applicationDidEnterBackground:(id)aApplication;

/*!
 *  \~chinese
 *  iOS专用，程序进入前台时，需要调用此方法进行重连
 *
 *  @param aApplication  UIApplication
 *
 *  \~english
 *  Reconnect to server when app enters foreground
 *
 *  @param aApplication  UIApplication
 */
- (void)applicationWillEnterForeground:(id)aApplication;

/*!
 *  \~chinese
 *  iOS专用，程序在前台收到APNS时，需要调用此方法
 *
 *  @param application  UIApplication
 *  @param userInfo     推送内容
 *
 *  \~english
 *  Invoked when receiving APNS in foreground
 *
 *  @param application  UIApplication
 *  @param userInfo     Push content
 */
- (void)application:(id)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

#pragma mark - Service Check

/*!
 *  \~chinese
 *  服务诊断接口，根据AgoraChatServerCheckType枚举的顺序依次诊断当前服务，并回调给开发者
 *  如果已经登录，默认使用登录账号
 *
 *  @param aUsername    用户名
 *  @param aPassword    密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Make a diagnose for service, Diagnosis of current services according to the order of AgoraChatServerCheckType enumeration, and callback for the developer
 *  If you have logged in, use the default login account
 *
 *  @param aUsername    username
 *  @param aPassword    password
 *  @param aCompletionBlock The callback block of completion
 */
- (void)serviceCheckWithUsername:(NSString *)aUsername
                        password:(NSString *)aPassword
                      completion:(void (^)(AgoraChatServerCheckType aType, AgoraChatError *aError))aCompletionBlock;

#pragma mark - EM_DEPRECATED_IOS 3.7.2
/*!
 *  \~chinese
 *  推送设置
 *
 *  \~english
 *  Apple Push Notification Service setting
 */
@property (nonatomic, strong, readonly) AgoraChatPushOptions *pushOptions EM_DEPRECATED_IOS(3_1_0, 3_7_2, "Use -[IAgoraChatPushManager.pushOptions] instead");


/*!
 *  \~chinese
 *  设置推送消息显示的昵称
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aNickname  要设置的昵称
 *
 *  @result 错误信息
 *
 *  \~english
 *  Set display name for Apple Push Notification message
 *
 *  Synchronization method will block the current thread
 *
 *  @param aNickname  Display name
 *
 *  @result Error
 */
- (AgoraChatError *)setApnsNickname:(NSString *)aNickname EM_DEPRECATED_IOS(3_1_0, 3_7_2, "Use -[IAgoraChatPushManager:setApnsNickname:] instead");

/*!
 *  \~chinese
 *  设置推送的显示名
 *
 *  @param aDisplayName     推送显示名
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Set display name for the push notification
 *
 *  @param aDisplayName     Display name of push
 *  @param aCompletionBlock The callback block of completion
 *
 */
- (void)updatePushNotifiationDisplayName:(NSString *)aDisplayName
                              completion:(void (^)(NSString *aDisplayName, AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_1_0, 3_7_2, "Use -[IAgoraChatPushManager:updatePushNotifiationDisplayName:completion:] instead");

/*!
 *  \~chinese
 *  从服务器获取推送属性
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param pError  错误信息
 *
 *  @result AgoraChatPushOptions 推送属性
 *
 *  \~english
 *  Get Apple Push Notification Service options from the server
 *
 *  Synchronization method will block the current thread
 *
 *  @param pError  Error
 *
 *  @result AgoraChatPushOptions  Apple Push Notification Service options
 */
- (AgoraChatPushOptions *)getPushOptionsFromServerWithError:(AgoraChatError **)pError EM_DEPRECATED_IOS(3_1_0, 3_7_2, "Use -[IAgoraChatPushManager:getPushOptionsFromServerWithError:] instead");

/*!
 *  \~chinese
 *  从服务器获取推送属性
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Get Apple Push Notification Service options from the server
 *
 *  @param aCompletionBlock The callback of completion block
 */
- (void)getPushNotificationOptionsFromServerWithCompletion:(void (^)(AgoraChatPushOptions *aOptions, AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_1_0, 3_7_2, "Use -[IAgoraChatPushManager:getPushNotificationOptionsFromServerWithCompletion:] instead");

/*!
 *  \~chinese
 *  更新推送设置到服务器
 *
 *  同步方法，会阻塞当前线程
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Update Apple Push Notification Service options to the server
 *
 *  Synchronization method will block the current thread
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)updatePushOptionsToServer EM_DEPRECATED_IOS(3_1_0, 3_7_2, "");

/*!
 *  \~chinese
 *  更新推送设置到服务器
 *
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Update Apple Push Notification Service options to the server
 *
 *  @param aCompletionBlock The callback block of completion
 */
- (void)updatePushNotificationOptionsToServerWithCompletion:(void (^)(AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_1_0, 3_7_2, "");

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
- (void)addDelegate:(id<AgoraChatClientDelegate>)aDelegate EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -[IEMCallManager addDelegate:delegateQueue:] instead");

#pragma mark - EM_DEPRECATED_IOS < 3.2.3

/*!
 *  \~chinese
 *  注册用户
 *
 *  不推荐使用，建议后台通过REST注册
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Register a new user
 *
 *  To enhance the reliability, registering new IM user through REST API from backend is highly recommended
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncRegisterWithUsername:(NSString *)aUsername
                         password:(NSString *)aPassword
                          success:(void (^)())aSuccessBlock
                          failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -registerWithUsername:password:completion: instead");


/*!
 *  \~chinese
 *  登录
 *
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Login
 *
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncLoginWithUsername:(NSString *)aUsername
                      password:(NSString *)aPassword
                       success:(void (^)())aSuccessBlock
                       failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -loginWithUsername:password:completion: instead");

/*!
 *  \~chinese
 *  登出
 *
 *  @param aIsUnbindDeviceToken 是否解除device token的绑定，解除绑定后设备不会再收到消息推送
 *         如果传入YES, 解除绑定失败，将返回error
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Logout
 *
 *  @param aIsUnbindDeviceToken Unbind device token to disable the Apple Push Notification Service
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 */
- (void)asyncLogout:(BOOL)aIsUnbindDeviceToken
            success:(void (^)())aSuccessBlock
            failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -logout:completion: instead");


/*!
 *  \~chinese
 *  绑定device token
 *
 *  @param aDeviceToken     要绑定的token
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Bind device token
 *
 *  @param aDeviceToken     Device token to bind
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 */
- (void)asyncBindDeviceToken:(NSData *)aDeviceToken
                     success:(void (^)())aSuccessBlock
                     failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -registerForRemoteNotificationsWithDeviceToken:completion: instead");

/*!
 *  \~chinese
 *  设置推送消息显示的昵称
 *
 *  @param aNickname             要设置显示的昵称
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Set display name for push notification
 *
 *  @param aNickname        Push Notification display name
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncSetApnsNickname:(NSString *)aNickname
                     success:(void (^)())aSuccessBlock
                     failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -updatePushNotifiationDisplayName:copletion: instead");

/*!
 *  \~chinese
 *  从服务器获取推送属性
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Get apns options from the server
 *
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 */
- (void)asyncGetPushOptionsFromServer:(void (^)(AgoraChatPushOptions *aOptions))aSuccessBlock
                              failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -getPushOptionsFromServerWithCompletion: instead");

/*!
 *  \~chinese
 *  更新推送设置到服务器
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Update APNS options to the server
 *
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 *
 */
- (void)asyncUpdatePushOptionsToServer:(void (^)())aSuccessBlock
                               failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -updatePushNotificationOptionsToServerWithCompletion: instead");

/*!
 *  \~chinese
 *  上传日志到服务器
 *
 *  @param aSuccessBlock    成功的回调
 *  @param aFailureBlock    失败的回调
 *
 *  \~english
 *  Upload log to server
 *
 *  @param aSuccessBlock    The callback block of success
 *  @param aFailureBlock    The callback block of failure
 */
- (void)asyncUploadLogToServer:(void (^)())aSuccessBlock
                       failure:(void (^)(AgoraChatError *aError))aFailureBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -uploadDebugLogToServerWithCompletion: instead");

/*!
 *  \~chinese
 *  iOS专用，数据迁移到SDK3.0
 *
 *  同步方法，会阻塞当前线程
 *
 *  升级到SDK3.0版本需要调用该方法，开发者需要等该方法执行完后再进行数据库相关操作
 *
 *  @result 是否迁移成功
 *
 *  \~english
 *  iOS-specific, data migration to SDK3.0
 *
 *  Synchronization method will block the current thread
 *
 *  It's needed to call this method when update to SDK3.0, developers need to wait this method complete before DB related operations
 *
 *  @result Whether migration successful
 */
- (BOOL)dataMigrationTo3 EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -migrateDatabaseToLatestSDK instead");


/*!
 *  \~chinese
 *  强制指定的设备登出
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aDevice          设备信息
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *
 *  @result AgoraChatError 错误信息
 *
 *  \~english
 *  Force logout the specified device
 *
 *  device information can be obtained from getLoggedInDevicesFromServerWithUsername:password:error:
 *
 *  Synchronization method will block the current thread
 *
 *  @param aDevice          device information <AgoraChatDeviceConfig>
 *  @param aUsername        Username
 *  @param aPassword        Password
 *
 *  @result AgoraChatError error
 */
- (AgoraChatError *)kickDevice:(AgoraChatDeviceConfig *)aDevice
               username:(NSString *)aUsername
               password:(NSString *)aPassword EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use - kickDeviceWithUsername:password:resource: instead");


/*!
 *  \~chinese
 *  强制指定的设备登出
 *
 *  @param aDevice          设备信息
 *  @param aUsername        用户名
 *  @param aPassword        密码
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Force logout the specified device
 *
 *  device information can be obtained from getLoggedInDevicesFromServerWithUsername:password:error:
 *
 *  @param aDevice          device information <AgoraChatDeviceConfig>
 *  @param aUsername        Username
 *  @param aPassword        Password
 *  @param aCompletionBlock The callback block of completion
 */
- (void)kickDevice:(AgoraChatDeviceConfig *)aDevice
          username:(NSString *)aUsername
          password:(NSString *)aPassword
        completion:(void (^)(AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use - kickDeviceWithUsername:password:resource:completion: instead");
@end
