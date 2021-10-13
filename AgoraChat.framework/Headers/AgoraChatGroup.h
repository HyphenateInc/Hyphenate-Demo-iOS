/*!
 *  \~chinese
 *  @header AgoraChatGroup.h
 *  @abstract 群组模型类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatGroup.h
 *  @abstract Group model
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatCommonDefs.h"
#import "AgoraChatGroupOptions.h"

/*!
 *  \~chinese
 *  群组枚举类型
 *
 *  \~english
 *  Group permission type
 */
typedef enum{
    AgoraChatGroupPermissionTypeNone   = -1,    /*! \~chinese 未知类型 \~english Unknown type*/
    AgoraChatGroupPermissionTypeMember = 0,     /*! \~chinese 普通成员类型  \~english Normal member type*/
    AgoraChatGroupPermissionTypeAdmin,          /*! \~chinese 群组管理员类型 \~english Group admin type*/
    AgoraChatGroupPermissionTypeOwner,          /*! \~chinese 群主类型 \~english Group owner  type*/
}AgoraChatGroupPermissionType;

/*!
 *  \~chinese 
 *  群组
 *
 *  \~english
 *  Group
 */
@interface AgoraChatGroup : NSObject

/*!
 *  \~chinese
 *  群组ID
 *
 *  \~english
 *  Group id
 */
@property (nonatomic, copy, readonly) NSString *groupId;

/*!
*  \~chinese
*  群组的名称，需要获取群详情
*
*  \~english
*  Subject of the group, require fetch group's detail first
*/
@property (nonatomic, copy, readonly) NSString *groupName;

/*!
 *  \~chinese
 *  群组的描述，需要获取群详情
 *
 *  \~english
 *  Description of the group, require fetch group's detail first
 */
@property (nonatomic, copy, readonly) NSString *description;

/*!
 *  \~chinese
 *  群组的公告，需要获取群公告
 *
 *  \~english
 *  Announcement of the group, require fetch group's announcement first
 */
@property (nonatomic, copy, readonly) NSString *announcement;

/*!
 *  \~chinese
 *  群组属性配置，需要获取群详情
 *
 *  \~english
 *  Setting options of group, require fetch group's detail first
 */
@property (nonatomic, strong, readonly) AgoraChatGroupOptions *setting;

/*!
 *  \~chinese
 *  群组的所有者，拥有群的最高权限，需要获取群详情
 *
 *  群组的所有者只有一人
 *
 *  \~english
 *  Owner of the group, has the highest authority of the group, require fetch group's detail first
 *
 *  Each group only has one owner
 */
@property (nonatomic, copy, readonly) NSString *owner;

/*!
 *  \~chinese
 *  群组的管理者，拥有群的管理权限，需要获取群详情
 *
 *
 *  \~english
 *  Admins of the group, have group management authority, require fetch group's detail first
 *
 */
@property (nonatomic, copy, readonly) NSArray *adminList;

/*!
 *  \~chinese
 *  群组的成员列表，需要获取群详情
 *
 *  \~english
 *  Member list of the group, require fetch group's detail first
 */
@property (nonatomic, copy, readonly) NSArray *memberList;

/*!
 *  \~chinese
 *  群组的黑名单，需要先调用获取群黑名单方法
 *
 *  需要owner权限才能查看，非owner返回nil
 *
 *  \~english
 *  Group's blacklist of blocked users, require call get blackList method first
 *
 *  Need owner's authority to access, return nil if user is not the group owner.
 */
@property (nonatomic, strong, readonly) NSArray *blacklist;

/*!
 *  \~chinese
 *  群组的被禁言列表
 *
 *  需要admin 或者 owner权限才能查看，否则返回nil
 *
 *  \~english
 *  List of muted members
 *
 *  Need admin's or owner's authority to access, return nil if user is not the group owner or admin.
 */
@property (nonatomic, strong, readonly) NSArray *muteList;


/*!
 *  \~chinese
 *  聊天室的白名单列表<NSString>
 *
 *  需要owner权限才能查看，非owner返回nil
 *
 *  \~english
 *  List of whitelist members<NSString>
 *
 *  Need owner's authority to access, return nil if user is not the group owner.
 */
@property (nonatomic, strong, readonly) NSArray *whiteList;

/*!
 *  \~chinese
 *  群共享文件列表
 *
 *  \~english
 *  List of group shared file
 */
@property (nonatomic, strong, readonly) NSArray *sharedFileList;

