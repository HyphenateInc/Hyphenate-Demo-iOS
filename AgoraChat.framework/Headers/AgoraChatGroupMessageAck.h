//
//  AgoraChatGroupMessageAck.h
//  HyphenateSDK
//
//  Created by 杜洁鹏 on 2019/6/3.
//  Copyright © 2019 easemob.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 *  \~chinese
 *  群组消息的确认类
 *
 *  \~english
 *  Apple Push Notification Service setting options
 */
@interface AgoraChatGroupMessageAck : NSObject

/*!
 *  \~chinese
 *  群组消息ID
 *
 *  \~english
 *  Group message id
 */
@property (nonatomic, copy) NSString *messageId;

/*!
 *  \~chinese
 *  群组消息发送者
 *
 *  \~english
 *  Group message sender
 */
@property (nonatomic, copy) NSString *from;

/*!
 *  \~chinese
 *  群组消息内容
 *
 *  \~english
 *  Group message content
 */
@property (nonatomic, copy) NSString *content;

/*!
 *  \~chinese
 *  群组消息已读消息数量
 *
 *  \~english
 *  Group message has read count
 */
@property (nonatomic) int readCount;

/*!
 *  \~chinese
 *  群组消息时间戳
 *
 *  \~english
 *  Group message timestamp
 */
@property (nonatomic) long long timestamp;

@end

NS_ASSUME_NONNULL_END
