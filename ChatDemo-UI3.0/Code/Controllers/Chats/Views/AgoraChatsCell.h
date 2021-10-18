//
//  AgoraChatsCell.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/8.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AgoraConversationModel;
@interface AgoraChatsCell : AgoraChatCustomBaseCell
- (void)setConversationModel:(AgoraConversationModel*)model;

@end

NS_ASSUME_NONNULL_END
