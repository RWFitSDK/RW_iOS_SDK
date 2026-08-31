//
//  DHBleConnectDelegate.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>
#import <DHBleSDK/DHPeripheralModel.h>
#import <DHBleSDK/DeviceFuncV2Model.h>

NS_ASSUME_NONNULL_BEGIN

/// 设备断开原因。新增值只追加在枚举尾部，避免影响已有取值。
typedef NS_ENUM(NSInteger, DHBleDisconnectReason) {
    DHBleDisconnectReasonUnknown = 0,
    DHBleDisconnectReasonManualDisconnect,
    DHBleDisconnectReasonPasswordAuthFailed,
};

@protocol DHBleConnectDelegate <NSObject>

@optional

/// 搜索到设备
/// @param peripherals 设备列表
- (void)centralManagerDidDiscoverPeripheral:(NSArray <DHPeripheralModel *>*)peripherals;

/// 连接成功
/// @param peripheral 设备
- (void)centralManagerDidConnectPeripheral:(CBPeripheral *)peripheral;

/// 配置表获取成功
/// @param deviceFuncModel 设备
- (void)centralManagerDidFunctionMenu:(DeviceFuncV2Model *)deviceFuncModel peripheral:(DHPeripheralModel *)peripheral;

/// 断开连接（已废弃），请使用 centralManagerDidDisconnectPeripheral:reason:
/// @param peripheral 设备
- (void)centralManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral
    DEPRECATED_MSG_ATTRIBUTE("Use centralManagerDidDisconnectPeripheral:reason: instead.");

/// 断开连接并返回原因。实现该方法后，SDK不再重复调用上面的旧断开回调。
/// @param peripheral 设备
/// @param reason 断开原因；密码认证失败对应DHBleDisconnectReasonPasswordAuthFailed
- (void)centralManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral reason:(DHBleDisconnectReason)reason;

/// 连接失败
/// @param peripheral 设备
- (void)centralManagerDidFailedPeripheral:(CBPeripheral *)peripheral;

/// 蓝牙开关状态更新
/// @param isOn 状态
- (void)centralManagerDidUpdateState:(BOOL)isOn;

@end

NS_ASSUME_NONNULL_END