/*!
 *  \~chinese
 *  群组是否接收消息推送通知
 *
 *  \~english
 *  Whether use Apple Push Notification Service  for group
 */
@property (nonatomic, readonly) BOOL isPushNotificationEnabled;

/*!
 *  \~chinese
 *  此群是否为公开群，需要获取群详情
 *
 *  \~english
 *  Whether is a public group, require fetch group's detail first
 */
@property (nonatomic, readonly) BOOL isPublic;

/*!
 *  \~chinese
 *  是否屏蔽群消息
 *
 *  \~english
 *  Whether block the current group‘s messages
 */
@property (nonatomic, readonly) BOOL isBlocked;

/*!
 *  \~chinese
 *  当前登录账号的群成员类型
 *
 *  \~english
 *  The group membership type of the current login account
 */
@property (nonatomic, readonly) AgoraChatGroupPermissionType permissionType;

/*!
 *  \~chinese
 *  群组的所有成员(包含owner、admins和members)
 *
 *  \~english
 *  All occupants of the group, includes the group owner and admins and all other group members
 */
@property (nonatomic, strong, readonly) NSArray *occupants;

/*!
 *  \~chinese
 *  群组当前的成员数量，需要获取群详情, 包括owner, admins, members
 *
 *  \~english
 *  The total number of group occupants, require fetch group's detail first, include owner, admins, members
 */
@property (nonatomic, readonly) NSInteger occupantsCount;

/**
 *  \~chinese
 *  群组成员是否全部被禁言
 *
 *  \~english
 *  The group is all members muted.
 */
@property (nonatomic, readonly) BOOL isMuteAllMembers;

/*!
 *  \~chinese
 *  获取群组实例，如果不存在则创建
 *
 *  @param aGroupId    群组ID
 *
 *  @result 群组实例
 *
 *  \~english
 *  Get group instance, create a instance if it does not exist
 *
 *  @param aGroupId  Group id
 *
 *  @result Group instance
 */
+ (instancetype)groupWithId:(NSString *)aGroupId;

#pragma mark - EM_DEPRECATED_IOS 3.3.0

/*!
 *  \~chinese
 *  群组的成员列表，需要获取群详情
 *
 *  \~english
 *  Member list of the group,require fetch group's detail first
 */
@property (nonatomic, copy, readonly) NSArray *members EM_DEPRECATED_IOS(3_1_0, 3_3_0, "Use -memberList instead");

/*!
 *  \~chinese
 *  群组的黑名单，需要先调用获取群黑名单方法
 *
 *  需要owner权限才能查看，非owner返回nil
 *
 *  \~english
 *  Group‘s blacklist of blocked users,require call fetch blackList method first
 *
 *  Need owner's authority to access, return nil if user is not the group owner.
 */
@property (nonatomic, strong, readonly) NSArray *blackList EM_DEPRECATED_IOS(3_1_0, 3_3_0, "Use -blacklist instead");

/*!
 *  \~chinese
 *  群组当前的成员数量，需要获取群详情, 包括owner, admins, members
 *
 *  \~english
 *  The total number of group members, require fetch group's detail first, include owner, admins, members
 */
@property (nonatomic, readonly) NSInteger membersCount EM_DEPRECATED_IOS(3_1_0, 3_3_0, "Use -occupantsCount instead");

/*!
 *  \~chinese
 *  群组的主题，需要获取群详情
 *
 *  \~english
 *  Subject of the group, require fetch group's detail first
 */
@property (nonatomic, copy, readonly) NSString *subject EM_DEPRECATED_IOS(3_1_0, 3_6_2, "Use -groupName instead");

#pragma mark - EM_DEPRECATED_IOS < 3.2.3

/*!
 *  \~chinese
 *  初始化群组实例
 *
 *  请使用+groupWithId:方法
 *
 *  @result nil
 *
 *  \~english
 *  Initialize a group instance
 *
 *  Please use [+groupWithId:]
 *
 *  @result nil
 */
- (instancetype)init __deprecated_msg("Use +groupWithId: instead");


/*!
 *  \~chinese
 *  群组的黑名单，需要先调用获取群黑名单方法
 *
 *  需要owner权限才能查看，非owner返回nil
 *
 *  \~english
 *  Group‘s blacklist of blocked users, require call fetch blackList method first
 *
 *  Need owner's authority to access, return nil if user is not the group owner.
 */
@property (nonatomic, strong, readonly) NSArray *bans __deprecated_msg("Use - blackList instead");

@end
