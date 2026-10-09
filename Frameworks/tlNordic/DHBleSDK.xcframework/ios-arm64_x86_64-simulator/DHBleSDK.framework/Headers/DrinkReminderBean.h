//
//  DrinkReminderBean.h
//  DHBleSDK
//
//  久坐提醒(协议2.2.18)与喝水提醒(协议2.2.19)通用设置实体, 与 Android SDK 同名对齐:
//  isOpen 开关 / startHour~endMin 起止时段 / remindDuration 提醒间隔(分钟) / repeatModel 重复日(bit0=周日…bit6=周六, 暂不开放编辑固定每天)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DrinkReminderBean : NSObject

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, assign) NSInteger startHour;
@property (nonatomic, assign) NSInteger startMin;
@property (nonatomic, assign) NSInteger endHour;
@property (nonatomic, assign) NSInteger endMin;
@property (nonatomic, assign) NSInteger remindDuration;
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *repeatModel;

/** 打包为6字节设置帧: bit7开关|bit0-6每天 + 起止时段 + 间隔(与 Android getSedentaryRemindCmd/getDrinkRemindCmd 一致) */
- (NSData *)valueWithJL;

@end

NS_ASSUME_NONNULL_END
