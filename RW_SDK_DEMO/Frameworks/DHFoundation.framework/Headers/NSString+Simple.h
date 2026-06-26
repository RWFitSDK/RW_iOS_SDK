//
//  NSString+Simple.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Simple)

/// 数组、字典对象转json字符串
/// @param object 数组、字典对象
+ (NSString*)dataToJsonString:(id)object;

/**
 如果是标准的json字符串，可获取相应对象
 */
@property (nonatomic, copy) NSDictionary *jsonDict;

/// json字符串转字典或数组
- (id)transToObject;

/**
 设置属性字符串

 @param stringArray 字符串数组
 @param fontArray 字体数组
 @param colorArray 颜色数组
 @return 属性字符串
 */
+ (NSMutableAttributedString*)attributedStrings:(NSArray *) stringArray
                                           fonts:(NSArray *) fontArray
                                          colors:(NSArray *) colorArray;


/**
计算文字高度

@param font 字体
@param width 最大宽度
@return 结果
*/
- (CGFloat)heightWithFont:(UIFont *)font width:(CGFloat)width;

/**
计算文字宽度

@param font 字体
@param maxHeight 最大高度
@return 结果
*/
- (CGFloat)widthWithFont:(UIFont *)font height:(CGFloat)maxHeight;

/**
 计算文字区域
 @param font 字体
 @param maxSize 极限区域
 @return 结果
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 有效的字符串
 */
- (BOOL)isValidateString;

/**
 字符串转日期
 @param formatStr 字符串格式
 */
- (NSDate *)dateByStringFormat:(NSString *)formatStr;

/**
MD5加密
*/
- (NSString *)md5WithString;

/**
SHA-1加密
*/
- (NSString*)sha1WithString;

/**
 字符串是否包含piece
 @param piece 字符片段
 */
- (BOOL)contains:(NSString *)piece;

/**
 相关的格式化   容错
 */
- (NSString *)formatDataString:(NSString *) datastr;

/**
 通过NSUserDefaults存储各种类型的数据
 @param value Object数据
 */
- (void)setObjectValue:(id)value;

/**
 通过NSUserDefaults存储各种类型的数据
 
 @param value NSInteger数据
 */
- (void)setIntValue:(NSInteger)value;

/**
 通过NSUserDefaults存储各种类型的数据
 
 @param value BOOL数据
 */
- (void)setBOOLValue:(BOOL)value;

/**
 获取NSUserDefaults保存的数据
 
 @return 返回Object数据
 */
- (id)getObjectValue;

/**
 获取NSUserDefaults保存的数据
 
 @return 返回NSInteger数据
 */
- (NSInteger)getIntValue;

/**
 获取NSUserDefaults保存的数据
 
 @return 返回BOOL数据
 */
- (BOOL)getBOOLValue;

/**
 删除NSUserDefaults保存的数据
 */
- (void)removeObjectValue;

@end

NS_ASSUME_NONNULL_END
