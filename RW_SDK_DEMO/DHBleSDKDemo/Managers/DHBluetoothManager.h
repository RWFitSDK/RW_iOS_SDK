//
//  DHBluetoothManager.h
//  DHBleSDKDemo
//
//  Created by DHS on 2022/10/13.
//

#import <Foundation/Foundation.h>
#import <DHBleSDK/DeviceFuncV2Model.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHBluetoothManager : NSObject<DHBleConnectDelegate>

/// 单例
+ (__kindof DHBluetoothManager *)shareInstance;

/// 连接状态
@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, strong, nullable) DeviceFuncV2Model *deviceFuncV2Model;

- (void)bindedOk;

- (void)unBindDevice;

@end

NS_ASSUME_NONNULL_END
