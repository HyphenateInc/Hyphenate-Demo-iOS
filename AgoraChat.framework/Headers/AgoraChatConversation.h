/*!
 *  \~chinese
 *  @header AgoraChatConversation.h
 *  @abstract 聊天会话类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatConversation.h
 *  @abstract Chat conversation
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatMessageBody.h"

/*
 *  \~chinese
 *  会话枚举类型
 *
 *  \~english
 *  Conversation type
 */
typedef enum {
    AgoraChatConversationTypeChat  = 0,    /*! \~chinese 单聊会话类型  \~english one-to-one chat type */
    AgoraChatConversationTypeGroupChat,    /*! \~chinese 群聊会话类型  \~english group chat  type*/
    AgoraChatConversationTypeChatRoom      /*! \~chinese 聊天室会话类型  \~english chat room  type*/
} AgoraChatConversationType;

/*
 *  \~chinese
 *  消息搜索方向枚举类型
 *
 *  \~english
 *  Message search direction type
 */
typedef enum {
    AgoraChatMessageSearchDirectionUp  = 0,    /*! \~chinese 向上搜索类型  \~english Search older messages type*/
    AgoraChatMessageSearchDirectionDown        /*! \~chinese 向下搜索类型  \~english Search newer messages type*/
} AgoraChatMessageSearchDirection;

@class AgoraChatMessage;
@class AgoraChatError;

/*!
 *  \~chinese
 *  聊天会话类
 *
 *  \~english
 *  Chat conversation
 */
@interface AgoraChatConversation : NSObject

/*!
 *  \~chinese
 *  会话ID
 *  对于单聊类型，会话ID同时也是对方用户的名称。
 *  对于群聊类型，会话ID同时也是对方群组的ID，并不同于群组的名称。
 *  对于聊天室类型，会话ID同时也是聊天室的ID，并不同于聊天室的名称。
 *  对于HelpDesk类型，会话ID与单聊类型相同，是对方用户的名称。
 *
 *  \~english
 *  conversation ID
 *  For single chat，conversation ID is to chat user's name
 *  For group chat, conversation ID is groupID(), different with getGroupName()
 *  For chat room, conversation ID is chatroom ID, different with chat room name()
 *  For help desk, it is same with single chat, conversationID is also chat user's name
 */
@property (nonatomic, copy, readonly) NSString *conversationId;

/*!
 *  \~chinese
 *  会话类型
 *
 *  \~english
 *  Conversation type
 */
@property (nonatomic, assign, readonly) AgoraChatConversationType type;

/*!
 *  \~chinese
 *  对话中未读取的消息数量
 *
 *  \~english
 *  Unread message count
 */
@property (nonatomic, assign, readonly) int unreadMessagesCount;

/*!
 *  \~chinese
 *  会话扩展属性
 *
 *  \~english
 *  Conversation extension property
 */
@property (nonatomic, copy) NSDictionary *ext;

/*!
 *  \~chinese
 *  会话最新一条消息
 *
 *  \~english
 *  Conversation latest message
 */
@property (nonatomic, strong, readonly) AgoraChatMessage *latestMessage;

/*!
 *  \~chinese
 *  收到的对方发送的最后一条消息，也是会话里的最新消息
 *
 *  @result 消息实例
 *
 *  \~english
 *  Get last received message
 *
 *  @result Message instance
 */
- (AgoraChatMessage *)lastReceivedMessage;

/*!
 *  \~chinese
 *  插入一条消息，消息的conversationId应该和会话的conversationId一致，消息会被插入DB，并且更新会话的latestMessage等属性
 *  insertMessage 会更新对应Conversation里的latestMessage
 *  Method AgoraChatConversation insertMessage:error: = AgoraChatManager importMsessage:completion: + update conversation latest message
 *
 *  @param aMessage 消息实例
 *  @param pError   错误信息
 *
 *  \~english
 *  Insert a message to a conversation in local database and SDK will update the last message automatically
 *  ConversationId of the message should be the same as conversationId of the conversation in order to insert the message into the conversation correctly. The inserting message will be inserted based on timestamp.
 *  Method AgoraChatConversation insertMessage:error: = AgoraChatManager importMsessage:completion: + update conversation latest message
 *
 *  @param aMessage Message
 *  @param pError   Error
 */
