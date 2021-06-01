/*!
 *  \~chinese
 *  @header AgoraErrorCode.h
 *  @abstract SDK定义的错误类型
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraErrorCode.h
 *  @abstract SDK defined error type
 *  @author Hyphenate
 *  @version 3.00
 */

typedef enum{

    AgoraErrorGeneral = 1,                      /*! \~chinese 一般错误 \~english General error */
    AgoraErrorNetworkUnavailable,               /*! \~chinese 网络不可用 \~english Network is unavaliable */
    AgoraErrorDatabaseOperationFailed,          /*! \~chinese 数据库操作失败 \~english Database operation failed */
    AgoraErrorExceedServiceLimit,               /*! \~chinese 超过服务器限制 \~english Exceed service limit */
    AgoraErrorServiceArrearages,                /*! \~chinese 余额不足 \~english Need charge for service */
    
    AgoraErrorInvalidAppkey = 100,              /*! \~chinese Appkey无效 \~english App (API) key is invalid */
    AgoraErrorInvalidUsername,                  /*! \~chinese 用户名无效 \~english Username is invalid */
    AgoraErrorInvalidPassword,                  /*! \~chinese 密码无效 \~english Password is invalid */
    AgoraErrorInvalidURL,                       /*! \~chinese URL无效 \~english URL is invalid */
    AgoraErrorInvalidToken,                     /*! \~chinese Token无效 \~english Token is invalid */
    AgoraErrorUsernameTooLong,                  /*! \~chinese 用户名过长 \~english Username too long */
    
    AgoraErrorUserAlreadyLogin = 200,           /*! \~chinese 用户已登录 \~english User already logged in */
    AgoraErrorUserNotLogin,                     /*! \~chinese 用户未登录 \~english User not logged in */
    AgoraErrorUserAuthenticationFailed,         /*! \~chinese 密码验证失败 \~english Password authentication failed */
    AgoraErrorUserAlreadyExist,                 /*! \~chinese 用户已存在 \~english User already existed */
    AgoraErrorUserNotFound,                     /*! \~chinese 用户不存在 \~english User not found */
    AgoraErrorUserIllegalArgument,              /*! \~chinese 参数不合法 \~english Invalid argument */
    AgoraErrorUserLoginOnAnotherDevice,         /*! \~chinese 当前用户在另一台设备上登录 \~english User has logged in from another device */
    AgoraErrorUserRemoved,                      /*! \~chinese 当前用户从服务器端被删掉 \~english User was removed from server */
    AgoraErrorUserRegisterFailed,               /*! \~chinese 用户注册失败 \~english Registration failed */
    AgoraErrorUpdateApnsConfigsFailed,          /*! \~chinese 更新推送设置失败 \~english Update Apple Push Notification configurations failed */
    AgoraErrorUserPermissionDenied,             /*! \~chinese 用户没有权限做该操作 \~english User has no operation permission */
    AgoraErrorUserBindDeviceTokenFailed,        /*! \~chinese 绑定device token失败  \~english Bind device token failed */
    AgoraErrorUserUnbindDeviceTokenFailed,      /*! \~chinese 解除device token失败 \~english Unbind device token failed */
    AgoraErrorUserBindAnotherDevice,            /*! \~chinese 已经在其他设备上绑定了，不允许自动登录 \~english already bound to other device and auto login is not allowed*/
    AgoraErrorUserLoginTooManyDevices,          /*! \~chinese 登录的设备数达到了上限 \~english User login on too many devices */
    AgoraErrorUserMuted,                        /*! \~chinese 用户在群组或聊天室中被禁言 \~english User is muted in group or chatroom */
    AgoraErrorUserKickedByChangePassword,       /*! \~chinese 用户已经修改了密码 \~english User has changed the password */
    AgoraErrorUserKickedByOtherDevice,          /*! \~chinese 被其他设备踢掉了 \~english User was kicked out from other device */
    
    AgoraErrorServerNotReachable = 300,         /*! \~chinese 服务器未连接 \~english Server is not reachable */
    AgoraErrorServerTimeout,                    /*! \~chinese 服务器超时 \~english Server response timeout */
    AgoraErrorServerBusy,                       /*! \~chinese 服务器忙碌 \~english Server is busy */
    AgoraErrorServerUnknownError,               /*! \~chinese 未知服务器错误 \~english Unknown server error */
    AgoraErrorServerGetDNSConfigFailed,         /*! \~chinese 获取DNS设置失败 \~english Get DNS config failed */
    AgoraErrorServerServingForbidden,           /*! \~chinese 服务被禁用 \~english Service is forbidden */
    
    AgoraErrorFileNotFound = 400,               /*! \~chinese 文件没有找到 \~english Cannot find the file */
    AgoraErrorFileInvalid,                      /*! \~chinese 文件无效 \~english File is invalid */
    AgoraErrorFileUploadFailed,                 /*! \~chinese 上传文件失败 \~english Upload file failed */
    AgoraErrorFileDownloadFailed,               /*! \~chinese 下载文件失败 \~english Download file failed */
    AgoraErrorFileDeleteFailed,                 /*! \~chinese 删除文件失败 \~english Delete file failed */
    AgoraErrorFileTooLarge,                     /*! \~chinese 文件体积过大 \~english File too large */
    AgoraErrorFileContentImproper,              /*! \~chinese 文件内容不合规 \~english File content improper */
    
    
    AgoraErrorMessageInvalid = 500,             /*! \~chinese 消息无效 \~english Message is invalid */
    AgoraErrorMessageIncludeIllegalContent,     /*! \~chinese 消息内容包含不合法信息 \~english Message contains invalid content */
    AgoraErrorMessageTrafficLimit,              /*! \~chinese 单位时间发送消息超过上限 \~english Unit time to send messages over the upper limit */
    AgoraErrorMessageEncryption,                /*! \~chinese 加密错误 \~english Encryption error */
    AgoraErrorMessageRecallTimeLimit,           /*! \~chinese 消息撤回超过时间限制 \~english Unit time to send recall for message over the time limit */
    AgoraErrorMessageExpired,                   /*! \~chinese 消息过期 \~english  The message has expired */
    AgoraErrorMessageIllegalWhiteList,          /*! \~chinese 不在白名单中无法发送 \~english  The message has delivery failed because it was not in the whitelist */
    
    AgoraErrorGroupInvalidId = 600,             /*! \~chinese 群组ID无效 \~english Group Id is invalid */
    AgoraErrorGroupAlreadyJoined,               /*! \~chinese 已加入群组 \~english User already joined the group */
    AgoraErrorGroupNotJoined,                   /*! \~chinese 未加入群组 \~english User has not joined the group */
    AgoraErrorGroupPermissionDenied,            /*! \~chinese 没有权限进行该操作 \~english User does not have permission to access the operation */
    AgoraErrorGroupMembersFull,                 /*! \~chinese 群成员个数已达到上限 \~english Group's max member capacity reached */
    AgoraErrorGroupNotExist,                    /*! \~chinese 群组不存在 \~english Group does not exist */
    AgoraErrorGroupSharedFileInvalidId,         /*! \~chinese 共享文件ID无效 \~english Shared file Id is invalid */
    
    AgoraErrorChatroomInvalidId = 700,          /*! \~chinese 聊天室ID无效 \~english Chatroom id is invalid */
    AgoraErrorChatroomAlreadyJoined,            /*! \~chinese 已加入聊天室 \~english User already joined the chatroom */
    AgoraErrorChatroomNotJoined,                /*! \~chinese 未加入聊天室 \~english User has not joined the chatroom */
    AgoraErrorChatroomPermissionDenied,         /*! \~chinese 没有权限进行该操作 \~english User does not have operation permission */
    AgoraErrorChatroomMembersFull,              /*! \~chinese 聊天室成员个数达到上限 \~english Chatroom's max member capacity reached */
    AgoraErrorChatroomNotExist,                 /*! \~chinese 聊天室不存在 \~english Chatroom does not exist */
    
    AgoraErrorCallInvalidId = 800,              /*! \~chinese 实时通话ID无效 \~english Call id is invalid */
    AgoraErrorCallBusy,                         /*! \~chinese 已经在进行实时通话了 \~english User is busy */
    AgoraErrorCallRemoteOffline,                /*! \~chinese 对方不在线 \~english Callee is offline */
    AgoraErrorCallConnectFailed,                /*! \~chinese 实时通话建立连接失败 \~english Establish connection failure */
    AgoraErrorCallCreateFailed,                 /*! \~chinese 创建实时通话失败 \~english Create a real-time call failed */
    AgoraErrorCallCancel,                       /*! \~chinese 取消实时通话 \~english Cancel a real-time call */
    AgoraErrorCallAlreadyJoined,                /*! \~chinese 已经加入了实时通话 \~english Has joined the real-time call */
    AgoraErrorCallAlreadyPub,                   /*! \~chinese 已经上传了本地数据流 \~english The local data stream has been uploaded */
    AgoraErrorCallAlreadySub,                   /*! \~chinese 已经订阅了该数据流 \~english The data stream has been subscribed */
    AgoraErrorCallNotExist,                     /*! \~chinese 实时通话不存在 \~english The real-time do not exist */
    AgoraErrorCallNoPublish,                    /*! \~chinese 实时通话没有已经上传的数据流 \~english Real-time calls have no data streams that have been uploaded */
    AgoraErrorCallNoSubscribe,                  /*! \~chinese 实时通话没有可以订阅的数据流 \~english Real-time calls have no data streams that can be subscribed */
    AgoraErrorCallNoStream,                     /*! \~chinese 实时通话没有数据流 \~english There is no data stream in the real-time call */
    AgoraErrorCallInvalidTicket,                /*! \~chinese 无效的ticket \~english Invalid ticket */
    AgoraErrorCallTicketExpired,                /*! \~chinese ticket已过期 \~english Ticket has expired */
    AgoraErrorCallSessionExpired,               /*! \~chinese 实时通话已过期 \~english The real-time call has expired */
    AgoraErrorCallRoomNotExist,                 /*! \~chinese 会议或白板不存在 \~english The conference or whiteboart  do not exist */
    AgoraErrorCallInvalidParams = 818,          /*! \~chinese 无效的会议参数 \~invalid conference params */
    AgoraErrorCallSpeakerFull = 823,            /*! \~chinese 主播个数已达到上限 \~english Conference's max speaker capacity reached */
    AgoraErrorCallVideoFull = 824,              /*! \~chinese 视频个数已达到上限 \~english Conference's max videos capacity reached */
    AgoraErrorCallCDNError = 825,               /*! \~chinese cdn推流错误 \~english Cdn push stream error */
    AgoraErrorCallDesktopFull = 826,            /*! \~chinese 共享桌面个数已达到上限 \~english Conference's desktop streams capacity reached */
    AgoraErrorCallAutoAudioFail = 827,          /*! \~chinese 自动发布订阅音频失败 \~english Conference's auto pub or sub audio stream fail */
    AgoraErrorUserCountExceed = 900,            /*! \~chinese 获取用户属性的用户个数超过100个 \~english The count of users to get userinfo more than 100 */
    AgoraErrorUserInfoDataLengthExceed = 901,   /*! \~chinese 设置的用户属性长度太长 \~english The count of The datalength of userinfo to set is too long */
}AgoraErrorCode;
