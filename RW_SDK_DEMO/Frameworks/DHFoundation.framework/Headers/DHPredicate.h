//
//  DHPredicate.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHPredicate : NSObject

/// 邮箱验证
/// @param email 邮箱
+ (BOOL)checkForEmail:(NSString *)email;

/// 手机号验证
/// @param mobilePhone 手机号
+ (BOOL)checkForMobilePhone:(NSString *)mobilePhone;

/// 电话号验证
/// @param phone 电话号
+ (BOOL)checkForPhone:(NSString *)phone;

/// 身份证号验证（15或18位）
/// @param idCard 身份证号
+ (BOOL)checkForIdCard:(NSString *)idCard;

/// 密码验证
/// @param shortest 最短长度
/// @param longest 最长长度
/// @param pwd 密码
+ (BOOL)checkForPasswordWithShortest:(NSInteger)shortest longest:(NSInteger)longest password:(NSString *)pwd;

/// 由数字和字母组成的字符串
/// @param string 字符串
+ (BOOL)checkForNumberAndCase:(NSString *)string;

/// 只有字母
/// @param string 字符串
+ (BOOL)checkForCase:(NSString *)string;

/// 只有数字
/// @param string 字符串
+ (BOOL)checkForNumber:(NSString *)string;

/// 是否含有特殊字符(%&’,;=?$\等)
/// @param string 字符串
+ (BOOL)checkForSpecialChar:(NSString *)string;

/// 只有邮箱
/// @param string 字符串
+ (BOOL)checkForNumberAndCaseAndEmailSymbol:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
