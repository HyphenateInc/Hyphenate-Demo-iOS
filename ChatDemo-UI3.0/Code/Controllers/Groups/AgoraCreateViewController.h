//
//  AgoraCreateViewNewController.h
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/4.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraBaseRefreshTableController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AgoraCreateViewController : UIViewController
@property (nonatomic,copy)void (^addGroupBlock)(void);

@end

NS_ASSUME_NONNULL_END
