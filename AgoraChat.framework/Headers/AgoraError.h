/*!
 *  \~chinese
 *  @header AgoraError.h
 *  @abstract SDK定义的错误
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraError.h
 *  @abstract SDK defined error
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraErrorCode.h"

/*!
 *  \~chinese 
 *  SDK定义的错误
 *
 *  \~english 
 *  SDK defined error
 */
@interface AgoraError : NSObject

/*!
 *  \~chinese 
 *  错误码
 *
 *  \~english 
 *  Error code
 */
@property (nonatomic) AgoraErrorCode code;

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
                               code:(AgoraErrorCode)aCode;

/*!
 *  \~chinese 
 *  创建错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 对象实例
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
                                code:(AgoraErrorCode)aCode;

@end
