//
//  UIColor+DHColor.h
//  DHBleSDKDemo
//
//  替代 DHUIKit 的 DHUIHelp colorWithHexString, hex 字符串转 UIColor
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DHColor)

/** 支持 "#RRGGBB" / "RRGGBB" / "#RRGGBBAA" 格式 */
+ (UIColor *)dh_colorWithHexString:(NSString *)hexStr;

/** 支持 "#RRGGBB" / "RRGGBB" 格式, 附加透明度 */
+ (UIColor *)dh_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
