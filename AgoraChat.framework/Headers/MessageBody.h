/*!
 *  \~chinese
 *  @header MessageBody.h
 *  @abstract 消息体类型的基类
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header MessageBody.h
 *  @abstract Base class of message body
 *  @author Hyphenate
 *  @version 3.00
 */

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

/*!
 *  \~chinese 
 *  消息体类型
 *
 *  \~english
 *  Message body type
 */
typedef enum {
    MessageBodyTypeText   = 1,    /*! \~chinese 文本类型 \~english Text */
    MessageBodyTypeImage,         /*! \~chinese 图片类型 \~english Image */
    MessageBodyTypeVideo,         /*! \~chinese 视频类型 \~english Video */
    MessageBodyTypeLocation,      /*! \~chinese 位置类型 \~english Location */
    MessageBodyTypeVoice,         /*! \~chinese 语音类型 \~english Voice */
    MessageBodyTypeFile,          /*! \~chinese 文件类型 \~english File */
    MessageBodyTypeCmd,           /*! \~chinese 命令类型 \~english Command */
    MessageBodyTypeCustom,        /*! \~chinese 自定义类型 \~english Custom */
} MessageBodyType;

/*!
 *  \~chinese 
 *  消息体
 *
 *  \~english 
 *  Message body
 */
@interface MessageBody : NSObject

/*!
 *  \~chinese 
 *  消息体类型
 *
 *  \~english 
 *  Message body type
 */
@property (nonatomic, readonly) MessageBodyType type;

@end
