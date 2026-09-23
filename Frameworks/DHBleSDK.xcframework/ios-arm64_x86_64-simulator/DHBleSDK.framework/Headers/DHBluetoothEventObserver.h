//
//  DHBluetoothEventObserver.h
//  DHBleSDK
//
//  可选的通用蓝牙事件监听（公开接口，供业务层桥接第三方库，设计依据 §5.2/§5.3）。
//  协议只涉及 CoreBluetooth 类型，不出现任何第三方 SDK 类型，也不硬编码 AI 服务 UUID。
//
//  规则：
//  - 服务、特征及数据事件只转发注册服务 UUID 对应的内容，不广播其它服务数据。
//  - RW、PXI、Telink、中科 OTA 等内置服务不允许外部注册监听。
//  - 连接和断连事件作为监听的生命周期通知；同一次连接只交付一次连接就绪。
//  - 注册时若当前连接有效，SDK 自动补发连接事件及已发现的注册服务特征。
//  - 补发不重置 RW 初始化，不绕过密码认证，不回放历史 Notify 数据。
//  - 在主线程调用，所有事件在主线程交付；调用方须持有 listener 并在结束使用时注销。
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DHBluetoothEventListener <NSObject>
@optional
/// 同一次连接内只回调一次（真实事件与注册补发去重）。
- (void)bluetoothCentralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void)bluetoothCentralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error;
/// 服务/特征准备失败；不影响 RW 主连接。
- (void)bluetoothServiceUnavailable:(NSError *)error;
/// 仅转发注册服务 UUID 对应的特征发现。
- (void)bluetoothPeripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
                      error:(nullable NSError *)error;
/// 仅转发注册服务 UUID 对应特征的数据；转发后 RW 解析器不再处理该数据。
- (void)bluetoothPeripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
                      error:(nullable NSError *)error;
/// 仅转发注册服务 UUID 对应特征的 Notify 使能结果（第三方库常以订阅确认作为发送前置）。
- (void)bluetoothPeripheral:(CBPeripheral *)peripheral
didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic
                      error:(nullable NSError *)error;
@end

@interface DHBluetoothEventObserver : NSObject

/// 注册事件监听，返回注册 ID；服务为内置服务或已被占用时返回 0。
+ (NSInteger)registerBluetoothEventListener:(id<DHBluetoothEventListener>)listener
                                serviceUUID:(NSString *)serviceUUID
                                NS_SWIFT_NAME(registerBluetoothEventListener(_:serviceUUID:));

/// 按注册 ID 注销，不再转发或补发事件。
+ (void)unregisterBluetoothEventListener:(NSInteger)registrationId
                                NS_SWIFT_NAME(unregisterBluetoothEventListener(_:));

/// 查询服务是否已被通道或事件监听接管。
+ (BOOL)isServiceOccupied:(NSString *)serviceUUID;

@end

NS_ASSUME_NONNULL_END
