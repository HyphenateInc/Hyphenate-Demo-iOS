/*!
 *  \~chinese
 *  @header AgoraChatManagerDelegate.h
 *  @abstract 此协议定义了聊天相关的回调
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatManagerDelegate.h
 *  @abstract This protocol defines chat related callbacks
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

@class Message;
@class AgoraError;

/*!
 *  \~chinese
 *  聊天相关回调
 *
 *  \~english
 *  Chat related callbacks
 */
@protocol AgoraChatManagerDelegate <NSObject>

@optional

#pragma mark - Conversation

/*!
 *  \~chinese
 *  会话列表发生变化
 *
 *  @param aConversationList  会话列表<AgoraConversation>
 *
 *  \~english
 *  Delegate method will be invoked when the conversation list has changed
 *
 *  @param aConversationList  Conversation list<AgoraConversation>
 */
- (void)conversationListDidUpdate:(NSArray *)aConversationList;

#pragma mark - Message

/*!
 *  \~chinese
 *  收到消息
 *
 *  @param aMessages  消息列表<Message>
 *
 *  \~english
 *  Invoked when receiving new messages
 *
 *  @param aMessages  Receivecd message list<Message>
 */
- (void)messagesDidReceive:(NSArray *)aMessages;

/*!
 *  \~chinese
 *  收到Cmd消息
 *
 *  @param aCmdMessages  Cmd消息列表<Message>
 *
 *  \~english
 *  Invoked when receiving command messages
 *
 *  @param aCmdMessages  Command message list<Message>
 */
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages;

/*!
 *  \~chinese
 *  收到已读回执
 *
 *  @param aMessages  已读消息列表<Message>
 *
 *  \~english
 *  Invoked when receiving read acknowledgement in message list
 *
 *  @param aMessages  Acknowledged message list<Message>
 */
- (void)messagesDidRead:(NSArray *)aMessages;

/*!
 *  \~chinese
 *  收到群消息已读回执
 *
 *  @param aMessages  已读消息列表<GroupMessageAck>
 *
 *  \~english
 *  Invoked when receiving read acknowledgement in message list
 *
 *  @param aMessages  Acknowledged message list<GroupMessageAck>
 */
- (void)groupMessageDidRead:(Message *)aMessage
                  groupAcks:(NSArray *)aGroupAcks;

/*!
 *  \~chinese
 *  所有群已读消息发生变化
 *
 *  \~english
 *  All group read messages count have changed
 *
 */
- (void)groupMessageAckHasChanged;

/**
 * \~chinese
 * 收到会话已读回调
 *
 * @param from  CHANNEL_ACK 发送方
 * @param to      CHANNEL_ACK 接收方
 *
 * \~english
 * received conversation read ack
 * @param from  the username who send channel_ack
 * @param to      the username who receive channel_ack
 */
- (void)onConversationRead:(NSString *)from to:(NSString *)to;

/*!
 *  \~chinese
 *  收到消息送达回执
 *
 *  @param aMessages  送达消息列表<Message>
 *
 *  \~english
 *  Invoked when receiving delivered acknowledgement in message list
 *
 *  @param aMessages  Acknowledged message list<Message>
 */
- (void)messagesDidDeliver:(NSArray *)aMessages;

/*!
 *  \~chinese
 *  收到消息撤回
 *
 *  @param aMessages  撤回消息列表<Message>
 *
 *  \~english
 * Delegate method will be invoked when receiving recall for message list
 *
 *  @param aMessages  Recall message list<Message>
 */
- (void)messagesDidRecall:(NSArray *)aMessages;

/*!
 *  \~chinese
 *  消息状态发生变化
 *
 *  @param aMessage  状态发生变化的消息
 *  @param aError    出错信息
 *
 *  \~english
 *  Invoked when message status has changed
 *
 *  @param aMessage  Message whose status has changed
 *  @param aError    Error info
 */
- (void)messageStatusDidChange:(Message *)aMessage
                         error:(AgoraError *)aError;

/*!
 *  \~chinese
 *  消息附件状态发生改变
 *
 *  @param aMessage  附件状态发生变化的消息
 *  @param aError    错误信息
 *
 *  \~english
 *  Invoked when message attachment status has changed
 *
 *  @param aMessage  Message attachment status has changed
 *  @param aError    Error
 */
- (void)messageAttachmentStatusDidChange:(Message *)aMessage
                                   error:(AgoraError *)aError;


#pragma mark - Deprecated methods

/*!
 *  \~chinese
 *  会话列表发生变化
 *
 *  @param aConversationList  会话列表<AgoraConversation>
 *
 *  \~english
 *  The conversation list has changed
 *
 *  @param aConversationList  Conversation list<AgoraConversation>
 */
- (void)didUpdateConversationList:(NSArray *)aConversationList __deprecated_msg("Use -conversationListDidUpdate:");

/*!
 *  \~chinese
 *  收到消息
 *
 *  @param aMessages  消息列表<Message>
 *
 *  \~english
 *  Received messages
 *
 *  @param aMessages  Message list<Message>
 */
- (void)didReceiveMessages:(NSArray *)aMessages __deprecated_msg("Use -messagesDidReceive:");

/*!
 *  \~chinese
 *  收到Cmd消息
 *
 *  @param aCmdMessages  Cmd消息列表<Message>
 *
 *  \~english
 *  Received cmd messages
 *
 *  @param aCmdMessages  Cmd message list<Message>
 */
- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages __deprecated_msg("Use -cmdMessagesDidReceive:");

/*!
 *  \~chinese
 *  收到已读回执
 *
 *  @param aMessages  已读消息列表<Message>
 *
 *  \~english
 *  Received read acks
 *
 *  @param aMessages  Read acked message list<Message>
 */
- (void)didReceiveHasReadAcks:(NSArray *)aMessages __deprecated_msg("Use -messagesDidRead:");

/*!
 *  \~chinese
 *  收到消息送达回执
 *
 *  @param aMessages  送达消息列表<Message>
 *
 *  \~english
 *  Received deliver acks
 *
 *  @param aMessages  Deliver acked message list<Message>
 */
- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages __deprecated_msg("Use -messagesDidDeliver:");

/*!
 *  \~chinese
 *  消息状态发生变化
 *
 *  @param aMessage  状态发生变化的消息
 *  @param aError    出错信息
 *
 *  \~english
 *  Message status has changed
 *
 *  @param aMessage  Message whose status changed
 *  @param aError    Error info
 */
- (void)didMessageStatusChanged:(Message *)aMessage
                          error:(AgoraError *)aError __deprecated_msg("Use -messageStatusDidChange:error");

/*!
 *  \~chinese
 *  消息附件状态发生改变
 *  
 *  @param aMessage  附件状态发生变化的消息
 *  @param aError    错误信息
 *
 *  \~english
 *  Attachment status has changed
 *
 *  @param aMessage  Message whose attachment status changed
 *  @param aError    Error
 */
- (void)didMessageAttachmentsStatusChanged:(Message *)aMessage
                                     error:(AgoraError *)aError __deprecated_msg("Use -messageAttachmentStatusDidChange:error");
@end
