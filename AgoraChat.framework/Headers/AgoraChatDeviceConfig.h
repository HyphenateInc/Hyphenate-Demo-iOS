/*!
 *  \~chinese
 *  @header AgoraChatDeviceConfig.h
 *  @abstract 已登录设备的信息类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatDeviceConfig.h
 *  @abstract The info of logged in device
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

@interface AgoraChatDeviceConfig : NSObject

/*!
 *  \~chinese
 *  设备资源描述
 *
 *  \~english
 *  Device resources
 */
@property (nonatomic, readonly) NSString *resource;

/*!
 *  \~chinese
 *  设备的UUID
 *
 *  \~english
 *  Device UUID
 */
@property (nonatomic, readonly) NSString *deviceUUID;

/*!
 *  \~chinese
 *  设备名称
 *
 *  \~english
 *  Device name
 */
@property (nonatomic, readonly) NSString *deviceName;

@end
