//
//  DHBleCentralManager.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/24.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <DHBleSDK/DHBleConnectDelegate.h>

NS_ASSUME_NONNULL_BEGIN


@interface DHBleCentralManager : NSObject

/// 单例
+ (__kindof DHBleCentralManager *)shareInstance;
/// 初始化设置服务
/// @param uuids 服务UUID
+ (void)initWithServiceUuids:(NSArray <NSString *>*)uuids;

/// 开始搜索 注意:如果设备未解绑,即使搜索到设备也不调用代理返回设备列表
+ (void)startScan;
/// 停止搜索
+ (void)stopScan;


//处理置后台,被杀后,打开app，不能重连问题;
+ (void)checkAndAutoReconnectDevice;

/// 连接设备
/// @param model 设备模型
+ (void)connectDeviceWithModel:(DHPeripheralModel *)model;
/// 断开连接
+ (void)disconnectDevice;
/// 蓝牙关闭状态
+ (BOOL)isPoweredOff;
/// 设备连接状态
+ (BOOL)isConnected;
/// 设备绑定状态
+ (BOOL)isBinded;
/// 设置绑定状态
/// @param isBinded 是否绑定
+ (void)setBindedStatus:(BOOL)isBinded;
/// 设置是否打印日志
/// @param isLog 是否打印日志
+ (void)setLogStatus:(BOOL)isLog;
///是否为Telink平台设备
+ (BOOL)isTelinkDevice;

/// 蓝牙连接代理
@property (nonatomic, weak) id<DHBleConnectDelegate> connectDelegate;

@end

NS_ASSUME_NONNULL_END