- (void)insertMessage:(AgoraChatMessage *)aMessage
                error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  插入一条消息到会话尾部，消息的conversationId应该和会话的conversationId一致，消息会被插入DB，并且更新会话的latestMessage等属性
 *
 *  @param aMessage 消息实例
 *  @param pError   错误信息
 *
 *  \~english
 *  Insert a message to the end of a conversation in local database. ConversationId of the message should be the same as conversationId of the conversation in order to insert the message into the conversation correctly.
 *
 *  @param aMessage Message
 *  @param pError   Error
 *
 */
- (void)appendMessage:(AgoraChatMessage *)aMessage
                error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  删除一条消息
 *
 *  @param aMessageId   要删除消失的ID
 *  @param pError       错误信息
 *
 *  \~english
 *  Delete a message
 *
 *  @param aMessageId   Id of the message to be deleted
 *  @param pError       Error
 *
 */
- (void)deleteMessageWithId:(NSString *)aMessageId
                      error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  删除该会话所有消息，同时清除内存和数据库中的消息
 *
 *  @param pError       错误信息
 *
 *  \~english
 *  Delete all messages of the conversation from memory cache and local database
 *
 *  @param pError       Error
 */
- (void)deleteAllMessages:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  更新本地的消息，不能更新消息ID，消息更新后，会话的latestMessage等属性进行相应更新
 *
 *  @param aMessage 要更新的消息
 *  @param pError   错误信息
 *
 *  \~english
 *  Use this method to update a message in local database. Changing properties will affect data in database
 *  LatestMessage of the conversation and other properties will be updated accordingly. messageId of the message cannot be updated
 *
 *  @param aMessage Message
 *  @param pError   Error
 *
 */
- (void)updateMessageChange:(AgoraChatMessage *)aMessage
                      error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  将消息设置为已读
 *
 *  @param aMessageId   要设置消息的ID
 *  @param pError       错误信息
 *
 *  \~english
 *  Mark a message as read
 *
 *  @param aMessageId   MessageID
 *  @param pError       Error
 *
 */
- (void)markMessageAsReadWithId:(NSString *)aMessageId
                          error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  将所有未读消息设置为已读
 *
 *  @param pError   错误信息
 *
 *  \~english
 *  Mark all messages as read
 *
 *  @param pError   Error
 *
 */
- (void)markAllMessagesAsRead:(AgoraChatError **)pError;


#pragma mark - Load Messages Methods

/*!
 *  \~chinese
 *  获取指定ID的消息
 *
 *  @param aMessageId       消息ID
 *  @param pError           错误信息
 *
 *  \~english
 *  Get a message with the ID
 *
 *  @param aMessageId       MessageID
 *  @param pError           Error
 *
 */
- (AgoraChatMessage *)loadMessageWithId:(NSString *)aMessageId
                           error:(AgoraChatError **)pError;

