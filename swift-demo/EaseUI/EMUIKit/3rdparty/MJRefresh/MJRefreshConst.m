#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


const CGFloat MJRefreshHeaderHeight = 54.0;
const CGFloat MJRefreshFooterHeight = 44.0;
const CGFloat MJRefreshFastAnimationDuration = 0.25;
const CGFloat MJRefreshSlowAnimationDuration = 0.4;

NSString *const MJRefreshKeyPathContentOffset = @"contentOffset";
NSString *const MJRefreshKeyPathContentInset = @"contentInset";
NSString *const MJRefreshKeyPathContentSize = @"contentSize";
NSString *const MJRefreshKeyPathPanState = @"state";

NSString *const MJRefreshHeaderLastUpdatedTimeKey = @"MJRefreshHeaderLastUpdatedTimeKey";

NSString *const MJRefreshHeaderIdleText = @"Pull to Refresh";
NSString *const MJRefreshHeaderPullingText = @"Release to Refresh";
NSString *const MJRefreshHeaderRefreshingText = @"Refreshing Data...";

NSString *const MJRefreshAutoFooterIdleText = @"Click or Pull to Load more";
NSString *const MJRefreshAutoFooterRefreshingText = @"Loading more data...";
NSString *const MJRefreshAutoFooterNoMoreDataText = @"Done Loading";

NSString *const MJRefreshBackFooterIdleText = @"Pull to Load more";
NSString *const MJRefreshBackFooterPullingText = @"Release to Load more";
NSString *const MJRefreshBackFooterRefreshingText = @"Loading more Data...";
NSString *const MJRefreshBackFooterNoMoreDataText = @"Done Loading";