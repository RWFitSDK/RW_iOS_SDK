//
//  DHProgressHUD.h
//  DHBleSDKDemo
//
//  MBProgressHUD 封装, 对齐原 SVProgressHUD 的四个宏语义:
//  SHOWINDETERMINATE / SHOWHUDNODISS / SHOWHUD / HUDDISS
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHProgressHUD : NSObject

/** 无文本菊花, 需手动 dismiss */
+ (void)show;

/** 带文本菊花, 需手动 dismiss */
+ (void)showStatus:(NSString *)status;

/** 纯文本提示, 约 1.5s 自动消失 */
+ (void)showText:(NSString *)text;

/** 隐藏当前 HUD */
+ (void)dismiss;

@end

NS_ASSUME_NONNULL_END
