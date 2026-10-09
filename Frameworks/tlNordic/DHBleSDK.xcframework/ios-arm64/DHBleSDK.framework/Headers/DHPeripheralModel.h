//
//  DHPeripheralModel.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHPeripheralModel : NSObject

/// 外围设备
@property (nonatomic,strong) CBPeripheral *peripheral;
/// MAC地址
@property (nonatomic,strong) NSString *macAddr;
/// UUID
@property (nonatomic,strong) NSString *uuid;
/// 设备名
@property (nonatomic,strong) NSString *name;
/// 信号强度（0-255 数值越小距离越近）
@property (nonatomic,assign) NSInteger rssi;
/// 设备型号(从广播包解析)
@property (nonatomic,strong) NSString *deviceModel;
/// FF广播协议版本；旧格式为0
@property (nonatomic,assign) NSInteger ffProtocolVersion;
/// 芯片平台；仅新格式有效，旧格式为-1
@property (nonatomic,assign) NSInteger chipPlatform;
/// 客户代码；仅新格式有效，旧格式为-1
@property (nonatomic,assign) NSInteger customerCode;
/// 广播充电状态：0未充电 1充电中 2充满，-1未提供或不支持(旧固件该字节为0x80)
@property (nonatomic,assign) NSInteger batteryStatus;

@end

NS_ASSUME_NONNULL_END
