//
//  NSObject+ToolSimple.h
//  PrizeFunction
//
//  Created by Z on 2020/9/29.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^NSObjectSimpleBlock)(id object);

@interface NSObject (ToolSimple)

/// 获取系统时制信息.       TURE为12小时制，否则为24小时制
- (BOOL)isHasAMPMTimeSystem;

/// 延迟调用.
- (void)delayPerformBlock:(NSObjectSimpleBlock)block WithTime:(CGFloat)time;

/// 判断文件是否存在.
- (BOOL)completePathDetermineIsThere:(NSString *)path;

///获取app语言
- (NSString *)getAppleLanguages;

@end

NS_ASSUME_NONNULL_END
