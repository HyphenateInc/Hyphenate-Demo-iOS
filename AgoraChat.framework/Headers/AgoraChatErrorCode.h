/*!
 *  \~chinese
 *  @header AgoraChatErrorCode.h
 *  @abstract SDK定义的错误码
 *  @author Hyphenate
 *  @version 3.00
 *
 *  \~english
 *  @header AgoraChatErrorCode.h
 *  @abstract SDK defined error type
 *  @author Hyphenate
 *  @version 3.00
 */

typedef enum{

    AgoraChatErrorGeneral = 1,                      /*! \~chinese 一般错误 \~english General error */
    AgoraChatErrorNetworkUnavailable,               /*! \~chinese 网络不可用 \~english Network is unavaliable */
    AgoraChatErrorDatabaseOperationFailed,          /*! \~chinese 数据库操作失败 \~english Database operation failed */
    AgoraChatErrorExceedServiceLimit,               /*! \~chinese 超过服务器限制 \~english Exceed service limit */
    AgoraChatErrorServiceArrearages,                /*! \~chinese 余额不足 \~english Need charge for service */
    
    AgoraChatErrorInvalidAppkey = 100,              /*! \~chinese Appkey无效 \~english App (API) key is invalid */
    AgoraChatErrorInvalidUsername,                  /*! \~chinese 用户名无效 \~english Username is invalid */
    AgoraChatErrorInvalidPassword,                  /*! \~chinese 密码无效 \~english Password is invalid */
    AgoraChatErrorInvalidURL,                       /*! \~chinese URL无效 \~english URL is invalid */
    AgoraChatErrorInvalidToken,                     /*! \~chinese Token无效 \~english Token is invalid */
    AgoraChatErrorUsernameTooLong,                  /*! \~chinese 用户名过长 \~english Username too long */
    
    AgoraChatErrorUserAlreadyLoginSame = 200,       /*! \~chinese 当前用户已登录 \~english Same User is already login */
    AgoraChatErrorUserNotLogin,                     /*! \~chinese 用户未登录 \~english User not logged in */
    AgoraChatErrorUserAuthenticationFailed,         /*! \~chinese 密码验证失败 \~english Password authentication failed */
    AgoraChatErrorUserAlreadyExist,                 /*! \~chinese 用户已存在 \~english User already existed */
    AgoraChatErrorUserNotFound,                     /*! \~chinese 用户不存在 \~english User not found */
    AgoraChatErrorUserIllegalArgument,              /*! \~chinese 参数不合法 \~english Invalid argument */
    AgoraChatErrorUserLoginOnAnotherDevice,         /*! \~chinese 当前用户在另一台设备上登录 \~english User has logged in from another device */
    AgoraChatErrorUserRemoved,                      /*! \~chinese 当前用户从服务器端被删掉 \~english User was removed from server */
    AgoraChatErrorUserRegisterFailed,               /*! \~chinese 用户注册失败 \~english Registration failed */
    AgoraChatErrorUpdateApnsConfigsFailed,          /*! \~chinese 更新推送设置失败 \~english Update Apple Push Notification configurations failed */
    AgoraChatErrorUserPermissionDenied,             /*! \~chinese 用户没有权限做该操作 \~english User has no operation permission */
    AgoraChatErrorUserBindDeviceTokenFailed,        /*! \~chinese 绑定device token失败  \~english Bind device token failed */
    AgoraChatErrorUserUnbindDeviceTokenFailed,      /*! \~chinese 解除device token失败 \~english Unbind device token failed */
    AgoraChatErrorUserBindAnotherDevice,            /*! \~chinese 已经在其他设备上绑定了，不允许自动登录 \~english already bound to other device and auto login is not allowed*/
    AgoraChatErrorUserLoginTooManyDevices,          /*! \~chinese 登录的设备数达到了上限 \~english User login on too many devices */
    AgoraChatErrorUserMuted,                        /*! \~chinese 用户在群组或聊天室中被禁言 \~english User is muted in group or chatroom */
    AgoraChatErrorUserKickedByChangePassword,       /*! \~chinese 用户已经修改了密码 \~english User has changed the password */
    AgoraChatErrorUserKickedByOtherDevice,          /*! \~chinese 被其他设备踢掉了 \~english User was kicked out from other device */
    AgoraChatErrorUserAlreadyLoginAnother,          /*! \~chinese 其他用户已登录 \~english Another User is already login */
    AgoraChatErrorUserMutedByAdmin,                 /*! \~chinese 用户被管理员禁言 \~english User is muted by admin */
    
    AgoraChatErrorServerNotReachable = 300,         /*! \~chinese 服务器未连接 \~english Server is not reachable */
    AgoraChatErrorServerTimeout,                    /*! \~chinese 服务器超时 \~english Server response timeout */
    AgoraChatErrorServerBusy,                       /*! \~chinese 服务器忙碌 \~english Server is busy */
    AgoraChatErrorServerUnknownError,               /*! \~chinese 未知服务器错误 \~english Unknown server error */
    AgoraChatErrorServerGetDNSConfigFailed,         /*! \~chinese 获取DNS设置失败 \~english Get DNS config failed */
    AgoraChatErrorServerServingForbidden,           /*! \~chinese 服务被禁用 \~english Service is forbidden */
    
    AgoraChatErrorFileNotFound = 400,               /*! \~chinese 文件没有找到 \~english Cannot find the file */
    AgoraChatErrorFileInvalid,                      /*! \~chinese 文件无效 \~english File is invalid */
    AgoraChatErrorFileUploadFailed,                 /*! \~chinese 上传文件失败 \~english Upload file failed */
    AgoraChatErrorFileDownloadFailed,               /*! \~chinese 下载文件失败 \~english Download file failed */
    AgoraChatErrorFileDeleteFailed,                 /*! \~chinese 删除文件失败 \~english Delete file failed */
    AgoraChatErrorFileTooLarge,                     /*! \~chinese 文件体积过大 \~english File too large */
    AgoraChatErrorFileContentImproper,              /*! \~chinese 文件内容不合规 \~english File content improper */
    
    
    AgoraChatErrorMessageInvalid = 500,             /*! \~chinese 消息无效 \~english Message is invalid */
    AgoraChatErrorMessageIncludeIllegalContent,     /*! \~chinese 消息内容包含不合法信息 \~english Message contains invalid content */
    AgoraChatErrorMessageTrafficLimit,              /*! \~chinese 单位时间发送消息超过上限 \~english Unit time to send messages over the upper limit */
    AgoraChatErrorMessageEncryption,                /*! \~chinese 加密错误 \~english Encryption error */
    AgoraChatErrorMessageRecallTimeLimit,           /*! \~chinese 消息撤回超过时间限制 \~english Unit time to send recall for message over the time limit */
    AgoraChatErrorServiceNotEnable,                 /*! \~chinese 服务未开通 \~english  service not enabled */
    AgoraChatErrorMessageExpired,                   /*! \~chinese 消息过期 \~english  The message has expired */
    AgoraChatErrorMessageIllegalWhiteList,          /*! \~chinese 不在白名单中无法发送 \~english  The message has delivery failed because it was not in the whitelist */
    AgoraChatErrorMessageExternalLogicBlocked,      /*! \~chinese 发送前回调逻辑拦截 \~english  The message blocked by external logic */
    
    AgoraChatErrorGroupInvalidId = 600,             /*! \~chinese 群组ID无效 \~english Group Id is invalid */
    AgoraChatErrorGroupAlreadyJoined,               /*! \~chinese 已加入群组 \~english User already joined the group */
    AgoraChatErrorGroupNotJoined,                   /*! \~chinese 未加入群组 \~english User has not joined the group */
    AgoraChatErrorGroupPermissionDenied,            /*! \~chinese 没有权限进行该操作 \~english User does not have permission to access the operation */
    AgoraChatErrorGroupMembersFull,                 /*! \~chinese 群成员个数已达到上限 \~english Group's max member capacity reached */
    AgoraChatErrorGroupNotExist,                    /*! \~chinese 群组不存在 \~english Group does not exist */
    AgoraChatErrorGroupSharedFileInvalidId,         /*! \~chinese 共享文件ID无效 \~english Shared file Id is invalid */
    
    AgoraChatErrorChatroomInvalidId = 700,          /*! \~chinese 聊天室ID无效 \~english Chatroom id is invalid */
    AgoraChatErrorChatroomAlreadyJoined,            /*! \~chinese 已加入聊天室 \~english User already joined the chatroom */
    AgoraChatErrorChatroomNotJoined,                /*! \~chinese 未加入聊天室 \~english User has not joined the chatroom */
    AgoraChatErrorChatroomPermissionDenied,         /*! \~chinese 没有权限进行该操作 \~english User does not have operation permission */
    AgoraChatErrorChatroomMembersFull,              /*! \~chinese 聊天室成员个数达到上限 \~english Chatroom's max member capacity reached */
    AgoraChatErrorChatroomNotExist,                 /*! \~chinese 聊天室不存在 \~english Chatroom does not exist */
    
    AgoraChatErrorCallInvalidId = 800,              /*! \~chinese 实时通话ID无效 \~english Call id is invalid */
    AgoraChatErrorCallBusy,                         /*! \~chinese 已经在进行实时通话了 \~english User is busy */
    AgoraChatErrorCallRemoteOffline,                /*! \~chinese 对方不在线 \~english Callee is offline */
    AgoraChatErrorCallConnectFailed,                /*! \~chinese 实时通话建立连接失败 \~english Establish connection failure */
    AgoraChatErrorCallCreateFailed,                 /*! \~chinese 创建实时通话失败 \~english Create a real-time call failed */
    AgoraChatErrorCallCancel,                       /*! \~chinese 取消实时通话 \~english Cancel a real-time call */
    AgoraChatErrorCallAlreadyJoined,                /*! \~chinese 已经加入了实时通话 \~english Has joined the real-time call */
    AgoraChatErrorCallAlreadyPub,                   /*! \~chinese 已经上传了本地数据流 \~english The local data stream has been uploaded */
    AgoraChatErrorCallAlreadySub,                   /*! \~chinese 已经订阅了该数据流 \~english The data stream has been subscribed */
    AgoraChatErrorCallNotExist,                     /*! \~chinese 实时通话不存在 \~english The real-time do not exist */
    AgoraChatErrorCallNoPublish,                    /*! \~chinese 实时通话没有已经上传的数据流 \~english Real-time calls have no data streams that have been uploaded */
    AgoraChatErrorCallNoSubscribe,                  /*! \~chinese 实时通话没有可以订阅的数据流 \~english Real-time calls have no data streams that can be subscribed */
    AgoraChatErrorCallNoStream,                     /*! \~chinese 实时通话没有数据流 \~english There is no data stream in the real-time call */
    AgoraChatErrorCallInvalidTicket,                /*! \~chinese 无效的ticket \~english Invalid ticket */
    AgoraChatErrorCallTicketExpired,                /*! \~chinese ticket已过期 \~english Ticket has expired */
    AgoraChatErrorCallSessionExpired,               /*! \~chinese 实时通话已过期 \~english The real-time call has expired */
    AgoraChatErrorCallRoomNotExist,                 /*! \~chinese 会议或白板不存在 \~english The conference or whiteboart  do not exist */
    AgoraChatErrorCallInvalidParams = 818,          /*! \~chinese 无效的会议参数 \~invalid conference params */
    AgoraChatErrorCallSpeakerFull = 823,            /*! \~chinese 主播个数已达到上限 \~english Conference's max speaker capacity reached */
    AgoraChatErrorCallVideoFull = 824,              /*! \~chinese 视频个数已达到上限 \~english Conference's max videos capacity reached */
    AgoraChatErrorCallCDNError = 825,               /*! \~chinese cdn推流错误 \~english Cdn push stream error */
    AgoraChatErrorCallDesktopFull = 826,            /*! \~chinese 共享桌面个数已达到上限 \~english Conference's desktop streams capacity reached */
    AgoraChatErrorCallAutoAudioFail = 827,          /*! \~chinese 自动发布订阅音频失败 \~english Conference's auto pub or sub audio stream fail */
    AgoraChatErrorUserCountExceed = 900,            /*! \~chinese 获取用户属性的用户个数超过100个 \~english The count of users to get userinfo more than 100 */
    AgoraChatErrorUserInfoDataLengthExceed = 901,   /*! \~chinese 设置的用户属性长度太长 \~english The count of The datalength of userinfo to set is too long */
}AgoraChatErrorCode;
