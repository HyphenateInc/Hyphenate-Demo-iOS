//
//  AgoraUserInfo.h
//  libHyphenateSDK.a
//
//  Created by lixiaoming on 2021/3/17.
//  Copyright © 2021 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 *  \~chinese
 *  用户属性类型
 *
 *  \~english
 *  UserInfo type
 */
typedef NS_ENUM(NSInteger, AgoraUserInfoType) {
    AgoraUserInfoTypeNickName = 0,
    AgoraUserInfoTypeAvatarURL,
    AgoraUserInfoTypePhone,
    AgoraUserInfoTypeMail,
    AgoraUserInfoTypeGender,
    AgoraUserInfoTypeSign,
    AgoraUserInfoTypeBirth,
    AgoraUserInfoTypeExt = 100,
};
/*!
 *  \~chinese
 *  用户属性信息
 *
 *  \~english
 *  UserInfo class
 */
@interface AgoraUserInfo : NSObject<NSCopying>
@property (nonatomic,copy) NSString *userId; /*! *\~chinese 用户环信Id *\~english user's id */
@property (nonatomic,copy) NSString *nickName; /*! *\~chinese 用户昵称 *\~english user's nickname */
@property (nonatomic,copy) NSString *avatarUrl; /*! *\~chinese 用户头像地址 *\~english user's avatar file uri */
@property (nonatomic,copy) NSString *mail; /*! *\~chinese 用户邮箱地址 *\~english user's mail  address */

@property (nonatomic,copy) NSString *phone; /*! *\~chinese 用户联系方式 *\~english user's phone  number */
@property (nonatomic) NSInteger gender; /*! *\~chinese 用户性别，0为未设置 *\~english user's phone  number */
@property (nonatomic,copy) NSString* sign; /*! *\~chinese 用户签名 *\~english user's sign info */
@property (nonatomic,copy) NSString* birth; /*! *\~chinese 用户生日 *\~english user's birth */
@property (nonatomic,copy) NSString *ext; /*! *\~chinese 扩展字段 *\~english extention info */
@end