/*!
 *  \~chinese
 *  从数据库获取指定数量的消息，取到的消息按时间排序，并且不包含参考的消息，如果参考消息的ID为空，则从最新消息取
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aMessageId       参考消息的ID
 *  @param count            获取的条数
 *  @param aDirection       消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Load messages starting from the specified message id from local database. Returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If the aMessageId is nil, will return starting from the latest message
 *
 *  Synchronization method will block the current thread
 *
 *  @param aMessageId       Start loading messages from the specified message id
 *  @param aCount           Max number of messages to load
 *  @param aDirection       Message search direction.
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadMessagesStartFromId:(NSString *)aMessageId
                          count:(int)aCount
                searchDirection:(AgoraChatMessageSearchDirection)aDirection;

/*!
 *  \~chinese
 *  从数据库获取指定数量的消息，取到的消息按时间排序，并且不包含参考的消息，如果参考消息的ID为空，则从最新消息取
 *
 *  @param aMessageId       参考消息的ID
 *  @param count            获取的条数
 *  @param aDirection       消息搜索方向
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Load messages starting from the specified message id from local database. Returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If the aMessageId is nil, will return starting from the latest message
 *
 *  @param aMessageId       Start loading messages from the specified message id
 *  @param aCount           Max number of messages to load
 *  @param aDirection       Message search direction. 
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId; 
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loadMessagesStartFromId:(NSString *)aMessageId
                          count:(int)aCount
                searchDirection:(AgoraChatMessageSearchDirection)aDirection
                     completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从数据库获取指定类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息取，如果aCount小于等于0当作1处理
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aType            消息类型
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aUsername        消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Load messages with specified message type from local database. Returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection.
 *
 *  Synchronization method will block the current thread
 *
 *  @param aType            Message type to load
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load. if aCount<0, will be handled as count=1
 *  @param aUsername        Message sender (optional). Use aUsername=nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadMessagesWithType:(AgoraChatMessageBodyType)aType
                   timestamp:(long long)aTimestamp
                       count:(int)aCount
                    fromUser:(NSString*)aUsername
             searchDirection:(AgoraChatMessageSearchDirection)aDirection;

/*!
 *  \~chinese
 *  从数据库获取指定类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息取，如果aCount小于等于0当作1处理
 *
 *  @param aType            消息类型
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aUsername        消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Load messages with specified message type from local database. Returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection.
 *
 *  @param aType            Message type to load
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load. if aCount<0, will be handled as count=1
 *  @param aUsername        Message sender (optional). Use aUsername=nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loadMessagesWithType:(AgoraChatMessageBodyType)aType
                   timestamp:(long long)aTimestamp
                       count:(int)aCount
                    fromUser:(NSString*)aUsername
             searchDirection:(AgoraChatMessageSearchDirection)aDirection
                  completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从数据库获取包含指定内容的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果aCount小于等于0当作1处理
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aKeywords        搜索关键字，如果为空则忽略
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aSender          消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Load messages with specified keyword from local database, returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  Synchronization method will block the current thread
 *
 *  @param aKeyword         Search keyword. aKeyword=nil to ignore
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load
 *  @param aSender          Message sender (optional). Pass nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadMessagesWithKeyword:(NSString*)aKeyword
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString*)aSender
                searchDirection:(AgoraChatMessageSearchDirection)aDirection;

/*!
 *  \~chinese
 *  从数据库获取包含指定内容的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果aCount小于等于0当作1处理
 *
 *  @param aKeywords        搜索关键字，如果为空则忽略
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aSender          消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Load messages with specified keyword from local database, returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  @param aKeyword         Search keyword. aKeyword=nil to ignore
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load
 *  @param aSender          Message sender (optional). Pass nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loadMessagesWithKeyword:(NSString*)aKeyword
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString*)aSender
                searchDirection:(AgoraChatMessageSearchDirection)aDirection
                     completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从数据库获取包含指定内容的自定义消息，如果参考的时间戳为负数，则从最新消息向前取，如果aCount小于等于0当作1处理
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aKeywords        搜索关键字，如果为空则忽略
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aSender          消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *
 *  \~english
 *  Load custom messages with specified keyword from local database,returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  Synchronization method will block the current thread
 *
 *  @param aKeyword         Search keyword. aKeyword=nil to ignore
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load
 *  @param aSender          Message sender (optional). Pass nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadCustomMsgWithKeyword:(NSString*)aKeyword
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString*)aSender
                 searchDirection:(AgoraChatMessageSearchDirection)aDirection;

/*!
 *  \~chinese
 *  从数据库获取包含指定内容的自定义消息，如果参考的时间戳为负数，则从最新消息向前取，如果aCount小于等于0当作1处理
 *
 *  @param aKeywords        搜索关键字，如果为空则忽略
 *  @param aTimestamp       参考时间戳
 *  @param aCount           获取的条数
 *  @param aSender          消息发送方，如果为空则忽略
 *  @param aDirection       消息搜索方向
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Load custom messages with specified keyword from local database,returning messages are sorted by receiving timestamp based on AgoraChatMessageSearchDirection. If reference timestamp is negative, load from the latest messages; if message count is negative, will be handled as count=1
 *
 *  @param aKeyword         Search keyword. aKeyword=nil to ignore
 *  @param aTimestamp       load based on reference timestamp. If aTimestamp=-1, will load from the most recent (the latest) message
 *  @param aCount           Max number of messages to load
 *  @param aSender          Message sender (optional). Pass nil to ignore
 *  @param aDirection       Message search direction
                            AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
                            AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId *  ----
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loadCustomMsgWithKeyword:(NSString*)aKeyword
                       timestamp:(long long)aTimestamp
                           count:(int)aCount
                        fromUser:(NSString*)aSender
                 searchDirection:(AgoraChatMessageSearchDirection)aDirection
                      completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从数据库获取指定时间段内的消息，取到的消息按时间排序，为了防止占用太多内存，用户应当制定加载消息的最大数
 *
 *  同步方法，会阻塞当前线程
 *
 *  @param aStartTimestamp  毫秒级开始时间
 *  @param aEndTimestamp    结束时间
 *  @param aCount           加载消息最大数
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *
 *  \~english
 *  Load messages within specified time range from local database. Returning messages are sorted by sending timestamp
 *
 *  Synchronization method will block the current thread
 *
 *  @param aStartTimestamp  Starting timestamp in miliseconds
 *  @param aEndTimestamp    Ending timestamp in miliseconds
 *  @param aCount           Max number of messages to load
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount;

/*!
 *  \~chinese
 *  从数据库获取指定时间段内的消息，取到的消息按时间排序，为了防止占用太多内存，用户应当制定加载消息的最大数
 *
 *  @param aStartTimestamp  毫秒级开始时间
 *  @param aEndTimestamp    结束时间
 *  @param aCount           加载消息最大数
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Load messages within specified time range from local database. Returning messages are sorted by sending timestamp
 *
 *  @param aStartTimestamp  Starting timestamp in miliseconds
 *  @param aEndTimestamp    Ending timestamp in miliseconds
 *  @param aCount           Max number of messages to load
 *  @param aCompletionBlock The callback of completion block
 *
 */
