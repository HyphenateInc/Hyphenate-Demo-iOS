/*!	
 *  \~chinese
 *  @header   AgoraChatOptions+PrivateDeploy.h
 *  @abstract SDK私有部署属性分类
 *  @author   Hyphenate
 *  @version  3.0
 *
 *  \~english
 *  @header   AgoraChatOptions+PrivateDeploy.h
 *  @abstract SDK setting options of private deployment
 *  @author   Hyphenate
 *  @version  3.0
 */

#import "AgoraChatOptions.h"

@interface AgoraChatOptions (PrivateDeploy)

/*!
 *  \~chinese 
 *  是否允许使用DNS, 默认为YES
 *
 *  只能在[AgoraChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改。
 *
 *  \~english
 *  Whether to allow using DNS, default is YES
 *
 *  Can only be set when initializing the SDK [AgoraChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, assign) BOOL enableDnsConfig;

/*!
 *  \~chinese 
 *  IM服务器端口
 *
 *  enableDnsConfig为NO时有效。只能在[AgoraChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  IM server port
 *
 *  chatPort is Only effective when isDNSEnabled is NO. 
 *  Can only be set when initializing the SDK with [AgoraChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, assign) int chatPort;

/*!
 *  \~chinese 
 *  IM服务器地址
 *
 *  enableDnsConfig为NO时生效。只能在[AgoraChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  IM server
 *
 *  chatServer is Only effective when isDNSEnabled is NO.
 *  Can only be set when initializing the SDK with [AgoraChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *chatServer;

/*!
 *  \~chinese 
 *  REST服务器地址
 *
 *  enableDnsConfig为NO时生效。只能在[AgoraChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  REST server
 *
 *  restServer Only effective when isDNSEnabled is NO.
 *  Can only be set when initializing the SDK with [AgoraChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *restServer;

/*!
 *  \~chinese
 *  DNS URL 地址
 *
 *  enableDnsConfig为YES时生效，只能在[AgoraChatClient initializeSDKWithOptions:]中设置，不能在程序运行过程中动态修改
 *
 *  \~english
 *  DNS url
 *
 *  dnsURL Only effective when isDNSEnabled is YES.
 *  Can only be set when initializing the SDK with [AgoraChatClient initializeSDKWithOptions:], cannot be altered in runtime
 */
@property (nonatomic, copy) NSString *dnsURL;


/*!
 *  \~chinese
 *  配置项扩展
 *
 *  \~english
 *  Options extension
 *
 */
#pragma mark - Deprecated 3.8.3.1
@property (nonatomic, strong) NSDictionary *extension __deprecated_msg("");

@end
