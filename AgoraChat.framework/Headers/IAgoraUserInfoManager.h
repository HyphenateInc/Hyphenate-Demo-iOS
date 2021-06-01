//
//  IAgoraUserInfoManager.h
//  HyphenateSDK
//
//  Created by lixiaoming on 2021/3/17.
//  Copyright © 2021 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraUserInfo.h"
#import "AgoraError.h"

@protocol IAgoraUserInfoManager <NSObject>

/*!
 *  \~chinese
 *  设置自己的所有用户属性
 *
 *  @param aUserData       要设置的用户属性信息
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Set all own user info
 *
 *  @param aUserData       The user info data to set
 *  @param aCompletionBlock    The completion callback
 */
- (void)updateOwnUserInfo:(AgoraUserInfo*)aUserData
                completion:(void (^)(AgoraUserInfo*aUserInfo,AgoraError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  设置自己的指定用户属性
 *
 *  @param aValue       要设置的用户属性信息
 *  @param aType         要设置的用户属性类型
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Set special own user info
 *
 *  @param aValue       The user info data to set
 *  @param aType         The user info type to set
 *  @param aCompletionBlock    The completion callback
 */
- (void)updateOwnUserInfo:(NSString*)aValue
                 withType:(AgoraUserInfoType)aType
               completion:(void (^)(AgoraUserInfo*aUserInfo,AgoraError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  根据用户ID获取用户属性
 *
 *  @param aUserIds  要获取用户属性的的用户ID
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Get user info by id
 *
 *  @param aUserIds       The users's id to get user info
 *  @param aCompletionBlock    The completion callback
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*)aUserIds
                completion:(void (^)(NSDictionary*aUserDatas,AgoraError *aError))aCompletionBlock;
/*!
 *  \~chinese
 *  根据用户ID获取用户指定属性
 *
 *  @param aUserIds  要获取用户属性的的用户ID
 *  @param aType         要获取哪些类型的用户属性
 *  @param aCompletionBlock     完成回调
 *
 *  \~english
 *  Get user special info by id
 *
 *  @param aUserIds       The users's id to get user info
 *  @param aType              The user info type to get
 *  @param aCompletionBlock    The completion callback
 */
- (void)fetchUserInfoById:(NSArray<NSString*>*)aUserIds
                      type:(NSArray<NSNumber*>*)aType
                completion:(void (^)(NSDictionary*aUserDatas,AgoraError *aError))aCompletionBlock;
@end

