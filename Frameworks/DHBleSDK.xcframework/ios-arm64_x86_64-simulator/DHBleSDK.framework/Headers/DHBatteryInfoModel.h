//
//  DHBatteryInfoModel.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHBatteryInfoModel : NSObject

/// 电量（0-100）
@property (nonatomic, assign) NSInteger battery;
/// 充电状态（0.未充电 1.充电中）；需设备固件支持，旧固件未返回时默认为0
@property (nonatomic, assign) NSInteger status;
/// 是否低电（0.否 1.是）
@property (nonatomic, assign) BOOL isLower;

@end

NS_ASSUME_NONNULL_END
