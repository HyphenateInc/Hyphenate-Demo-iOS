//
//  AgoraChatTimeRecallCell.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraMessageModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraChatRecallCell : UITableViewCell

- (void)updateCellWithType:(AgoraChatDemoWeakRemind)type
               withContent:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
