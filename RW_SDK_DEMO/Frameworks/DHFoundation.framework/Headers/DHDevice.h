//
//  DHDevice.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHDevice : NSObject

/// 手机序列号
+ (NSString *)identifierForVendor;

/// 手机昵称
+ (NSString *)deviceNikeName;

/// 手机名称
+ (NSString *)deviceSystemName;

/// 手机系统版本
+ (NSString *)deviceSystemVersion;

/// 手机系统语言
+ (NSString *)deviceLanguage;

/// 手机型号
+ (NSString *)deviceModel;

/// 国际化区域名称
+ (NSString *)deviceLocalizedModel;

/// 手机电量
+ (CGFloat)deviceBatteryLevel;

/// APP名称
+ (NSString *)appDisplayName;

/// APP版本
+ (NSString *)appShotVersion;

/// APP构建版本
+ (NSString *)appBuildVersion;

@end

NS_ASSUME_NONNULL_END
