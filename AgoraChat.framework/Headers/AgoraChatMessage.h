/*!
 *  \~chinese
 *  @header AgoraChatMessage.h
 *  @abstract 聊天消息
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatMessage.h
 *  @abstract Chat message
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatMessageBody.h"

/*!
 *  \~chinese
 *  聊天枚举类型
 *
 *  \~english
 *  Chat type
 */
typedef enum {
    AgoraChatTypeChat   = 0,   /*! \~chinese 单聊消息类型  \~english one to one chat type */
    AgoraChatTypeGroupChat,    /*! \~chinese 群聊消息类型  \~english Group chat type */
    AgoraChatTypeChatRoom,     /*! \~chinese 聊天室消息类型  \~english Chatroom chat type */
} AgoraChatType;

/*!
 *  \~chinese
 *  消息发送状态枚举类型
 *
 *  \~english
 *   Message delivery status type
 */
typedef enum {
    AgoraChatMessageStatusPending  = 0,    /*! \~chinese 发送未开始类型 \~english Pending type*/
    AgoraChatMessageStatusDelivering,      /*! \~chinese 正在发送类型 \~english Delivering type*/
    AgoraChatMessageStatusSucceed,         /*! \~chinese 发送成功类型 \~english Succeed type*/
    AgoraChatMessageStatusFailed,          /*! \~chinese 发送失败类型 \~english Failed type*/
} AgoraChatMessageStatus;

/*!
 *  \~chinese
 *  消息方向枚举类型
 *
 *  \~english
 *  Message direction  type
 */
typedef enum {
    AgoraChatMessageDirectionSend = 0,    /*! \~chinese 发送的消息类型 \~english Send type*/
    AgoraChatMessageDirectionReceive,     /*! \~chinese 接收的消息类型 \~english Receive type*/
} AgoraChatMessageDirection;

/*!
 *  \~chinese
 *  聊天消息类
 *
 *  \~english
 *  Chat message
 */
@interface AgoraChatMessage : NSObject

/*!
 *  \~chinese
 *  消息的唯一标识符
 *
 *  \~english
 *  Unique identifier of the message
 */
@property (nonatomic, copy) NSString *messageId;

/*!
 *  \~chinese
 *  所属会话的唯一标识符
 *
 *  \~english
 *  Unique identifier of conversation, the message's container object
 */
@property (nonatomic, copy) NSString *conversationId;

/*!
 *  \~chinese
 *  消息的方向
 *
 *  \~english
 *  Message delivery direction
 */
@property (nonatomic) AgoraChatMessageDirection direction;

/*!
 *  \~chinese
 *  发送方
 *
 *  \~english
 *  Message sender
 */
@property (nonatomic, copy) NSString *from;

/*!
 *  \~chinese
 *  接收方
 *
 *  \~english
 *  Message receiver
 */
@property (nonatomic, copy) NSString *to;

/*!
 *  \~chinese
 *  时间戳，服务器收到此消息的时间
 *
 *  \~english
 *  Timestamp, the time of server received the message
 */
@property (nonatomic) long long timestamp;

/*!
 *  \~chinese
 *  客户端发送/收到此消息的时间
 *
 *  \~english
 *  The time of client sends/receives the message
 */
@property (nonatomic) long long localTime;

/*!
 *  \~chinese
 *  消息类型
 *
 *  \~english
 *  Chat type
 */
@property (nonatomic) AgoraChatType chatType;

/*!
 *  \~chinese
 *  消息状态类型
 *
 *  \~english
 *  Message delivery status type
 */
@property (nonatomic) AgoraChatMessageStatus status;

/*!
 *  \~chinese
 *  已读回执是否已发送/收到, 对于发送方表示是否已经收到已读回执，对于接收方表示是否已经发送已读回执
 *
 *  \~english
 *  Acknowledge if the message is read by the receipient. It indicates whether the sender has received a message read acknowledgement; or whether the recipient has sent a message read acknowledgement
 */
@property (nonatomic) BOOL isReadAcked;

/*!
 *  \~chinese
 *  是否需要群组确认
 *
 *  \~english
 *  Whether need group confirmation
 */
@property (nonatomic) BOOL isNeedGroupAck;

/*!
 *  \~chinese
 *  群组确认消息数量
 *
 *  \~english
 *  Number of group confirmation messages
 */
@property (nonatomic, readonly) int groupAckCount;

/*!
 *  \~chinese
 *  送达回执是否已发送/收到，对于发送方表示是否已经收到送达回执，对于接收方表示是否已经发送送达回执，如果AgoraChatOptions设置了enableDeliveryAck，SDK收到消息后会自动发送送达回执
 *
 *  \~english
 *  Acknowledge if the message is delivered. It indicates whether the sender has received a message deliver acknowledgement; or whether the recipient has sent a message deliver acknowledgement. SDK will automatically send delivery acknowledgement if AgoraChatOptions is set to enableDeliveryAck
 */
@property (nonatomic) BOOL isDeliverAcked;

/*!
 *  \~chinese
 *  是否已读
 *
 *  \~english
 *  Whether the message has been read
 */
@property (nonatomic) BOOL isRead;

/*!
 *  \~chinese
 *  语音消息是否已听
 *
 *  \~english
 *  Whether the message has been listen
 */
@property (nonatomic) BOOL isListened;

/*!
 *  \~chinese
 *  消息体
 *
 *  \~english
 *  Message body
 */
@property (nonatomic, strong) AgoraChatMessageBody *body;

/*!
 *  \~chinese
 *  消息扩展
 *
 *  Key值类型必须是NSString, Value值类型必须是NSString或者 NSNumber类型的 BOOL, int, unsigned in, long long, double.
 *
 *  \~english
 *  Message extension
 *
 *  Key type must be NSString. Value type must be NSString, or NSNumber object (including int, unsigned in, long long, double, use NSNumber (@YES/@NO) instead of BOOL).
 */
@property (nonatomic, copy) NSDictionary *ext;

/*!
 *  \~chinese
 *  初始化消息实例
 *
 *  @param aConversationId  会话ID
 *  @param aFrom            发送方
 *  @param aTo              接收方
 *  @param aBody            消息体实例
 *  @param aExt             扩展信息
 *
 *  @result 消息实例
 *
 *  \~english
 *  Initialize a message instance
 *
 *  @param aConversationId  Conversation id
 *  @param aFrom             Sender
 *  @param aTo                  Receiver
 *  @param aBody             Message body
 *  @param aExt               Message extention
 *
 *  @result Message instance
 */
- (id)initWithConversationID:(NSString *)aConversationId
                        from:(NSString *)aFrom
                          to:(NSString *)aTo
                        body:(AgoraChatMessageBody *)aBody
                         ext:(NSDictionary *)aExt;


@end
