/*!
 *  \~chinese
 *  @header IAgoraChatManager.h
 *  @abstract 聊天相关操作代理协议
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header IAgoraChatManager.h
 *  @abstract This protocol defines the operations of chat
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatCommonDefs.h"
#import "AgoraChatManagerDelegate.h"
#import "AgoraChatConversation.h"

#import "AgoraChatMessage.h"
#import "AgoraChatTextMessageBody.h"
#import "AgoraChatLocationMessageBody.h"
#import "AgoraChatCmdMessageBody.h"
#import "AgoraChatFileMessageBody.h"
#import "AgoraChatImageMessageBody.h"
#import "AgoraChatVoiceMessageBody.h"
#import "AgoraChatVideoMessageBody.h"
#import "AgoraChatCustomMessageBody.h"
#import "AgoraChatCursorResult.h"

#import "AgoraChatGroupMessageAck.h"

@class AgoraChatError;

/*!
 *  \~chinese
 *  聊天相关操作代理协议
 *  目前消息都是从DB中加载，沒有从server端加载
 *
 *  \~english
 *  This protocol defines the operations of chat
 *  Current message are loaded from local database, not from server
 */
@protocol IAgoraChatManager <NSObject>

@required

#pragma mark - Delegate

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  实现代理协议的对象
 *  @param aQueue     执行代理方法的队列
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Objects that implement the  protocol
 *  @param aQueue     (optional) The queue of calling delegate methods. Pass in nil to run on main thread.
 */
- (void)addDelegate:(id<AgoraChatManagerDelegate>)aDelegate
      delegateQueue:(dispatch_queue_t)aQueue;

/*!
 *  \~chinese
 *  移除回调代理
 *
 *  @param aDelegate  要移除的代理
 *
 *  \~english
 *  Remove delegate
 *
 *  @param aDelegate  Delegate  to be removed
 */
- (void)removeDelegate:(id<AgoraChatManagerDelegate>)aDelegate;

#pragma mark - Conversation

/*!
 *  \~chinese
 *  获取所有会话，如果内存中不存在会从DB中加载
 *
 *  @result 会话列表<AgoraChatConversation>
 *
 *  \~english
 *  Get all conversations from local databse. Will load conversations from cache first, otherwise local database
 *
 *  @result Conversation NSArray<AgoraChatConversation>
 */
- (NSArray *)getAllConversations;

/*!
 *  \~chinese
 *  从服务器获取所有会话
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Get all conversations from  server
 */
