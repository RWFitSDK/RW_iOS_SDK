//
//  DHBluetoothManager.m
//  DHBleSDKDemo
//
//  Created by DHS on 2022/10/13.
//

#import "DHBluetoothManager.h"

static NSString * const DHSavedDeviceNameKey = @"DHSavedDeviceNameKey";
static NSString * const DHSavedDeviceMacKey = @"DHSavedDeviceMacKey";
static NSString * const DHSavedDeviceModelKey = @"DHSavedDeviceModelKey";

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

- (void)saveDeviceInfoWithModel:(DHPeripheralModel *)model
{
    if (!model) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:model.name ?: @"" forKey:DHSavedDeviceNameKey];
    [defaults setObject:model.macAddr ?: @"" forKey:DHSavedDeviceMacKey];
    [defaults setObject:model.deviceModel ?: @"" forKey:DHSavedDeviceModelKey];
    [defaults synchronize];
}

- (void)clearSavedDeviceInfo
{
    self.deviceFuncV2Model = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:DHSavedDeviceNameKey];
    [defaults removeObjectForKey:DHSavedDeviceMacKey];
    [defaults removeObjectForKey:DHSavedDeviceModelKey];
    [defaults synchronize];
}

- (NSString *)savedDeviceName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DHSavedDeviceNameKey] ?: @"";
}

- (NSString *)savedDeviceMac
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DHSavedDeviceMacKey] ?: @"";
}

- (NSString *)savedDeviceModel
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:DHSavedDeviceModelKey] ?: @"";
}

- (void)unBindDevice
{
    [DHBleCentralManager setBindedStatus:NO];
    [DHBleCentralManager disconnectDevice];
    [self clearSavedDeviceInfo];
}


- (void)centralManagerDidConnectPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}


- (void)centralManagerDidFunctionMenu:(DeviceFuncV2Model *)deviceFuncModel peripheral:(DHPeripheralModel *)peripheral
{
    self.deviceFuncV2Model = deviceFuncModel;
    [self saveDeviceInfoWithModel:peripheral];
    // 功能表到达后刷新首页与设备页，按设备能力生成对应功能项。
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}

- (void)handleDisconnectedPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = NO;
    self.deviceFuncV2Model = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}

- (void)centralManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral reason:(DHBleDisconnectReason)reason {
    NSLog(@"centralManagerDidDisconnectPeripheral reason=%ld", (long)reason);
    [self handleDisconnectedPeripheral:peripheral];
}

- (void)centralManagerDidFailedPeripheral:(CBPeripheral *)peripheral {
    self.isConnected = NO;
    self.deviceFuncV2Model = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
}

- (void)centralManagerDidUpdateState:(BOOL)isOn {
    if (!isOn) {
        self.isConnected = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothNotificationConnectStateChange object:nil];
    }
}

@end
