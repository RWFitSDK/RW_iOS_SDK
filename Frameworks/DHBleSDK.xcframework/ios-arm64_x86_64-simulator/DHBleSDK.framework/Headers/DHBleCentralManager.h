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
/// 初始化设置服务，并指定外部CBCentralManager
/// @param uuids 服务UUID
/// @param centralManager 客户统一扫描使用的CBCentralManager，传nil时SDK自行管理
+ (void)initWithServiceUuids:(NSArray <NSString *>*)uuids externalCentralManager:(nullable CBCentralManager *)centralManager;
/// 设置外部CBCentralManager
/// @param centralManager 客户统一扫描使用的CBCentralManager，传nil时恢复SDK自行管理
+ (void)setExternalCentralManager:(nullable CBCentralManager *)centralManager;
/// 是否使用外部CBCentralManager
+ (BOOL)isUsingExternalCentralManager;

/// 开始搜索 注意:如果设备未解绑,即使搜索到设备也不调用代理返回设备列表
+ (void)startScan;
/// 开始搜索并按客户代码过滤
/// @param customerCode nil表示不过滤；0x00返回旧格式和协议v1公版设备；0x01-0xFE仅返回协议v1且客户代码一致的设备
+ (void)startScanWithCustomerCode:(nullable NSNumber *)customerCode;
/// 停止搜索
+ (void)stopScan;


//处理置后台,被杀后,打开app，不能重连问题;
+ (void)checkAndAutoReconnectDevice;

/// 连接设备
/// @param model 设备模型
+ (void)connectDeviceWithModel:(DHPeripheralModel *)model;
/// 连接客户统一扫描到的设备
/// @param peripheral 客户传入的CBCentralManager扫描得到的CBPeripheral
/// @param advertisementData 广播数据
/// @param RSSI 信号强度
+ (void)connectPeripheral:(CBPeripheral *)peripheral advertisementData:(nullable NSDictionary *)advertisementData RSSI:(nullable NSNumber *)RSSI;
/// 断开连接
+ (void)disconnectDevice;
/// 蓝牙关闭状态
+ (BOOL)isPoweredOff;
/// 设备连接状态
+ (BOOL)isConnected;
/// 设备绑定状态
+ (BOOL)isBinded;
/// 当前绑定设备UUID
+ (nullable NSString *)currentBindedUUID;
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
/// SDK内部自动重连状态。宿主切换设备前可设置为NO，停止遗留重连状态。
@property (nonatomic, assign) BOOL isAutoReconnecting;
/// SDK内部自动重连超时定时器。宿主切换设备前可主动失效，避免旧任务再次发起连接。
@property (nonatomic, strong, nullable) NSTimer *reconnectTimeoutTimer;

@end

NS_ASSUME_NONNULL_END
