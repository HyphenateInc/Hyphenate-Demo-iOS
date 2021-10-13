/*!
 *  \~chinese
 *  @header AgoraChatGroupOptions.h
 *  @abstract 群组属性选项
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatGroupOptions.h
 *  @abstract Group property options
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#define KSDK_GROUP_MINUSERSCOUNT 3
#define KSDK_GROUP_USERSCOUNTDEFAULT 200

/*!
 *  \~chinese 
 *  群组枚举类型
 *
 *  \~english
 *  Group type
 */
typedef enum{
    AgoraChatGroupStylePrivateOnlyOwnerInvite  = 0,    /*! \~chinese 私有群组类型，只允许Owner邀请用户加入 \~english Private groups, only owner can invite users to join */
    AgoraChatGroupStylePrivateMemberCanInvite,         /*! \~chinese 私有群组类型，Owner和群成员均可邀请用户加入 \~english Private groups, both owner and members can invite users to join  */
    AgoraChatGroupStylePublicJoinNeedApproval,         /*! \~chinese 公开群组类型，Owner可以邀请用户加入; 非群成员用户发送入群申请，经Owner同意后才能入组 \~english Public groups, owner can invite users to join; User can join group after owner approves user's group request */
    AgoraChatGroupStylePublicOpenJoin,                 /*! \~chinese 公开群组类型，用户可以自由加入 \~english Public groups, user can join the group freely */
}AgoraChatGroupStyle;

/*!
 *  \~chinese
 *  群组属性选项
 *
 *  \~english
 *  Group options
 */
@interface AgoraChatGroupOptions : NSObject

/*!
 *  \~chinese
 *  群组的类型
 *
 *  \~english
 *  Group style
 */
@property (nonatomic) AgoraChatGroupStyle style;

/*!
 *  \~chinese
 *  群组的最大成员数(3 - 2000，默认是200)
 *
 *  \~english
 *  The group capacity (3-2000, the default is 200)
 */
@property (nonatomic) NSInteger maxUsersCount;

/*!
 *  \~chinese
 *  邀请群成员时，是否需要发送邀请通知. 若NO，被邀请的人自动加入群组
 *
 *  \~english
 *  When you invite a group member, do you need to send an invitation notification. if NO , means joined Automatically 
 */
@property (nonatomic) BOOL IsInviteNeedConfirm;

/*!
 *  \~chinese
 *  扩展信息
 *
 *  \~english
 *  Extended of the group
 */
@property (nonatomic, strong) NSString *ext;

@end
