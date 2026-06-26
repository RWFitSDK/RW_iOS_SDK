//
//  NSDate+Simple.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Simple)

/**
 NSDate 扩展属性
 */
@property (nonatomic, readonly) NSInteger    year;
@property (nonatomic, readonly) NSInteger    month;
@property (nonatomic, readonly) NSInteger    day;
@property (nonatomic, readonly) NSInteger    hour;
@property (nonatomic, readonly) NSInteger    minute;
@property (nonatomic, readonly) NSInteger    second;

/// 1为周天，2为周一，周天为周开始日计算
@property (nonatomic, readonly) NSInteger    weekday;

/// NSDateFormatter 单例模式, 避免持续消耗内存.
+ (NSDateFormatter *)dateFormatterTemp;

/// 获得当前的时区
+ (CGFloat)DateByTimeZone;

#pragma mark 转换型

/// yyyyMMdd 时间转 time interval since 1970
/// @param dateStr yyyyMMdd 格式时间字符串
+ (NSString *)get1970timeTempWithDateStr:(NSString *)dateStr;

/// 年、月、日 转 time interval since 1970
/// @param year 年
/// @param month 月
/// @param day 日
+ (NSString *)get1970timeTempWithYear:(NSInteger)year
                             andMonth:(NSInteger)month
                               andDay:(NSInteger)day;

/// 当前时间字符串 YYYY-MM-dd HH:mm:ss.SSS
+ (NSString *)currentTimeString;

/// 当前时间日期字符串 YYYY-MM-dd
+ (NSString *)currentDayString;

/// 当前时间戳
+ (NSString *)currentTimeStamp;

/// 时间字符串转时间戳
/// @param timeStr 时间字符串 yyyyMMddHHmmss
+ (NSString *)timeStampFromtimeStr:(NSString *)timeStr;

/// 获取utc 时间字符串
+ (NSArray<NSString *> *)currentTimespToUtcFormat;

/// 获取某月有几天
/// @param year 年
/// @param month 月
+ (NSInteger)getDaysInMonthWithYear:(NSInteger)year
                              month:(NSInteger)month;

/// 根据时间戳创建时间组建
/// @param dateStr 时间戳字符串
+ (NSDateComponents *)dateComponentsWithDateStr:(NSString *)dateStr;

/// 日期转为字符串
/// @param format 格式
- (NSString *)dateToStringFormat:(NSString *)format;

/**
 返回几天后的日期
 @param day (若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterDay:(NSInteger)day;

/**
 * 返回day天后的日期(若day为负数,则为|day|天前的日期)
 */
- (NSDate *)dateAfterMonth:(NSInteger)month;

/**
 返回周首日日期和最后一天

 @param firstDay 设置周首日 1天；2一；3二；4三；5四；6五；7六
 @return 返回周首日日期和最后一天
 */
- (NSArray *)getweekBeginAndEndWithFirstDay:(NSInteger)firstDay;

/**
 返回给定日期月第一天和最后一天

 @return 返回给定日期月第一天和最后一天
 */
- (NSArray *)getMonthBeginAndEnd;

/**
 * 获取一年中的总天数
 */
- (NSInteger)daysInYear;

/**
 * 获取该日期是该年的第几周
 */
- (NSInteger)weekOfYear;

/**
 * 返回当前月一共有几周(可能为4,5,6)
 */
- (NSInteger)weeksOfMonth;

/**
 * 获取该月的第一天的日期
 */
- (NSDate *)begindayOfMonth;

/**
 * 获取该月的最后一天的日期
 */
- (NSDate *)lastdayOfMonth;

#pragma mark 判断型

/**
 * 判断是否是润年
 * @return YES表示润年，NO表示平年
 */
- (BOOL)isLeapYear;

/**
 判断当前日期是否是本周
 */
- (BOOL)dateIsThisWeek;

/**
 判断当前日期是否是本月
 */
- (BOOL)dateIsThisMonth;

/// 是否是今天
- (BOOL)isToday;

/// 是否是未来
- (BOOL)isInFuture;

/// 是否是过去
- (BOOL)isInPast;

///是否提前aDate
- (BOOL)isEarlierThanDate:(NSDate *)aDate;

///是否晚于aDate
- (BOOL)isLaterThanDate:(NSDate *)aDate;

/// 是否12小时制
+ (BOOL)isHasAMPMTimeSystem;

@end

NS_ASSUME_NONNULL_END