- (void)loadMessagesFrom:(long long)aStartTimestamp
                      to:(long long)aEndTimestamp
                   count:(int)aCount
              completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

#pragma mark - Deprecated methods

/*!
 *  \~chinese
 *  插入一条消息，消息的conversationId应该和会话的conversationId一致，消息会被插入DB，并且更新会话的latestMessage等属性
 *
 *  @param aMessage  消息实例
 *
 *  @result 是否成功   YES: 插入成功  NO: 插入失败
 *
 *  \~english
 *  Insert a message to a conversation. ConversationId of the message should be the same as conversationId of the conversation in order to insert the message into the conversation correctly.
 *
 *  @param aMessage  Message
 *
 *  @result Message insert result,  YES:  mean success,  NO:  mean failure.
 */
- (BOOL)insertMessage:(AgoraChatMessage *)aMessage __deprecated_msg("Use -insertMessage:error: instead");

/*!
 *  \~chinese
 *  插入一条消息到会话尾部，消息的conversationId应该和会话的conversationId一致，消息会被插入DB，并且更新会话的latestMessage等属性
 *
 *  @param aMessage  消息实例
 *
 *  @result 是否成功  YES: 插入成功  NO: 插入失败
 *
 *  \~english
 *  Insert a message to the tail of conversation, message's conversationId should equle to conversation's conversationId, message will be inserted to DB, and update conversation's property
 *
 *  @param aMessage  Message
 *
 *  @result Message insert result,  YES:  mean success,  NO:  mean failure.
 */
- (BOOL)appendMessage:(AgoraChatMessage *)aMessage __deprecated_msg("Use -appendMessage:error: instead");