- (void)getConversationsFromServer:(void (^)(NSArray *aCoversations, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  从本地数据库中获取一个已存在的会话
 *
 *  @param aConversationId  会话ID
 *
 *  @result 会话对象
 *
 *  \~english
 *  Get a conversation from local database
 *
 *  @param aConversationId  Conversation id
 *
 *  @result Conversation  object
 */
- (AgoraChatConversation *)getConversationWithConvId:(NSString *)aConversationId;

/*!
 *  \~chinese
 *  获取一个会话
 *
 *  @param aConversationId  会话ID
 *  @param aType            会话类型
 *  @param aIfCreate        如果不存在是否创建
 *
 *  @result 会话对象
 *
 *  \~english
 *  Get a conversation from local database
 *
 *  @param aConversationId  Conversation id
 *  @param aType            Conversation type (Must be specified)
 *  @param aIfCreate        Whether create conversation if not exist
 *
 *  @result Conversation
 */
- (AgoraChatConversation *)getConversation:(NSString *)aConversationId
                               type:(AgoraChatConversationType)aType
                   createIfNotExist:(BOOL)aIfCreate;

/*!
 *  \~chinese
 *  删除会话
 *
 *  @param aConversationId      会话ID
 *  @param aIsDeleteMessages    是否删除会话中的消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Delete a conversation from local database
 *
 *  @param aConversationId      Conversation id
 *  @param aIsDeleteMessages    if delete messages
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)deleteConversation:(NSString *)aConversationId
          isDeleteMessages:(BOOL)aIsDeleteMessages
                completion:(void (^)(NSString *aConversationId, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  删除一组会话
 *
 *  @param aConversations       会话列表<AgoraChatConversation>
 *  @param aIsDeleteMessages    是否删除会话中的消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Delete multiple conversations
 *
 *  @param aConversations       Conversation NSArray<AgoraChatConversation>
 *  @param aIsDeleteMessages    Whether delete messages
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)deleteConversations:(NSArray *)aConversations
           isDeleteMessages:(BOOL)aIsDeleteMessages
                 completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  导入一组会话到DB
 *
 *  @param aConversations   会话列表<AgoraChatConversation>
 *  @param aCompletionBlock 完成的回调
 *
 *
 *  \~english
 *  Import multiple conversations to local database
 *
 *  @param aConversations       Conversation NSArray<AgoraChatConversation>
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)importConversations:(NSArray *)aConversations
                 completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

#pragma mark - Message

/*!
 *  \~chinese
 *  获取指定的消息
 *
 *  @param aMessageId   消息ID
 *
 *
 *  \~english
 *  Get the specified message
 *
 *  @param aMessageId    Message id
 *
 */
- (AgoraChatMessage *)getMessageWithMessageId:(NSString *)aMessageId;

/*!
 *  \~chinese
 *  获取消息附件路径，存在这个路径的文件，删除会话时会被删除
 *
 *  @param aConversationId  会话ID
 *
 *  @result 附件路径
 *
 *  \~english
 *  Get message attachment local path for the conversation. Delete the conversation will also delete the files under the file path
 *
 *  @param aConversationId  Conversation id
 *
 *  @result Attachment path
 */
- (NSString *)getMessageAttachmentPath:(NSString *)aConversationId;

/*!
 *  \~chinese
 *  导入一组消息到DB
 *
 *  @param aMessages        消息列表<AgoraChatMessage>
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Import multiple messages to local database
 *
 *  @param aMessages            Message NSArray<AgoraChatMessage>
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)importMessages:(NSArray *)aMessages
            completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  更新消息到DB
 *
 *  @param aMessage         消息
 *  @param aCompletionBlock 完成的回调
 *
 *  \~english
 *  Update a message in local database. latestMessage of the conversation and other properties will be updated accordingly. messageId of the message cannot be updated
 *
 *  @param aMessage             Message
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)updateMessage:(AgoraChatMessage *)aMessage
           completion:(void (^)(AgoraChatMessage *aMessage, AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  发送消息已读回执
 *
 *  异步方法
 *
 *  @param aMessage             消息id
 *  @param aUsername            已读接收方
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Send read acknowledgement for message
 *
 *  @param aMessageId           Message id
 *  @param aUsername            ack receiver
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)sendMessageReadAck:(NSString *)aMessageId
                    toUser:(NSString *)aUsername
                completion:(void (^)(AgoraChatError *aError))aCompletionBlock;


/*!
 *  \~chinese
 *  发送群消息已读回执
 *
 *  异步方法
 *
 *  @param aMessageId           消息id
 *  @param aGroupId             群id
 *  @param aContent             附加消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Send read acknowledgement for message
 *
 *  @param aMessageId           Message id
 *  @param aGroupId             group receiver
 *  @param aContent             Content
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)sendGroupMessageReadAck:(NSString *)aMessageId
                        toGroup:(NSString *)aGroupId
                        content:(NSString *)aContent
                     completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  发送会话已读消息，将通知服务器将此会话未读数置为0，针对单聊会话
 *  对话方（包含多端多设备）将会在回调方法 AgoraChatManagerDelegate onConversationRead(String, String) 中接收到回调
 *
 *  建议：此方法可以在进入聊天页面时有大量未读消息时调用，减少调用本方法的次数
 *  在聊天过程中调用 sendMessageReadAck 发送消息已读
 *
 *  异步方法
 *
 *  @param conversationId            会话id
 *  @param aCompletionBlock       完成的回调
 *
 *  \~english
 *  Send read conversation ack to server, or single chat session which makes the conversation read
 *  The conversation (including multiple devices) will receive a callback in the callback agency AgoraChatManagerDelegate onConversationRead(String, String)
 *
 *  Suggestion: This method can be called when entering the chat page with a large number of unread messages, reducing the number of calls to this method
 *  Call sendMessageReadAck during chat to send the message read
 *
 *  @param conversationId             conversation id
 *  @param aCompletionBlock         The callback of completion block
 * 
 */
- (void)ackConversationRead:(NSString *)conversationId
                 completion:(void (^)(AgoraChatError *aError))aCompletionBlock;

/*!
 *  \~chinese
 *  撤回消息
 *
 *  异步方法
 *
 *  @param aMessageId           消息ID
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Recall a message
 *
 *
 *  @param aMessageId           Message id
 *  @param aCompletionBlock     The callback block of completion
 *
 */
- (void)recallMessageWithMessageId:(NSString *)aMessageId
                        completion:(void (^)(AgoraChatError *aError))aCompletionBlock;


/*!
 *  \~chinese
 *  发送消息
 *
 *  @param aMessage         消息
 *  @param aProgressBlock   附件上传进度回调block
 *  @param aCompletionBlock 发送完成回调block
 *
 *  \~english
 *  Send a message
 *
 *  @param aMessage             Message instance
 *  @param aProgressBlock       The block of attachment upload progress in percentage, 0~100.
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)sendMessage:(AgoraChatMessage *)aMessage
           progress:(void (^)(int progress))aProgressBlock
         completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  重新发送消息
 *
 *  @param aMessage         消息对象
 *  @param aProgressBlock   附件上传进度回调block
 *  @param aCompletionBlock 发送完成回调block
 *
 *  \~english
 *  Resend Message
 *
 *  @param aMessage             Message object
 *  @param aProgressBlock       The callback block of attachment upload progress
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)resendMessage:(AgoraChatMessage *)aMessage
             progress:(void (^)(int progress))aProgressBlock
           completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  下载缩略图（图片消息的缩略图或视频消息的第一帧图片），SDK会自动下载缩略图，所以除非自动下载失败，用户不需要自己下载缩略图
 *
 *  @param aMessage            消息对象
 *  @param aProgressBlock      附件下载进度回调block
 *  @param aCompletionBlock    下载完成回调block
 *
 *  \~english
 *  Manual download the message thumbnail (thumbnail of image message or first frame of video image).
 *  SDK handles the thumbnail downloading automatically, no need to download thumbnail manually unless automatic download failed.
 *
 *  @param aMessage             Message object
 *  @param aProgressBlock       The callback block of attachment download progress
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)downloadMessageThumbnail:(AgoraChatMessage *)aMessage
                        progress:(void (^)(int progress))aProgressBlock
                      completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;

/*!
 *  \~chinese
 *  下载消息附件（语音，视频，图片原图，文件），SDK会自动下载语音消息，所以除非自动下载语音失败，用户不需要自动下载语音附件
 *
 *  异步方法
 *
 *  @param aMessage            消息
 *  @param aProgressBlock      附件下载进度回调block
 *  @param aCompletionBlock    下载完成回调block
 *
 *  \~english
 *  Download message attachment (voice, video, image or file). SDK handles attachment downloading automatically, no need to download attachment manually unless automatic download failed
 *
 *  @param aMessage             Message object
 *  @param aProgressBlock       The callback block of attachment download progress
 *  @param aCompletionBlock     The callback of completion block
 */
- (void)downloadMessageAttachment:(AgoraChatMessage *)aMessage
                         progress:(void (^)(int progress))aProgressBlock
                       completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletionBlock;



/**
 *  \~chinese
 *  从服务器获取指定会话的历史消息
 *
 *  @param  aConversationId     要获取漫游消息的Conversation ID
 *  @param  aConversationType   要获取漫游消息的Conversation type
 *  @param  aStartMessageId     参考起始消息的ID
 *  @param  aPageSize           获取消息条数
 *  @param  pError              错误信息
 *
 *  @result     获取的消息结果
 *
 *
 *  \~english
 *  Fetch conversation roam messages from server.
 
 *  @param aConversationId      The conversation id which select to fetch roam message.
 *  @param aConversationType    The conversation type which select to fetch roam message.
 *  @param aStartMessageId      The start search roam message id, if empty start from the server leastst message.
 *  @param aPageSize            The page size.
 *  @param pError               AgoraChatError used for output.
 *
 *  @result    The result
 */
- (AgoraChatCursorResult *)fetchHistoryMessagesFromServer:(NSString *)aConversationId
                                  conversationType:(AgoraChatConversationType)aConversationType
                                    startMessageId:(NSString *)aStartMessageId
                                          pageSize:(int)aPageSize
                                             error:(AgoraChatError **)pError;


/**
 *  \~chinese
 *  从服务器获取指定会话的历史消息
 *
 *  异步方法
 *
 *  @param  aConversationId     要获取漫游消息的Conversation ID
 *  @param  aConversationType   要获取漫游消息的Conversation type
 *  @param  aStartMessageId     参考起始消息的ID
 *  @param  aPageSize           获取消息条数
 *  @param  aCompletionBlock    获取消息结束的callback
 *
 *
 *  \~english
 *  Fetch conversation roam messages from server.
 
 *  @param aConversationId      The conversation id which select to fetch roam message.
 *  @param aConversationType    The conversation type which select to fetch roam message.
 *  @param aStartMessageId      The start search roam message id, if empty start from the server leastst message.
 *  @param aPageSize            The page size.
 *  @param aCompletionBlock     The callback block of fetch complete
 */
- (void)asyncFetchHistoryMessagesFromServer:(NSString *)aConversationId
                           conversationType:(AgoraChatConversationType)aConversationType
                             startMessageId:(NSString *)aStartMessageId
                                   pageSize:(int)aPageSize
                                 completion:(void (^)(AgoraChatCursorResult *aResult, AgoraChatError *aError))aCompletionBlock;


/**
 *  \~chinese
 *  从服务器获取指定群已读回执
 *
 *  异步方法
 *
 *  @param  aMessageId           要获取的消息ID
 *  @param  aGroupId             要获取回执对应的群ID
 *  @param  aGroupAckId          要获取的群回执ID
 *  @param  aPageSize            获取消息条数
 *  @param  aCompletionBlock     获取消息结束的callback
 *
 *
 *  \~english
 *  Fetch group read back receipt from the server
 
 *  @param  aMessageId           The message id which select to fetch.
 *  @param  aGroupId             The group id which select to fetch.
 *  @param  aGroupAckId          The group ack id which select to fetch.
 *  @param  aPageSize            The page size.
 *  @param  aCompletionBlock     The callback block of fetch complete
 */
- (void)asyncFetchGroupMessageAcksFromServer:(NSString *)aMessageId
                                     groupId:(NSString *)aGroupId
                             startGroupAckId:(NSString *)aGroupAckId
                                    pageSize:(int)aPageSize
                                  completion:(void (^)(AgoraChatCursorResult *aResult, AgoraChatError *error, int totalCount))aCompletionBlock;

#pragma mark - EM_DEPRECATED_IOS 3.6.1

/*!
 *  \~chinese
 *  发送消息已读回执
 *
 *  异步方法
 *
 *  @param aMessage             消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Send read acknowledgement for message
 *
 *  @param aMessage             Message instance
 *  @param aCompletionBlock     The callback of completion block
 *
 */
- (void)sendMessageReadAck:(AgoraChatMessage *)aMessage
                completion:(void (^)(AgoraChatMessage *aMessage, AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_3_0, 3_6_1, "Use -[IAgoraChatManager sendMessageReadAck:toUser:completion:] instead");


/*!
 *  \~chinese
 *  撤回消息
 *
 *  异步方法
 *
 *  @param aMessage             消息
 *  @param aCompletionBlock     完成的回调
 *
 *  \~english
 *  Recall a message
 *
 *
 *  @param aMessage             Message instance
 *  @param aCompletionBlock     The callback block of completion
 *
 */
- (void)recallMessage:(AgoraChatMessage *)aMessage
           completion:(void (^)(AgoraChatMessage *aMessage, AgoraChatError *aError))aCompletionBlock EM_DEPRECATED_IOS(3_3_0, 3_6_1, "Use -[IAgoraChatManager recallMessageWithMessageId:completion:] instead");


#pragma mark - EM_DEPRECATED_IOS 3.2.3

/*!
 *  \~chinese
 *  添加回调代理
 *
 *  @param aDelegate  要添加的代理
 *
 *  \~english
 *  Add delegate
 *
 *  @param aDelegate  Delegate
 */
- (void)addDelegate:(id<AgoraChatManagerDelegate>)aDelegate EM_DEPRECATED_IOS(3_1_0, 3_2_2, "Use -[IAgoraChatManager addDelegate:delegateQueue:] instead");

#pragma mark - EM_DEPRECATED_IOS < 3.2.3

/*!
 *  \~chinese
 *  从数据库中获取所有的会话，执行后会更新内存中的会话列表
 *  
 *  同步方法，会阻塞当前线程
 *
 *  @result 会话列表<AgoraChatConversation>
 *
 *  \~english
 *  Load all conversations from DB, will update conversation list in memory after this method is called
 *
 *  Synchronization method will block the current thread
 *
 *  @result Conversation list<AgoraChatConversation>
 */
- (NSArray *)loadAllConversationsFromDB __deprecated_msg("Use -getAllConversations instead");

/*!
 *  \~chinese
 *  删除会话
 *
 *  @param aConversationId  会话ID
 *  @param aDeleteMessage   是否删除会话中的消息
 *
 *  @result 是否成功
 *
 *  \~english
 *  Delete a conversation
 *
 *  @param aConversationId  Conversation id
 *  @param aDeleteMessage   Whether delete messages
 *
 *  @result Whether deleted successfully
 */
- (BOOL)deleteConversation:(NSString *)aConversationId
            deleteMessages:(BOOL)aDeleteMessage __deprecated_msg("Use -deleteConversation:isDeleteMessages:completion: instead");

/*!
 *  \~chinese
 *  删除一组会话
 *
 *  @param aConversations  会话列表<AgoraChatConversation>
 *  @param aDeleteMessage  是否删除会话中的消息
 *
 *  @result 是否成功
 *
 *  \~english
 *  Delete multiple conversations
 *
 *  @param aConversations  Conversation list<AgoraChatConversation>
 *  @param aDeleteMessage  Whether delete messages
 *
 *  @result Whether deleted successfully
 */
- (BOOL)deleteConversations:(NSArray *)aConversations
             deleteMessages:(BOOL)aDeleteMessage __deprecated_msg("Use -deleteConversations:isDeleteMessages:completion: instead");

/*!
 *  \~chinese
 *  导入一组会话到DB
 *
 *  @param aConversations  会话列表<AgoraChatConversation>
 *
 *  @result 是否成功
 *
 *  \~english
 *  Import multiple conversations to DB
 *
 *  @param aConversations  Conversation list<AgoraChatConversation>
 *
 *  @result Whether imported successfully
 */
- (BOOL)importConversations:(NSArray *)aConversations __deprecated_msg("Use -importConversations:completion: instead");

/*!
 *  \~chinese
 *  导入一组消息到DB
 *
 *  @param aMessages  消息列表<AgoraChatMessage>
 *
 *  @result 是否成功
 *
 *  \~english
 *  Import multiple messages
 *
 *  @param aMessages  Message list<AgoraChatMessage>
 *
 *  @result Whether imported successfully
 */
- (BOOL)importMessages:(NSArray *)aMessages __deprecated_msg("Use -importMessages:completion: instead");

/*!
 *  \~chinese
 *  更新消息到DB
 *
 *  @param aMessage  消息
 *
 *  @result 是否成功
 *
 *  \~english
 *  Update message to DB
 *
 *  @param aMessage  Message
 *
 *  @result Whether updated successfully
 */
- (BOOL)updateMessage:(AgoraChatMessage *)aMessage __deprecated_msg("Use -updateMessage:completion: instead");

/*!
 *  \~chinese
 *  发送消息已读回执
 *
 *  异步方法
 *
 *  @param aMessage  消息
 *
 *  \~english
 *  Send read ack for message
 *
 *  Asynchronous methods
 *
 *  @param aMessage  Message instance
 */
- (void)asyncSendReadAckForMessage:(AgoraChatMessage *)aMessage __deprecated_msg("Use -sendMessageReadAck:completion: instead");

/*!
 *  \~chinese
 *  发送消息
 *  
 *  异步方法
 *
 *  @param aMessage            消息
 *  @param aProgressCompletion 附件上传进度回调block
 *  @param aCompletion         发送完成回调block
 *
 *  \~english
 *  Send a message
 *
 *  Asynchronous methods
 *
 *  @param aMessage            Message instance
 *  @param aProgressCompletion The block of attachment upload progress
 *
 *  @param aCompletion         The block of send complete
 */
- (void)asyncSendMessage:(AgoraChatMessage *)aMessage
                progress:(void (^)(int progress))aProgressCompletion
              completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletion __deprecated_msg("Use -sendMessage:progress:completion: instead");

/*!
 *  \~chinese
 *  重发送消息
 *  
 *  异步方法
 *
 *  @param aMessage            消息对象
 *  @param aProgressCompletion 附件上传进度回调block
 *  @param aCompletion         发送完成回调block
 *
 *  \~english
 *  Resend Message
 *
 *  Asynchronous methods
 *
 *  @param aMessage            Message object
 *  @param aProgressCompletion The callback block of attachment upload progress
 *  @param aCompletion         The callback block of send complete
 */
- (void)asyncResendMessage:(AgoraChatMessage *)aMessage
                  progress:(void (^)(int progress))aProgressCompletion
                completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletion __deprecated_msg("Use -resendMessage:progress:completion: instead");

/*!
 *  \~chinese
 *  下载缩略图（图片消息的缩略图或视频消息的第一帧图片），SDK会自动下载缩略图，所以除非自动下载失败，用户不需要自己下载缩略图
 *
 *  异步方法
 *
 *  @param aMessage            消息对象
 *  @param aProgressCompletion 附件下载进度回调block
 *  @param aCompletion         下载完成回调block
 *
 *  \~english
 *  Download message thumbnail attachments (thumbnails of image message or first frame of video image), SDK can download thumbail automatically, so user should NOT download thumbail manually except automatic download failed
 *
 *  Asynchronous methods
 *
 *  @param aMessage            Message object
 *  @param aProgressCompletion The callback block of attachment download progress
 *  @param aCompletion         The callback block of download complete
 */
- (void)asyncDownloadMessageThumbnail:(AgoraChatMessage *)aMessage
                             progress:(void (^)(int progress))aProgressCompletion
                           completion:(void (^)(AgoraChatMessage * message, AgoraChatError *error))aCompletion __deprecated_msg("Use -downloadMessageThumbnail:progress:completion: instead");

/*!
 *  \~chinese
 *  下载消息附件（语音，视频，图片原图，文件），SDK会自动下载语音消息，所以除非自动下载语音失败，用户不需要自动下载语音附件
 *  
 *  异步方法
 *
 *  @param aMessage            消息对象
 *  @param aProgressCompletion 附件下载进度回调block
 *  @param aCompletion         下载完成回调block
 *
 *  \~english
 *  Download message attachment(voice, video, image or file), SDK can download voice automatically, so user should NOT download voice manually except automatic download failed
 *
 *  Asynchronous methods
 *
 *  @param aMessage            Message object
 *  @param aProgressCompletion The callback block of attachment download progress
 *  @param aCompletion         The callback block of download complete
 */
- (void)asyncDownloadMessageAttachments:(AgoraChatMessage *)aMessage
                               progress:(void (^)(int progress))aProgressCompletion
                             completion:(void (^)(AgoraChatMessage *message, AgoraChatError *error))aCompletion __deprecated_msg("Use -downloadMessageAttachment:progress:completion: instead");

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
 *                          AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
 *                          AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
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
 *                          AgoraChatMessageSearchDirectionUp: get aCount of messages before aMessageId;
 *                          AgoraChatMessageSearchDirectionDown: get aCount of messages after aMessageId
 *
 *  @result AgoraChatMessage NSArray<AgoraChatMessage>
 *
 */
- (NSArray<AgoraChatMessage *> *)loadMessagesWithKeyword:(NSString*)aKeywords
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
- (void)loadMessagesWithKeyword:(NSString*)aKeywords
                      timestamp:(long long)aTimestamp
                          count:(int)aCount
                       fromUser:(NSString*)aSender
                searchDirection:(AgoraChatMessageSearchDirection)aDirection
                     completion:(void (^)(NSArray *aMessages, AgoraChatError *aError))aCompletionBlock;

@end
