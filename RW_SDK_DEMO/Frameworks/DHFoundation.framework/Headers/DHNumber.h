//
//  DHNumber.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHNumber : NSObject

/// 展示小数--一般
/// @param digit 限制最大位数
/// @param number 数值
+ (NSString *)displayDecimalWithDigit:(NSInteger)digit number:(CGFloat)number;

/// 展示百分比
/// @param digit 最大位数
/// @param number 数值
+ (NSString *)displayPercentageWithDigit:(NSInteger)digit number:(CGFloat)number;

/// 展示小数--四舍五入
/// @param digit 限制最大位数
/// @param number 数值
+ (NSString *)roundWithDigit:(NSInteger)digit number:(CGFloat)number;

/// 展示小数--向上取整
/// @param digit 限制最大位数
/// @param number 数值
+ (NSString *)ceilWithDigit:(NSInteger)digit number:(CGFloat)number;

/// 展示小数--向下取整
/// @param digit 限制最大位数
/// @param number 数值
+ (NSString *)floorWithDigit:(NSInteger)digit number:(CGFloat)number;

/// 获取最大值
/// @param numberArray 数组
+ (CGFloat)maxOfNumbers:(NSArray <NSString *>*)numberArray;

/// 获取最小值
/// @param numberArray 数组
+ (CGFloat)minOfNumbers:(NSArray <NSString *>*)numberArray;

/// 获取平均值
/// @param numberArray 数组
+ (CGFloat)averageOfNumbers:(NSArray <NSString *>*)numberArray;

/// 获取总数
/// @param numberArray 数组
+ (CGFloat)sumOfNumbers:(NSArray <NSString *>*)numberArray;

/// 获取最大值的角标
/// @param numberArray 数组
+ (NSInteger)indexOfMaxValue:(NSArray <NSString *>*)numberArray;

/// 获取最小值的角标
/// @param numberArray 数组
+ (NSInteger)indexOfMinValue:(NSArray <NSString *>*)numberArray;

@end

NS_ASSUME_NONNULL_END
