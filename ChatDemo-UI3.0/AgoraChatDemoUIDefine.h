/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#ifndef EMChatDemoUIDefine_h
#define EMChatDemoUIDefine_h

#define ChatDemo_DEBUG 0

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define WEAK_SELF typeof(self) __weak weakSelf = self;

#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define KScreenWidth  [[UIScreen mainScreen] bounds].size.width

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_UPDATEUNREADCOUNT @"setupUnreadMessageCount"
#define KNOTIFICATIONNAME_DELETEALLMESSAGE @"RemoveAllMessages"
#define KNOTIFICATION_CALL @"callOutWithChatter"

#define  AGORACHATDEMO_POSTNOTIFY(name,object)  [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];

#define  AGORACHATDEMO_LISTENNOTIFY(name,SEL)  [[NSNotificationCenter defaultCenter] addObserver:self selector:SEL name:name object:nil];
  

#define ImageWithName(imageName) [UIImage imageNamed:imageName]

#define kAgroaPadding 10.0f

//消息撤回
#define MSG_EXT_RECALL @"agora_recall"



#endif /* EMChatDemoUIDefine_h */
