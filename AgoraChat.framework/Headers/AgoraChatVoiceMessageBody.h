/*!
 *  \~chinese
 *  @header AgoraChatVoiceMessageBody.h
 *  @abstract 语音消息体
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatVoiceMessageBody.h
 *  @abstract Voice message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>

#import "AgoraChatFileMessageBody.h"

/*!
 *  \~chinese 
 *  语音消息体
 *
 *  \~english
 *  Voice message body
 */
@interface AgoraChatVoiceMessageBody : AgoraChatFileMessageBody

/*!
 *  \~chinese 
 *  语音时长, 秒为单位
 *
 *  \~english 
 *  Voice duration, in seconds
 */
@property (nonatomic) int duration;

@end
