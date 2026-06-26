//
//  DHBluetoothManager.m
//  DHBleSDKDemo
//
//  Created by DHS on 2022/10/13.
//

#import "DHBluetoothManager.h"

@implementation DHBluetoothManager

static DHBluetoothManager * _shared = nil;

+ (__kindof DHBluetoothManager *)shareInstance
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _shared = [[super allocWithZone:NULL] init];
    }) ;
    return _shared;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [DHBluetoothManager shareInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone
{
    return [DHBluetoothManager shareInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [DHBleCentralManager shareInstance].connectDelegate = self;
        self.isConnected = NO;
    }
    return self;
}


- (void)bindedOk
{
    //保存本地，重新打开将重连
    [DHBleCentralManager setBindedStatus:YES];
}

- (void)unBindDevice
{
    [DHBleCentralManager setBindedStatus:NO];
    [DHBleCentralManager disconnectDevice];
}


- (void)centralManagerDidConnectPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}


- (void)centralManagerDidFunctionMenu:(DeviceFuncV2Model *)deviceFuncModel peripheral:(DHPeripheralModel *)peripheral
{
    self.deviceFuncV2Model = deviceFuncModel;
    
}

- (void)centralManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}

- (void)centralManagerDidFailedPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}

- (void)centralManagerDidUpdateState:(BOOL)isOn {
    if (!isOn) {
        self.isConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
    }
}

@end
