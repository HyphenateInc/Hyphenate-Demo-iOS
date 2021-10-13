/*!
 *  \~chinese
 *  @header AgoraChatError.h
 *  @abstract SDK定义的错误类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatError.h
 *  @abstract SDK defined error
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatErrorCode.h"

/*!
 *  \~chinese 
 *  SDK定义的错误类
 *
 *  \~english 
 *  SDK defined error
 */
@interface AgoraChatError : NSObject

/*!
 *  \~chinese 
 *  错误码
 *
 *  \~english 
 *  Error code
 */
@property (nonatomic) AgoraChatErrorCode code;

/*!
 *  \~chinese 
 *  错误描述
 *
 *  \~english 
 *  Error description
 */
@property (nonatomic, copy) NSString *errorDescription;


#pragma mark - Internal SDK

/*!
 *  \~chinese 
 *  初始化错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 错误实例
 *
 *  \~english
 *  Initialize an error instance
 *
 *  @param aDescription  Error description
 *  @param aCode         Error code
 *
 *  @result Error instance
 */
- (instancetype)initWithDescription:(NSString *)aDescription
                               code:(AgoraChatErrorCode)aCode;

/*!
 *  \~chinese 
 *  创建错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 错误实例
 *
 *  \~english
 *  Create a error instance
 *
 *  @param aDescription  Error description
 *  @param aCode         Error code
 *
 *  @result Error instance
 */
+ (instancetype)errorWithDescription:(NSString *)aDescription
                                code:(AgoraChatErrorCode)aCode;

@end
