//
//  AgoraBlackListCell.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/2.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AgoraBlackListCell : AgoraChatCustomBaseCell
@property (nonatomic,copy) void(^unBlockCompletion)(NSString *unBlockUserId);
- (void)updateCellWithObj:(id)obj;

@end

NS_ASSUME_NONNULL_END