/*!
 *  \~chinese
 *  删除一条消息
 *
 *  @param aMessageId  要删除消息的ID
 *
 *  @result 是否成功  YES: 删除成功  NO: 删除失败
 *
 *  \~english
 *  Delete a message
 *
 *  @param aMessageId  Message's ID who will be deleted
 *
 *  @result Message delete result, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)deleteMessageWithId:(NSString *)aMessageId __deprecated_msg("Use -deleteMessageWithId:error: instead");

/*!
 *  \~chinese
 *  删除该会话所有消息
 *
 *  @result 是否成功 YES: 删除成功  NO: 删除失败
 *
 *  \~english
 *  Delete all message of the conversation
 *
 *  @result Delete result, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)deleteAllMessages __deprecated_msg("Use -deleteAllMessages: instead");

/*!
 *  \~chinese
 *  更新一条消息，不能更新消息ID，消息更新后，会话的latestMessage等属性进行相应更新
 *
 *  @param aMessage  要更新的消息
 *
 *  @result 是否成功   YES: 更新成功  NO: 更新失败
 *
 *  \~english
 *  Update a message, can't update message's messageId, conversation's latestMessage and so on properties will update after update the message
 *
 *  @param aMessage  Message
 *
 *  @result Message update result, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)updateMessage:(AgoraChatMessage *)aMessage __deprecated_msg("Use -updateMessageChange:error: instead");

/*!
 *  \~chinese
 *  将消息设置为已读
 *
 *  @param aMessageId  要设置消息的ID
 *
 *  @result 是否成功。 YES: 更新成功  NO: 更新失败
 *
 *  \~english
 *  Mark a message as read
 *
 *  @param aMessageId  Message's ID who will be set read status
 *
 *  @result Result of mark message as read, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)markMessageAsReadWithId:(NSString *)aMessageId __deprecated_msg("Use -markMessageAsReadWithId:error: instead");

/*!
 *  \~chinese
 *  将所有未读消息设置为已读
 *
 *  @result 是否成功  YES: 更新成功  NO: 更新失败
 *
 *  \~english
 *  Mark all message as read
 *
 *  @result Result of mark all message as read, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)markAllMessagesAsRead __deprecated_msg("Use -markAllMessagesAsRead: instead");

/*!
 *  \~chinese
 *  更新会话扩展属性到DB
 *
 *  @result 是否成功     YES: 更新成功  NO: 更新失败
 *
 *
 *  \~english
 *  Update conversation extend properties to DB
 *
 *  @result Extend properties update result, YES:  mean success,  NO:  mean failure.
 */
- (BOOL)updateConversationExtToDB __deprecated_msg("setExt: will update extend properties to DB");

/*!
 *  \~chinese
 *  获取指定ID的消息
 *
 *  @param aMessageId  消息ID
 *
 *  @result 消息
 *
 *  \~english
 *  Get a message with the ID
 *
 *  @param aMessageId  Message's id
 *
 *  @result Message instance
 */
- (AgoraChatMessage *)loadMessageWithId:(NSString *)aMessageId __deprecated_msg("Use -loadMessageWithId:error: instead");

/*!
 *  \~chinese
 *  从数据库获取指定数量的消息，取到的消息按时间排序，并且不包含参考的消息，如果参考消息的ID为空，则从最新消息向前取
 *
 *  @param aMessageId  参考消息的ID
 *  @param aLimit      获取的条数
 *  @param aDirection  消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Get more messages from DB, result messages are sorted by receive time, and NOT include the reference message, if reference messag's ID is nil, will fetch message from latest message
 *
 *  @param aMessageId  Reference message's ID
 *  @param aLimit      Count of messages to load
 *  @param aDirection  Message search direction
 *
 *  @result Message NSArray<AgoraChatMessage>
 */
- (NSArray *)loadMoreMessagesFromId:(NSString *)aMessageId
                              limit:(int)aLimit
                          direction:(AgoraChatMessageSearchDirection)aDirection __deprecated_msg("Use -loadMessagesStartFromId:count:searchDirection:completion: instead");

