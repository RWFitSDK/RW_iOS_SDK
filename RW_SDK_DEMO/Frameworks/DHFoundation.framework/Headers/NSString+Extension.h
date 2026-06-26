//
//  NSString+Extension.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extension)

/// 把字符串每两个分割
/// @param iStr 分割的字符串
- (NSString *)insertStr:(NSString *)iStr;

/// 16进制字符串转NSData
- (NSData *)hexStrToData;

/// 16进制字符串转Byte
- (Byte *)hexStrToByte;

/// 把当前字符串转化为16进制字符串
- (NSString *)strToHexStr;

/// 把16进制字符串转化为普通字符串
- (NSString *)hexStrTostr;

/// NSData转16进制
+ (NSString *)dataToHexStr:(NSData *)data;

/// 十进制转十六进制
/// @param tmpid tmpid 数据
+ (NSString *)ToHex:(long long int)tmpid;

///把 16进制 的字符串转换成 2进制 的字符串
+ (NSString *)binaryDataWithStr:(NSString *)str;

+ (NSString*) uniqueString;

- (NSString*) urlEncodedString;

- (NSString*) urlDecodedString;

/// 把浮点型数据转化为String，不丢失精度
/// @param value float数据
/// @param count 保留精度，1或2
+ (NSString *)strWithFloatValue:(CGFloat)value count:(NSInteger)count;

/// 整数添加逗号分隔
+ (NSString *)strFormatWithIntValue:(NSInteger)intValue;

@end

NS_ASSUME_NONNULL_END
