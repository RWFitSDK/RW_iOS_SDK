//
//  UIColor+DHColor.m
//  DHBleSDKDemo
//

#import "UIColor+DHColor.h"

static unsigned long dh_hexValue(NSString *component) {
    return strtoul(component.UTF8String, NULL, 16);
}

@implementation UIColor (DHColor)

+ (UIColor *)dh_colorWithHexString:(NSString *)hexStr {
    return [self dh_colorWithHexString:hexStr alpha:1.0];
}

+ (UIColor *)dh_colorWithHexString:(NSString *)hexStr alpha:(CGFloat)alpha {
    if (hexStr.length == 0) {
        return [UIColor clearColor];
    }
    NSMutableString *hex = [hexStr mutableCopy];
    if ([hex hasPrefix:@"#"]) {
        [hex deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    // 缩写 "#RGB" 展开为 "#RRGGBB", 每位重复一次
    if (hex.length == 3) {
        unichar chars[3];
        [hex getCharacters:chars range:NSMakeRange(0, 3)];
        hex = [NSString stringWithFormat:@"%C%C%C%C%C%C",
               chars[0], chars[0], chars[1], chars[1], chars[2], chars[2]].mutableCopy;
    }
    if (hex.length != 6 && hex.length != 8) {
        return [UIColor clearColor];
    }
    NSString *rStr = [hex substringWithRange:NSMakeRange(0, 2)];
    NSString *gStr = [hex substringWithRange:NSMakeRange(2, 2)];
    NSString *bStr = [hex substringWithRange:NSMakeRange(4, 2)];
    CGFloat a = alpha;
    if (hex.length == 8) {
        // 8 位时低 2 位为内置透明度, 仅在调用方未指定(=1)时采用
        if (alpha >= 1.0) {
            a = dh_hexValue([hex substringWithRange:NSMakeRange(6, 2)]) / 255.0;
        }
    }
    return [UIColor colorWithRed:dh_hexValue(rStr) / 255.0
                           green:dh_hexValue(gStr) / 255.0
                            blue:dh_hexValue(bStr) / 255.0
                           alpha:a];
}

@end