/*!
 *  \~chinese
 *  从数据库获取指定类型的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果aLimit是负数，则获取所有符合条件的消息
 *
 *  @param aType        消息类型
 *  @param aTimestamp   参考时间戳
 *  @param aLimit       获取的条数
 *  @param aSender      消息发送方，如果为空则忽略
 *  @param aDirection   消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Get more messages with specified type from DB, result messages are sorted by received time, if reference timestamp is negative, will fetch message from latest message, andd will fetch all messages that meet the condition if aLimit is negative
 *
 *  @param aType        Message type to load
 *  @param aTimestamp   Reference timestamp
 *  @param aLimit       Count of messages to load
 *  @param aSender      Message sender, will ignore it if it's empty
 *  @param aDirection   Message search direction
 *
 *  @result Message NSArray<AgoraChatMessage>
 */
- (NSArray *)loadMoreMessagesWithType:(AgoraChatMessageBodyType)aType
                               before:(long long)aTimestamp
                                limit:(int)aLimit
                                 from:(NSString*)aSender
                            direction:(AgoraChatMessageSearchDirection)aDirection __deprecated_msg("Use -loadMessagesWithType:timestamp:count:fromUser:searchDirection:completion: instead");

/*!
 *  \~chinese
 *  从数据库获取包含指定内容的消息，取到的消息按时间排序，如果参考的时间戳为负数，则从最新消息向前取，如果aLimit是负数，则获取所有符合条件的消息
 *
 *  @param aKeywords    搜索关键字，如果为空则忽略
 *  @param aTimestamp   参考时间戳
 *  @param aLimit       获取的条数
 *  @param aSender      消息发送方，如果为空则忽略
 *  @param aDirection   消息搜索方向
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Get more messages contain specified keywords from DB, result messages are sorted by received time, if reference timestamp is negative, will fetch message from latest message, andd will fetch all messages that meet the condition if aLimit is negative
 *
 *  @param aKeywords    Search content, will ignore it if it's empty
 *  @param aTimestamp   Reference timestamp
 *  @param aLimit       Count of messages to load
 *  @param aSender      Message sender, will ignore it if it's empty
 *  @param aDirection    Message search direction
 *
 *  @result Message NSArray<AgoraChatMessage>
 */
- (NSArray *)loadMoreMessagesContain:(NSString*)aKeywords
                              before:(long long)aTimestamp
                               limit:(int)aLimit
                                from:(NSString*)aSender
                           direction:(AgoraChatMessageSearchDirection)aDirection __deprecated_msg("Use -loadMessagesContainKeywords:timestamp:count:fromUser:searchDirection:completion: instead");

/*!
 *  \~chinese
 *  从数据库获取指定时间段内的消息，取到的消息按时间排序，为了防止占用太多内存，用户应当制定加载消息的最大数
 *
 *  @param aStartTimestamp  毫秒级开始时间
 *  @param aEndTimestamp    结束时间
 *  @param aMaxCount        加载消息最大数
 *
 *  @result 消息列表<AgoraChatMessage>
 *
 *  \~english
 *  Load messages from DB in duration, result messages are sorted by receive time, user should limit the max count to load to avoid memory issue
 *
 *  @param aStartTimestamp  Start time's timestamp in miliseconds
 *  @param aEndTimestamp    End time's timestamp in miliseconds
 *  @param aMaxCount        Message search direction
 *
 *  @result Message NSArray<AgoraChatMessage>
 */
- (NSArray *)loadMoreMessagesFrom:(long long)aStartTimestamp
                               to:(long long)aEndTimestamp
                         maxCount:(int)aMaxCount __deprecated_msg("Use -loadMessagesFrom:to:count:completion: instead");

/*!
 *  \~chinese
 *  收到的对方发送的最后一条消息
 *
 *  @result 消息实例
 *
 *  \~english
 *  Get latest message that received from others
 *
 *  @result Message instance
 */
- (AgoraChatMessage *)latestMessageFromOthers __deprecated_msg("Use -lastReceivedMessage instead");

@end
