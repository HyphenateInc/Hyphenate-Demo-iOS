//
//  IAgoraChatUserInfoManager.h
//  HyphenateSDK
//
//  Created by lixiaoming on 2021/3/17.
//  Copyright © 2021 easemob.com. All rights reserved.
//

/*!
 *  \~chinese
 *  @header IAgoraChatUserInfoManager.h
 *  @abstract 用户属性操作类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IAgoraChatUserInfoManager.h
 *  @abstract UserInfo Operation class
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "AgoraChatUserInfo.h"
#import "AgoraChatError.h"

@protocol IAgoraChatUserInfoManager <NSObject>

/*!
 *  \~chinese
 *  设置自己的所有用户属性
 *
 *  @param aUserData       要设置的用户属性信息
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Set all own userInfo
 *
 *  @param aUserData       The userInfo data to set
 *  @param aCompletionBlock    The completion of callback
 */
- (void)updateOwnUserInfo:(AgoraChatUserInfo*)aUserData
               completion:(void (^)(AgoraChatUserInfo*aUserInfo,AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  设置自己的指定用户属性
 *
 *  @param aValue       要设置的用户属性信息
 *  @param aType         要设置的用户属性类型
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Set special own userInfo
 *
 *  @param aValue       The userInfo data to set
 *  @param aType         The userInfo type to set
 *  @param aCompletionBlock   The completion of callback
 */
- (void)updateOwnUserInfo:(NSString*)aValue
                 withType:(AgoraChatUserInfoType)aType
               completion:(void (^)(AgoraChatUserInfo*aUserInfo,AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  根据用户ID获取用户属性
 *
 *  @param aUserIds  要获取用户属性的的用户ID列表
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Get userInfo by userId
 *
 *  @param aUserIds                      UserId list
 *  @param aCompletionBlock    The completion of callback
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*)aUserIds
               completion:(void (^)(NSDictionary*aUserDatas,AgoraChatError *aError))aCompletionBlock;
/*!
 *  \~chinese
 *  根据用户ID列表及属性类型列表获取用户指定属性
 *
 *  @param aUserIds  要获取用户属性的的用户ID列表
 *  @param aType         要获取哪些类型的用户属性列表
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Get user special info by id
 *
 *  @param aUserIds             UserId list
 *  @param aType                    UserInfo type list
 *  @param aCompletionBlock    The completion of callback
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*)aUserIds
                     type:(NSArray<NSNumber*>*)aType
               completion:(void (^)(NSDictionary*aUserDatas,AgoraChatError *aError))aCompletionBlock;
@end

