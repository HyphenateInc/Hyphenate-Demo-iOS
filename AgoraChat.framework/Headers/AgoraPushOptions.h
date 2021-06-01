/*!
 *  \~chinese
 *  @header AgoraPushOptions.h
 *  @abstract 消息推送的设置选项
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraPushOptions.h
 *  @abstract Setting options of Apple Push Notification
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import "AgoraCommonDefs.h"

#define kPushNickname @"nickname"
#define kPushDisplayStyle @"notification_display_style"
#define kPushNoDisturbing @"notification_no_disturbing"
#define kPushNoDisturbingStartH @"notification_no_disturbing_start"
#define kPushNoDisturbingStartM @"notification_no_disturbing_startM"
#define kPushNoDisturbingEndH @"notification_no_disturbing_end"
#define kPushNoDisturbingEndM @"notification_no_disturbing_endM"

/*!
 *  \~chinese 
 *  推送消息的显示风格
 *
 *  \~english 
 *  Display style of push message
 */
typedef enum {
    AgoraPushDisplayStyleSimpleBanner = 0, /*! 
                                         *  \~chinese
                                         *  简单显示"您有一条新消息"
                                         *
                                         *  \~english
                                         *  Simply show "You have a new message"
                                         */
    AgoraPushDisplayStyleMessageSummary,   /*! 
                                         *  \~chinese 
                                         *  显示消息内容
                                         * 
                                         *  \~english 
                                         *  Show message's content
                                         */
} AgoraPushDisplayStyle;


/*!
 *  \~chinese 
 *  消息推送的设置选项
 *
 *  \~english 
 *  Apple Push Notification setting options
 */
@interface AgoraPushOptions : NSObject

/*!
 *  \~chinese 
 *  推送消息显示的昵称
 *
 *  \~english 
 *  User's nickname to be displayed in apple push notification service messages
 */
@property (nonatomic, strong, readonly) NSString *displayName;

/*!
 *  \~chinese 
 *  推送消息显示的类型
 *
 *  \~english 
 *  Display style of notification message
 */
@property (nonatomic, readonly) AgoraPushDisplayStyle displayStyle;


/*!
 *  \~chinese 
 *  消息推送免打扰开始时间，小时，暂时只支持整点（小时）
 *
 *  \~english 
 *  No disturbing mode start time (in hour)
 */
@property (nonatomic, readonly) NSInteger noDisturbingStartH;

/*!
 *  \~chinese 
 *  消息推送免打扰结束时间，小时，暂时只支持整点（小时）
 *
 *  \~english 
 *  No disturbing mode end time (in hour)
 */
@property (nonatomic, readonly) NSInteger noDisturbingEndH;

/*!
 *  \~chinese
 *  开启消息免打扰
 *
 *  \~english
 *  Do not disturb messages enable
 */

@property (nonatomic, readonly) BOOL isNoDisturbEnable;


#pragma mark - EM_DEPRECATED_IOS

@property (nonatomic, copy) NSString *nickname EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use - displayName");


typedef enum {
    AgoraPushNoDisturbStatusDay = 0,
    AgoraPushNoDisturbStatusCustom,
    AgoraPushNoDisturbStatusClose,
} AgoraPushNoDisturbStatus EM_DEPRECATED_IOS(3_1_0, 3_7_2, "");

@property (nonatomic) AgoraPushNoDisturbStatus noDisturbStatus EM_DEPRECATED_IOS(3_1_0, 3_7_2, "");




@end
