//
//  DHUIHelp.h
//  DHUIKit
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHUIHelp : NSObject

/**
 十六进制字符串转颜色
 HexStr strings to color
 
 @param color 十六进制字符串
 @return color
 */
+ (UIColor *_Nullable)colorWithHexString:(NSString *_Nonnull)color;


/**
 十六进制字符串转颜色 加透明度

 @param color 十六进制字符串
 @param alpha 透明度
 @return color
 */
+ (UIColor *_Nullable)colorWithHexString:(NSString *_Nonnull)color alpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END
