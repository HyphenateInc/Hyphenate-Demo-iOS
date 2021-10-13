/*!
 *  \~chinese
 *  @header AgoraChatCustomMessageBody.h
 *  @abstract 自定义消息体
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatCustomMessageBody.h
 *  @abstract Custom message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "AgoraChatCommonDefs.h"
#import "AgoraChatMessageBody.h"

/*!
 *  \~chinese
 *  自定义消息体
 *
 *  \~english
 *  Custom message body
 */
@interface AgoraChatCustomMessageBody : AgoraChatMessageBody

/*!
 *  \~chinese
 *  自定义事件
 *
 *  \~english
 *  Custom event
 */
@property (nonatomic, copy) NSString *event;

/*!
 *  \~chinese
 *  自定义扩展字典
 *
 *  \~english
 *  Custom extension dictionary
 */
@property (nonatomic, copy) NSDictionary<NSString *,NSString *> *customExt;


/*!
 *  \~chinese
 *  初始化自定义消息体
 *
 *  @param aEvent   自定义事件
 *  @param aCustomExt 自定义扩展字典
 *
 *  @result 自定义消息体实例
 *
 *  \~english
 *   Initialize a custom message body instance
 *
 *  @param aEvent   Custom event
 *  @param aCustomExt Custom extension dictionary
 *
 *  @result Custom message body instance
 */
- (instancetype)initWithEvent:(NSString *)aEvent customExt:(NSDictionary<NSString *,NSString *> *)aCustomExt;

#pragma mark - EM_DEPRECATED_IOS 3.7.2
/*!
 *  \~chinese
 *  扩展字典
 *
 *  \~english
 *  extension dictionary
 */
@property (nonatomic, copy) NSDictionary *ext; EM_DEPRECATED_IOS(3_6_5, 3_7_2, "Use - customExt instead");

/*!
 *  \~chinese
 *  初始化自定义消息体
 *
 *  @param aEvent   自定义事件
 *  @param aExt        扩展字典
 *
 *  @result 自定义消息体实例
 *
 *  \~english
 *   Initialize a custom message body instance
 *
 *  @param aEvent   Custom event
 *  @param aExt  extension dictionary
 *
 *  @result Custom message body instance
 */
- (instancetype)initWithEvent:(NSString *)aEvent ext:(NSDictionary *)aExt; EM_DEPRECATED_IOS(3_6_5, 3_7_2, "Use - initWithEvent:customExt: instead");

@end
