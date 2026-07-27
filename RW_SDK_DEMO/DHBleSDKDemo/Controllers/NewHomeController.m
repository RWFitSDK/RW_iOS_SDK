//
//  NewHomeController.m
//  DHBleSDKDemo
//
//  Created by DHS on 2025/1/14.
//

#import "NewHomeController.h"
#import <DHBleSDK/DHDailyStepModel.h>
#import <DHBleSDK/DHDailySleepModel.h>
#import <DHBleSDK/DHDailyHrModel.h>
#import <DHBleSDK/DHDailyBoModel.h>
#import <DHBleSDK/DHDailyHrvModel.h>
#import <DHBleSDK/DHDeviceInfoModel.h>
#import <DHBleSDK/DHBpModeSetModel.h>
#import <DHBleSDK/DHDailyBpModel.h>

#import "WorkoutTypeController.h"
#import "ScanViewController.h"
#import <DHFoundation/SSZipArchive.h>

@interface NewHomeController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UILabel *infoDeviceNameLb;
@property (nonatomic, strong) IBOutlet UILabel *infoDeviceStateLb;
@property (nonatomic, strong) IBOutlet UILabel *infoDeviceMacLb;
@property (nonatomic, strong) IBOutlet UITableView *functionTb;
@property (nonatomic, strong) IBOutlet UIButton *infoDeviceBindBt;
@property (nonatomic, strong) UILabel *headerStatusLb;
@property (nonatomic, strong) UILabel *headerNameLb;
@property (nonatomic, strong) UILabel *headerMacLb;
@property (nonatomic, strong) UILabel *headerUuidLb;
@property (nonatomic, strong) UILabel *headerDeviceModelLb;
@property (nonatomic, strong) UIButton *retryConnectBt;
@property (nonatomic, strong) UIButton *searchDeviceBt;

@property (nonatomic, strong) NSArray *functionBaseList;
@property (nonatomic, strong) NSArray *functionHealthList;
@property (nonatomic, strong) NSArray *functionWorkoutList;
@property (nonatomic, strong) NSArray *functionOTAList;


@property (nonatomic, strong) NSArray *groupTitleArr;


@end

@implementation NewHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.groupTitleArr = @[@"Basic function commands-基础功能指令", @"Health data synchronization-健康数据同步(实时单次与全天检测)", @"Workout-多运动", @"Firmware upgrade-固件升级"];

    self.functionBaseList = @[@"SDK Version", @"Get Bluetooth MAC address(获取蓝牙Mac地址)", @"Set user information(设置用户信息)", @"Get firmware information(获取固件信息)", @"Get Battery(获取电量)", @"Get Video Switch(获取视频控制开关)", @"Set Video Switch(设置视频控制开关)", @"Get LED brightness level(获取LED亮屏强度)", @"Set LED brightness level(设置LED亮屏强度)", @"Get Wearing position(获取佩戴位置)", @"Set Wearing position(设置佩戴位置)",@"Activate and deactivate the camera(启动与关闭拍照)", @"Find Device(查找设备)", @"Shut down and restore to factory settings(关机,恢复出厂设置)", @"Alarm Clock - Get Alarm Clock(闹钟-获取闹钟)", @"Alarm clock - Set alarm(闹钟-设置闹钟)", @"Alarm Clock - Delete all alarms(闹钟-删除所有闹钟)", @"Get the number of vibrations-震动次数获取",@"Set the number of vibrations-震动次数设置", @"Get screen sleep mode-睡眠模式获取", @"Set screen sleep mode-睡眠模式设置", @"Get Message push notification switch-消息推送开关获取", @"Set Message push notification switch-消息推送开关设置", @"Check if receiving likes/comments is enabled-获取赞念是否打开", @"Set whether the likes feature is enabled.-设置赞念是否打开", @"Get heart rate alarm configuration-获取心率报警配置", @"Set heart rate alarm configuration-设置心率报警配置", @"Get blood oxygen alarm configuration-获取血氧报警配置", @"Set blood oxygen alarm configuration-设置血氧报警配置", @"Set Time Format-设置12/24小时时间显示格式", @"Get Alarm Vibration Duration-获取闹钟震动时长", @"Set Alarm Vibration Duration-设置闹钟震动时长", @"Get Vibration Interval-获取震动间隔时长", @"Set Vibration Interval-设置震动间隔时长"];

    self.functionHealthList = @[@"Real-time, single-instance health data monitoring-实时单次启动健康数据检测(心率,血氧,HRV, 压力, 血糖)", @"Get HeartRate Monitor(获取心率监听)", @"Set HeartRate Monitor(设置心率监听)",@"Get Blood oxygen Monitor(获取血氧监听)", @"Set Blood oxygen Monitor(设置血氧监听)",@"Get HRV Monitor(获取HRV监听)", @"Set HRV Monitor(设置HRV监听)",@"Get PPG Monitor(获取PPG监听)", @"Set PPG Monitor(设置PPG监听)",@"Get Stress Monitor(获取压力监听)", @"Set Stress Monitor(设置压力监听)",@"Get Blood Sugar Monitor(获取血糖监听)", @"Set Blood Sugar Monitor(设置血糖监听)", @"Sync all your health data(同步所有健康数据)", @"Get Blood Pressure Monitor(获取血压监听)", @"Set Blood Pressure Monitor(设置血压监听)", @"Get Temperature Monitor(获取定时体温监测)", @"Set Temperature Monitor(设置定时体温监测)", @"Get Muslim Time Display Mode(获取Muslim时间显示模式)", @"Set Muslim Time Display Mode(设置Muslim时间显示模式)", @"Get Muslim Count Reset Mode(获取Muslim计数清零方式)", @"Set Muslim Count Reset Mode(设置Muslim计数清零方式)", @"Start Sensor Raw(启动传感器原始数据)", @"Stop Sensor Raw(停止传感器原始数据)", @"Get Sensor History Raw(获取传感器历史数据)", @"HR Calibration(心率校正)", @"Get Fall Detect(获取跌落提醒开关)", @"Set Fall Detect On(设置跌落提醒开启)", @"Get Count Reminder(获取计数提醒间隔)", @"Set Count Reminder 60min(设置计数提醒60分钟)"];

    self.functionWorkoutList = @[@"Workout-多运动"];

    self.functionOTAList = @[@"Firmware upgrade ota - 固件升级"];



    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChange:) name:BluetoothNotificationConnectStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectLoginOKChange:) name:BluetoothNotificationConnectLoginOKChange object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRingMeasureValueChange:) name:BluetoothNotificationHealthRingMeasureValueChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRingMeasureStateChange:) name:BluetoothNotificationHealthRingMeasureStateChange object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraTakePictureNotification) name:BluetoothNotificationCameraTakePicture object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healthOverAlert:) name:BluetoothNotificationRingHealthOverAlert object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorRawDataNotification:) name:BluetoothNotificationSensorRawData object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchEventNotification:) name:BluetoothNotificationTouchEvent object:nil];

    self.infoDeviceNameLb.hidden = YES;
    self.infoDeviceStateLb.hidden = YES;
    self.infoDeviceMacLb.hidden = YES;
    self.infoDeviceBindBt.hidden = YES;
    [self.functionTb mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(self.navigationView.mas_bottom).offset(10);
        make.bottom.offset(-kBottomHeight);
    }];
    [self setupDeviceHeaderView];
    [self updateDeviceHeaderView];
    [self setupLogShareButton];
}

#pragma mark - Log sharing

- (void)setupLogShareButton
{
    self.navigationView.navRightButton.hidden = NO;
    if (@available(iOS 13.0, *)) {
        UIImage *shareImage = [UIImage systemImageNamed:@"square.and.arrow.up"];
        [self.navigationView.navRightButton setImage:shareImage forState:UIControlStateNormal];
        self.navigationView.navRightButton.tintColor = HomeColor_TitleColor;
    } else {
        [self.navigationView.navRightButton setImage:nil forState:UIControlStateNormal];
        [self.navigationView.navRightButton setTitle:@"日志" forState:UIControlStateNormal];
        [self.navigationView.navRightButton setTitleColor:HomeColor_TitleColor forState:UIControlStateNormal];
        self.navigationView.navRightButton.titleLabel.font = HomeFont_ContentFont;
    }
    self.navigationView.navRightButton.accessibilityLabel = @"分享日志";
}

- (void)navRightButtonClick:(UIButton *)sender
{
    [self shareLogArchiveFromSourceView:sender];
}

- (void)shareLogArchiveFromSourceView:(UIView *)sourceView
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logDirectoryPath = [documentsPath stringByAppendingPathComponent:@"DeviceLog"];
    if (![self directoryContainsFilesAtPath:logDirectoryPath]) {
        SHOWHUD(@"暂无可分享的日志");
        return;
    }

    NSString *temporaryPath = NSTemporaryDirectory();
    for (NSString *fileName in [fileManager contentsOfDirectoryAtPath:temporaryPath error:nil]) {
        if ([fileName hasPrefix:@"RW_SDK_logs_"] && [fileName.pathExtension.lowercaseString isEqualToString:@"zip"]) {
            [fileManager removeItemAtPath:[temporaryPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyyMMdd_HHmmss";
    NSString *archiveName = [NSString stringWithFormat:@"RW_SDK_logs_%@.zip", [formatter stringFromDate:[NSDate date]]];
    NSString *archivePath = [temporaryPath stringByAppendingPathComponent:archiveName];

    SHOWHUDNODISS(@"正在打包日志…");
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        BOOL success = [SSZipArchive createZipFileAtPath:archivePath withContentsOfDirectory:logDirectoryPath];
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                [fileManager removeItemAtPath:archivePath error:nil];
                return;
            }
            HUDDISS;
            if (!success || ![fileManager fileExistsAtPath:archivePath]) {
                [fileManager removeItemAtPath:archivePath error:nil];
                SHOWHUD(@"日志分享失败");
                return;
            }

            NSURL *archiveURL = [NSURL fileURLWithPath:archivePath];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[archiveURL] applicationActivities:nil];
            UIPopoverPresentationController *popover = activityController.popoverPresentationController;
            if (popover) {
                popover.sourceView = sourceView;
                popover.sourceRect = sourceView.bounds;
            }
            activityController.completionWithItemsHandler = ^(UIActivityType _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                [fileManager removeItemAtPath:archivePath error:nil];
            };
            [strongSelf presentViewController:activityController animated:YES completion:nil];
        });
    });
}

- (BOOL)directoryContainsFilesAtPath:(NSString *)directoryPath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory] || !isDirectory) {
        return NO;
    }

    NSDirectoryEnumerator<NSString *> *enumerator = [fileManager enumeratorAtPath:directoryPath];
    for (NSString *relativePath in enumerator) {
        NSString *fullPath = [directoryPath stringByAppendingPathComponent:relativePath];
        BOOL childIsDirectory = NO;
        if ([fileManager fileExistsAtPath:fullPath isDirectory:&childIsDirectory] && !childIsDirectory) {
            return YES;
        }
    }
    return NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if ([DHBluetoothManager shareInstance].isConnected){
        self.infoDeviceStateLb.text = @"Connected";
    }
    else{
        self.infoDeviceStateLb.text = @"Disconnected";
    }
    [self updateDeviceHeaderView];
}

- (void)connectStateChange:(NSNotification *)ntf
{
    NSLog(@"NewHomeController connectStateChange");
    if ([DHBluetoothManager shareInstance].isConnected){
        self.infoDeviceStateLb.text = @"Connected";
    }
    else{
        self.infoDeviceStateLb.text = @"Disconnected";
    }
    [self updateDeviceHeaderView];
}

- (void)connectLoginOKChange:(NSNotification *)ntf
{
    [[DHBluetoothManager shareInstance] bindedOk];

    if ([DHBleCentralManager isBinded]){
        [self.infoDeviceBindBt setTitle:@"Binded" forState:UIControlStateNormal];
    }
    else{
        [self.infoDeviceBindBt setTitle:@"Unbound" forState:UIControlStateNormal];
    }
    [self updateDeviceHeaderView];
}


- (IBAction)unbindButttonClick:(id)sender
{
    if ([DHBleCentralManager isBinded]){
        [[DHBluetoothManager shareInstance] unBindDevice];


        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)setupDeviceHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 178)];
    headerView.backgroundColor = HomeColor_BlockColor;

    self.headerStatusLb = [self createHeaderLabelWithFrame:CGRectMake(15, 10, kScreenWidth - 30, 20) font:HomeFont_TitleFont];
    self.headerNameLb = [self createHeaderLabelWithFrame:CGRectMake(15, 38, kScreenWidth - 30, 18) font:HomeFont_ContentFont];
    self.headerMacLb = [self createHeaderLabelWithFrame:CGRectMake(15, 62, kScreenWidth - 30, 18) font:HomeFont_ContentFont];
    self.headerUuidLb = [self createHeaderLabelWithFrame:CGRectMake(15, 86, kScreenWidth - 30, 18) font:HomeFont_ContentFont];
    self.headerDeviceModelLb = [self createHeaderLabelWithFrame:CGRectMake(15, 110, kScreenWidth - 30, 18) font:HomeFont_ContentFont];

    CGFloat buttonTop = 138;
    CGFloat buttonSpace = 8;
    CGFloat buttonWidth = (kScreenWidth - 30 - buttonSpace) / 2.0;
    self.retryConnectBt = [self createHeaderButtonWithFrame:CGRectMake(15, buttonTop, buttonWidth, 34) title:@"Retry Connect" action:@selector(retryConnectButtonClick)];
    self.searchDeviceBt = [self createHeaderButtonWithFrame:CGRectMake(15 + buttonWidth + buttonSpace, buttonTop, buttonWidth, 34) title:@"Search Device" action:@selector(searchDeviceButtonClick)];

    [headerView addSubview:self.headerStatusLb];
    [headerView addSubview:self.headerNameLb];
    [headerView addSubview:self.headerMacLb];
    [headerView addSubview:self.headerUuidLb];
    [headerView addSubview:self.headerDeviceModelLb];
    [headerView addSubview:self.retryConnectBt];
    [headerView addSubview:self.searchDeviceBt];

    self.functionTb.tableHeaderView = headerView;
}

- (UILabel *)createHeaderLabelWithFrame:(CGRect)frame font:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.font = font;
    label.textColor = HomeColor_TitleColor;
    label.numberOfLines = 1;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

- (UIButton *)createHeaderButtonWithFrame:(CGRect)frame title:(NSString *)title action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = frame;
    button.titleLabel.font = [UIFont systemFontOfSize:13.0];
    button.backgroundColor = COLOR(@"#F2F2F2");
    button.layer.cornerRadius = 6.0;
    button.layer.borderWidth = 0.5;
    button.layer.borderColor = HomeColor_LineColor.CGColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:HomeColor_TitleColor forState:UIControlStateNormal];
    [button setTitleColor:HomeColor_SubTitleColor forState:UIControlStateDisabled];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)updateDeviceHeaderView
{
    NSString *uuid = [DHBleCentralManager currentBindedUUID] ?: @"";
    BOOL hasSavedDevice = uuid.length > 0;
    BOOL isConnected = [DHBluetoothManager shareInstance].isConnected || [DHBleCentralManager isConnected];
    NSString *name = self.deviceModel.name.length ? self.deviceModel.name : [[DHBluetoothManager shareInstance] savedDeviceName];
    NSString *mac = self.deviceModel.macAddr.length ? self.deviceModel.macAddr : [[DHBluetoothManager shareInstance] savedDeviceMac];
    NSString *deviceModel = self.deviceModel.deviceModel.length ? self.deviceModel.deviceModel : [[DHBluetoothManager shareInstance] savedDeviceModel];

    self.headerStatusLb.text = isConnected ? @"Connected" : (hasSavedDevice ? @"Saved device, disconnected" : @"No saved device");
    self.headerNameLb.text = [NSString stringWithFormat:@"Name: %@", name.length ? name : @"-"];
    self.headerMacLb.text = [NSString stringWithFormat:@"MAC: %@", mac.length ? mac : @"-"];
    self.headerUuidLb.text = [NSString stringWithFormat:@"UDID: %@", uuid.length ? uuid : @"-"];
    self.headerDeviceModelLb.text = [NSString stringWithFormat:@"DeviceID: %@", deviceModel.length ? deviceModel : @"-"];

    self.retryConnectBt.enabled = hasSavedDevice && !isConnected;
    [self.searchDeviceBt setTitle:hasSavedDevice ? @"Search Again" : @"Search Device" forState:UIControlStateNormal];
}

- (void)retryConnectButtonClick
{
    if ([DHBleCentralManager isPoweredOff]) {
        SHOWHUD(@"手机蓝牙未开启")
        return;
    }
    if (![DHBleCentralManager currentBindedUUID].length) {
        SHOWHUD(@"No saved device")
        return;
    }
    [DHBleCentralManager checkAndAutoReconnectDevice];
}

- (void)searchDeviceButtonClick
{
    if ([DHBleCentralManager currentBindedUUID].length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"重新搜索设备"
                                                                       message:@"将清除 Demo 中保存的设备并断开当前连接。如设备已通过系统蓝牙配对（ANCS 通知等功能会触发系统配对），还需要到 iPhone 设置 > 蓝牙 中手动忽略此设备，否则系统配对关系仍会保留。"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf startSearchDevice];
        }];
        [alert addAction:cancelAction];
        [alert addAction:continueAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self startSearchDevice];
}

- (void)startSearchDevice
{
    [[DHBluetoothManager shareInstance] clearSavedDeviceInfo];
    [DHBleCentralManager setBindedStatus:NO];
    [DHBleCentralManager disconnectDevice];

    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.navTitle = @"搜索设备";
    vc.navRightImage = @"public_nav_refresh";
    [self.navigationController pushViewController:vc animated:YES];
    [self updateDeviceHeaderView];
}

- (void)updateRingMeasureStateChange:(NSNotification *)ntf
{
    NSLog(@"updateRingMeasureStateChange 测量完成 结束");
}

- (void)updateRingMeasureValueChange:(NSNotification *)ntf
{
    NSDictionary *tUserInfo = ntf.userInfo;
    NSInteger tDataValue = [tUserInfo[@"dataValue"] integerValue];
    NSInteger tDataType = [tUserInfo[@"dataType"] integerValue];

    NSLog(@"updateRingMeasureValueChange 0x%04X 数值: %zd", (unsigned int)tDataType, tDataValue);

    if (tDataType == BLE_KEY_APP_REAL_TIME_MUSLIM_COUNT){ //Muslim Count

    }
    else if (tDataType == BLE_KEY_APP_REAL_BLOOD_SUGAR_DATA){ //BloodSugar 血糖

    }
    else if (tDataType == BLE_KEY_APP_REAL_TIME_HRV_DATA){ //HRV

    }
    else if (tDataType == BLE_KEY_APP_REAL_TIME_HR_DATA){ //HR 心率

    }
    else if (tDataType == BLE_KEY_APP_REAL_TIME_BLOOD_OXYGEN_DATA){ //BloodOxygen 血氧

    }
    else if (tDataType == BLE_KEY_APP_REAL_TIME_STRESS_DATA){ //Stress 压力

    }
    else if (tDataType == BLE_KEY_APP_REAL_TIME_BP_DATA){ //BloodPressure 血压
        NSInteger sp = [tUserInfo[@"systolic"] integerValue]; //收缩压
        NSInteger dp = [tUserInfo[@"diastolic"] integerValue]; //舒张压
        NSLog(@"BloodPressure sp=%zd dp=%zd", sp, dp);
    }
}

- (void)cameraTakePictureNotification {
    //进行拍照
    NSLog(@"cameraTakePictureNotification 进行拍照");
}

- (void)healthOverAlert:(NSNotification *)ntf
{
    NSDictionary *tUserInfo = ntf.userInfo;
    NSInteger tType = [tUserInfo[@"type"] integerValue];
    NSInteger tValue = [tUserInfo[@"value"] integerValue];

    if (tType == 0){ //HeartRate Alert Over

    }
    else if (tType == 1){ //SP02

    }
    else if (tType == 2){ //HeartRate Alert Under

    }
}

- (void)sensorRawDataNotification:(NSNotification *)ntf
{
    NSDictionary *tUserInfo = ntf.userInfo;
    NSInteger sensorType = [tUserInfo[@"sensorType"] integerValue];
    if (sensorType == 1) {
        NSArray *ppgData = tUserInfo[@"ppgData"];
        NSLog(@"SensorRaw PPG count: %zd", ppgData.count);
    } else if (sensorType == 2) {
        NSArray *accData = tUserInfo[@"accData"];
        NSLog(@"SensorRaw ACC count: %zd", accData.count);
    } else if (sensorType == 3) {
        NSArray *ppgRedData = tUserInfo[@"ppgRedData"];
        NSLog(@"SensorRaw PPG Red count: %zd", ppgRedData.count);
    } else if (sensorType == 4) {
        NSArray *irData = tUserInfo[@"irData"];
        NSLog(@"SensorRaw IR count: %zd", irData.count);
    } else if (sensorType == 5) {
        NSArray *sleepData = tUserInfo[@"sleepData"];
        NSLog(@"SensorRaw Sleep count: %zd", sleepData.count);
        for (NSDictionary *item in sleepData) {
            NSLog(@"  timestamp=%@ mode=%@", item[@"timestamp"], item[@"mode"]);
        }
    }
}

- (void)muslimCountResetModeNotification:(NSNotification *)ntf
{
    NSLog(@"Muslim Count Reset Mode set successfully");
}

- (void)touchEventNotification:(NSNotification *)ntf
{
    NSDictionary *tUserInfo = ntf.userInfo;
    NSInteger keyType = [tUserInfo[@"keyType"] integerValue];   // 1:触摸按键 2:跌落
    NSInteger touchType = [tUserInfo[@"touchType"] integerValue]; // 1:单击 2:双击 3:三击 4:长按 5:甩动
    NSLog(@"TouchEvent keyType=%zd touchType=%zd", keyType, touchType);
    if (keyType == 2) {
        NSLog(@"Fall Detected!");
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark- UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupTitleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.groupTitleArr[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return self.functionBaseList.count;
    }
    else if (section == 1){
        return self.functionHealthList.count;
    }
    else if (section == 2){
        return self.functionWorkoutList.count;
    }
    else{
        return  self.functionOTAList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"VaperFunctionCell"];
    if (!tCell){
        tCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"VaperFunctionCell"];
    }
    tCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    tCell.textLabel.font = [UIFont systemFontOfSize:14.0];
    tCell.textLabel.numberOfLines = 0;
    tCell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;

    if (indexPath.section == 0){
        tCell.textLabel.text = [self.functionBaseList objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1){
        tCell.textLabel.text = [self.functionHealthList objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 2){
        tCell.textLabel.text = [self.functionWorkoutList objectAtIndex:indexPath.row];
    }
    else{
        tCell.textLabel.text = [self.functionOTAList objectAtIndex:indexPath.row];
    }
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == 0){
        if (indexPath.row == 0){ //sdk version
            NSLog(@"%@", [DHBleCommand getSDKVersion]);
        }
        else if (indexPath.row == 1){ //mac
            [DHBleCommand ringGetMacAddress:^(int code, id  _Nonnull data) {
                DHDeviceInfoModel *tDeviceInfoData = data;
                NSLog(@"mac: %@", tDeviceInfoData.macAddr);
            }];
        }
        else if (indexPath.row == 2){ //Set user information
            DHUserInfoSetModel *userInfoModel = [[DHUserInfoSetModel alloc] init];
            userInfoModel.gender = 1;
            userInfoModel.height = 170;
            userInfoModel.weight = 600;
            userInfoModel.stepGoal = 8000;
            userInfoModel.age = 20;
            [DHBleCommand setUserInfo:userInfoModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"set ok");
                }
            }];
        }
        else if (indexPath.row == 3){ //Get firmware information
            [DHBleCommand getFirmwareVersion:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"getFirmwareVersion OK");
                    DHFirmwareVersionModel *model = data;
                    NSLog(@"型号 %@ 固件版本 %@ UI版本 %@", model.deviceModel, model.firmwareVersion, model.uiVersion);
                }
            }];
        }
        else if (indexPath.row == 4){ //Get Battery
            [DHBleCommand getBattery:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHBatteryInfoModel *model = data;
                    NSLog(@"getBattery OK 电量值 %zd", model.battery);
                }
            }];
        }
        else if (indexPath.row == 5){// 获取视频控制开关
            [DHBleCommand getVideoHid:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHVideoHidSetModel *model = data;
                    NSLog(@"getVideoHid OK 开关 %d", model.isOpen);
                }
            }];
        }
        else if (indexPath.row == 6){ //设置视频控制开关
            DHVideoHidSetModel *tModeSetModel = [[DHVideoHidSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            [DHBleCommand setVideoHid:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setVideoHid OK");
                }
            }];
        }
        else if (indexPath.row == 7){// 获取LED高屏强度
            [DHBleCommand getRingLEDLight:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHLedLightSetModel *model = data;
                    NSLog(@"getRingLEDLight OK 开关 %d", model.isOpen);
                }
            }];
        }
        else if (indexPath.row == 8){ //设置LED高屏强度
            DHLedLightSetModel *tModeSetModel = [[DHLedLightSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            tModeSetModel.lightLevel = 3; //1微光2柔光3强光
            [DHBleCommand setRingLEDLight:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setRingLEDLight OK");
                }
            }];
        }
        else if (indexPath.row == 9){// 获取佩戴位置
            [DHBleCommand getRingWearHand:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSInteger tWearHand = [data intValue];
                    NSLog(@"getRingWearHand OK 佩戴位置 %zd", tWearHand);
                }
            }];
        }
        else if (indexPath.row == 10){ //设置佩戴位置
            uint8_t tModeSetModel = 0; //0左手 1右手
            [DHBleCommand setRingWearHand:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setRingWearHand OK");
                }
            }];
        }
        else if (indexPath.row == 11){ // 启动与关闭拍照

            //APP进相机界面启动 1为控制设备进对应界面, 0为控制设备退出
            //BluetoothNotificationCameraTakePicture 设备发出拍照通知,进行拍照
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isTakePhoto){

                [DHBleCommand controlCamera:1 block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 12){ // 查找设备
            [DHBleCommand controlFindDeviceBegin:^(int code, id  _Nonnull data) {

            }];
        }
        else if (indexPath.row == 13){ // 关机,恢复出厂设置
            // 1关机 2 恢复出厂
            [DHBleCommand controlDevice:2 block:^(int code, id  _Nonnull data) {

            }];
        }
        else if (indexPath.row == 14){ //Alarm-Get Alarms
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isAlarm){
                [DHBleCommand getAlarms:^(int code, id  _Nonnull data) {
                    NSArray *tAlarmList = data;
                    NSLog(@"getAlarms %zd", tAlarmList.count);
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 15){ //Alarm-Set Alarms
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isAlarm){
                DHAlarmSetModel *tAlarm1 = [[DHAlarmSetModel alloc] init];
                tAlarm1.hour = 07; //时
                tAlarm1.minute = 00;//分
                tAlarm1.isOpen = true;//开关
                tAlarm1.repeats = @[@(0),@(0),@(0),@(0),@(0),@(0),@(1)]; //重复周期,周六重复

                DHAlarmSetModel *tAlarm2 = [[DHAlarmSetModel alloc] init];
                tAlarm2.hour = 8;
                tAlarm2.minute = 00;
                tAlarm2.isOpen = true;
                tAlarm2.repeats = @[]; //单次闹钟

                [DHBleCommand setAlarms:@[tAlarm1, tAlarm2] block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 16){ //Alarm-delete all Alarms
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isAlarm){
                [DHBleCommand setAlarms:@[] block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 17){ //震动次数获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMotoVibrationLevel){
                [DHBleCommand getRingMotorLevel:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHVibrationLevelModel *tVibrationModel = data;
                        NSLog(@"getRingMotorLevel Level %d num %d", tVibrationModel.vibrationLevel, tVibrationModel.vibrationNumber);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 18){ //震动次数设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMotoVibrationLevel){
                [DHBleCommand setRingMotorLevel:1 motorNum:2 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"set ok");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 19){ //睡眠模式获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isBackLightSleepMode){
                [DHBleCommand getDisplaySleepMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHBrightTimeSetModel *tModel = data;
                        NSLog(@"getDisplaySleepMode sleepOpen %d sleepStartHour %d sleepStartMin %d", tModel.sleepOpen, tModel.sleepStartHour, tModel.sleepEndMin);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 20){ //睡眠模式设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isBackLightSleepMode){
                DHBrightTimeSetModel *sleepModel = [[DHBrightTimeSetModel alloc] init];
                sleepModel.sleepOpen = YES;
                sleepModel.sleepStartHour = 10;
                sleepModel.sleepStartMin = 00;
                sleepModel.sleepEndHour = 20;
                sleepModel.sleepEndMin = 00;
                [DHBleCommand setDisplaySleepMode:sleepModel block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 21){ //消息推送开关获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isPushMsg){
                [DHBleCommand ringGetAncs:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHAncsSetModel *ancsModel = data;

                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 22){ //消息推送开关设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isPushMsg){
                DHAncsSetModel *tAncsModel = [[DHAncsSetModel alloc] init];
                tAncsModel.isSMS = YES;
                [DHBleCommand ringSetAncs:tAncsModel block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 23){ //获取赞念是否打开
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimCountSwitch){
                [DHBleCommand getMuslimCountSwitch:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        Boolean tOpen = [data boolValue];
                        NSLog(@"getMuslimCountSwitch tOpen %d", tOpen);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 24){ //设置赞念是否打开
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimCountSwitch){
                [DHBleCommand setMuslimCountSwitch:1 block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 25){ //获取心率报警配置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                [DHBleCommand getHRAlert:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHRAlertModel *model = data;
                        NSLog(@"getHRAlert %d %zd", model.isOpen, model.overValue);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 26){ //设置心率报警配置
            // BluetoothNotificationRingHealthOverAlert
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                DHHRAlertModel *tHRAlertModel = [[DHHRAlertModel alloc] init];
                tHRAlertModel.isOpen = YES;
                tHRAlertModel.overValue = 160;
                tHRAlertModel.underValue = 0xff;
                [DHBleCommand setHRAlert:tHRAlertModel block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 27){ //获取血氧报警配置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                [DHBleCommand getSP02Alert:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHRAlertModel *model = data;
                        NSLog(@"getSP02Alert %d %zd", model.isOpen, model.overValue);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 28){ //设置血氧报警配置
            // BluetoothNotificationRingHealthOverAlert
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                DHHRAlertModel *tSP02AlertModel = [[DHHRAlertModel alloc] init];
                tSP02AlertModel.isOpen = YES;
                tSP02AlertModel.overValue = 94;
                [DHBleCommand setSP02Alert:tSP02AlertModel block:^(int code, id  _Nonnull data) {

                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 29){
            [DHBleCommand ringSetTimeformat:0 block:^(int code, id  _Nonnull data) {
                NSLog(@"ringSetTimeformat code %d", code);
            }];
        }
        else if (indexPath.row == 30){ //获取闹钟震动时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportAlarmVibrationDuration){
                [DHBleCommand getAlarmVibrationDuration:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getAlarmVibrationDuration count %@", data);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 31){ //设置闹钟震动时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportAlarmVibrationDuration){
                [DHBleCommand setAlarmVibrationDuration:2 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setAlarmVibrationDuration OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 32){ //获取震动间隔时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportVibrationInterval){
                [DHBleCommand getVibrationInterval:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getVibrationInterval %@ms", data);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 33){ //设置震动间隔时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportVibrationInterval){
                [DHBleCommand setVibrationInterval:100 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setVibrationInterval OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
    }
    else if (indexPath.section == 1){
        if (indexPath.row == 0){ //
            //BluetoothNotificationHealthRingMeasureValueChange 通知获取测试的值
            //BluetoothNotificationHealthRingMeasureStateChange 测试完成通知

            //启动心率测试
            [DHBleCommand controlOpen:1 dataType:BLE_KEY_BLOOD_PRESSURE block:^(int code, id  _Nonnull data) {

            }];

            //启动血氧测试
    //        [DHBleCommand controlOpen:1 dataType:BLE_KEY_BLOOD_OXYGEN block:^(int code, id  _Nonnull data) {
    //
    //        }];
            //启动HRV测试
    //        [DHBleCommand controlOpen:1 dataType:BLE_KEY_HRV block:^(int code, id  _Nonnull data) {
    //
    //        }];

            //启动压力Stress测试, 确保设备支持压力
    //        [DHBleCommand controlOpen:1 dataType:BLE_KEY_STRESS block:^(int code, id  _Nonnull data) {
    //
    //        }];

            //启动血糖测试, 确保设备支持血糖
    //        [DHBleCommand controlOpen:1 dataType:BLE_KEY_BLOOD_SUGAR block:^(int code, id  _Nonnull data) {
    //
    //        }];
        }
        else if (indexPath.row == 1){ //获取心率监听
            [DHBleCommand getHeartRateMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHHeartRateModeSetModel *model = data;
                    NSLog(@"getHeartRateMode OK 开关 %d 检测周期 %d", model.isOpen, model.interval);
                }
            }];
        }
        else if (indexPath.row == 2){ //设置心率监听

            DHHeartRateModeSetModel *tModeSetModel = [[DHHeartRateModeSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            tModeSetModel.startHour = 00;
            tModeSetModel.startMinute = 00;
            tModeSetModel.endHour = 23;
            tModeSetModel.endMinute = 59;
            tModeSetModel.interval = 30; //30分钟
            [DHBleCommand setHeartRateMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setHeartRateMode OK");
                }
            }];
        }
        else if (indexPath.row == 3){// 获取血氧监听
            [DHBleCommand getBoMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHBoModeSetModel *model = data;
                    NSLog(@"getBoMode OK 开关 %d 检测周期 %zd", model.isOpen, model.interval);
                }
            }];
        }
        else if (indexPath.row == 4){ //设置血氧监听
            DHBoModeSetModel *tModeSetModel = [[DHBoModeSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            tModeSetModel.startHour = 00;
            tModeSetModel.startMinute = 00;
            tModeSetModel.endHour = 23;
            tModeSetModel.endMinute = 59;
            tModeSetModel.interval = 60; //1小时
            [DHBleCommand setBoMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setBoMode OK");
                }
            }];
        }
        else if (indexPath.row == 5){// 获取HRV监听
            [DHBleCommand getHrvMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHHrvModeSetModel *model = data;
                    NSLog(@"getBoMode OK 开关 %d", model.isOpen);
                }
            }];
        }
        else if (indexPath.row == 6){ //设置HRV监听
            DHHrvModeSetModel *tModeSetModel = [[DHHrvModeSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            tModeSetModel.startHour = 00;
            tModeSetModel.startMinute = 00;
            tModeSetModel.endHour = 23;
            tModeSetModel.endMinute = 59;
            tModeSetModel.interval = 60; //1小时
            [DHBleCommand setHrvMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setHrvMode OK");
                }
            }];
        }
        else if (indexPath.row == 7){// 获取PPG监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportPPGMonitoring){
                [DHBleCommand getPPGMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHrvModeSetModel *model = data;
                        NSLog(@"getPPGMode OK 开关 %d", model.isOpen);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 8){ //设置PPG监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportPPGMonitoring){
                DHHrvModeSetModel *tModeSetModel = [[DHHrvModeSetModel alloc] init];
                tModeSetModel.isOpen = YES;
                tModeSetModel.startHour = 00;
                tModeSetModel.startMinute = 00;
                tModeSetModel.endHour = 23;
                tModeSetModel.endMinute = 59;
                tModeSetModel.interval = 60;
                [DHBleCommand setPPGMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setPPGMode OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 9){// 获取Stress监听
            [DHBleCommand getStressMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHStressModeSetModel *model = data;
                    NSLog(@"getStressMode OK 开关 %d", model.isOpen);
                }
            }];
        }
        else if (indexPath.row == 10){ //设置HRV监听
            DHStressModeSetModel *tModeSetModel = [[DHStressModeSetModel alloc] init];
            tModeSetModel.isOpen = YES;
            tModeSetModel.startHour = 00;
            tModeSetModel.startMinute = 00;
            tModeSetModel.endHour = 23;
            tModeSetModel.endMinute = 59;
            tModeSetModel.interval = 60; //1小时
            [DHBleCommand setStressMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"setStressMode OK");
                }
            }];
        }
        else if (indexPath.row == 11){// 获取血糖监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodSugar){

                [DHBleCommand getBloodSugarMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHBloodSugarModeSetModel *model = data;
                        NSLog(@"getBloodSugarMode OK 开关 %d", model.isOpen);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 12){ //设置血糖监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodSugar){
                DHBloodSugarModeSetModel *tModeSetModel = [[DHBloodSugarModeSetModel alloc] init];
                tModeSetModel.isOpen = YES;
                tModeSetModel.startHour = 00;
                tModeSetModel.startMinute = 00;
                tModeSetModel.endHour = 23;
                tModeSetModel.endMinute = 59;
                tModeSetModel.interval = 60; //1小时
                [DHBleCommand setBloodSugarMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setBloodSugarMode OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }

        }
        else if (indexPath.row == 13){ //Sync all your health data
            [DHBleCommand startDataSyncing:^(int code, id data){
                NSLog(@"同步完成 %d", code);
            } datablcok:^(int code, int progress, id  _Nonnull data) {
                if (code == 0) {
                    if ([data isKindOfClass:[NSArray class]]) {
                        NSArray *array = data;
                        for (id model in array) {
                            if ([model isKindOfClass:[DHDailyStepModel class]]) {  //计步数据
                                NSLog(@"同步有 计步数据");
                            }
                            else if ([model isKindOfClass:[DHDailySleepModel class]]) { //睡眠数据
                                NSLog(@"同步有 睡眠数据");
                            }
                            else if ([model isKindOfClass:[DHDailyHrModel class]]) { //心率数据
                                NSLog(@"同步有 心率数据");
                            }
                            else if ([model isKindOfClass:[DHDailyBoModel class]]) { //血氧数据
                                NSLog(@"同步有 血氧数据");
                            }
                            else if ([model isKindOfClass:[DHDailyHrvModel class]]) { ///HRV数据
                                NSLog(@"同步有 HRV数据");
                            }
                            else if ([model isKindOfClass:[DHDailyPressureModel class]]) { ///压力数据
                                NSLog(@"同步有 Stress数据");
                            }
                            else if ([model isKindOfClass:[DHDailyBloodSugarModel class]]) { ///血糖数据
                                NSLog(@"同步有 血糖数据");
                            }
                            else if ([model isKindOfClass:[DHDailyMuslimCountModel class]]) { ///赞念数据
                                NSLog(@"同步有 赞念数据");
                            }
                            else if ([model isKindOfClass:[DHDailyTempModel class]]) { ///体温数据
                                NSLog(@"同步有 体温数据");
                            }
                            else if ([model isKindOfClass:[DHDailyBpModel class]]) { ///血压数据
                                NSLog(@"同步有 血压数据");
                            }
                        }
                    }
                }
            }];
        }
        else if (indexPath.row == 14){ //获取血压监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodPressure){
                [DHBleCommand getBpMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHBpModeSetModel *model = data;
                        NSLog(@"getBpMode OK 开关 %d 检测周期 %zd", model.isOpen, model.interval);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 15){ //设置血压监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodPressure){
                DHBpModeSetModel *tModeSetModel = [[DHBpModeSetModel alloc] init];
                tModeSetModel.isOpen = YES;
                tModeSetModel.startHour = 00;
                tModeSetModel.startMinute = 00;
                tModeSetModel.endHour = 23;
                tModeSetModel.endMinute = 59;
                tModeSetModel.interval = 60; //1小时
                [DHBleCommand setBpMode:tModeSetModel block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setBpMode OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 16){ //获取定时体温监测
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportTemperatureMonitoring){
                [DHBleCommand getTimedBodyTemperature:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHeartRateModeSetModel *model = data;
                        NSLog(@"getTimedBodyTemperature OK 开关 %d 检测周期 %zd", model.isOpen, model.interval);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 17){ //设置定时体温监测
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportTemperatureMonitoring){
                DHHeartRateModeSetModel *tModeSetModel = [[DHHeartRateModeSetModel alloc] init];
                tModeSetModel.isOpen = YES;
                tModeSetModel.startHour = 00;
                tModeSetModel.startMinute = 00;
                tModeSetModel.endHour = 23;
                tModeSetModel.endMinute = 59;
                tModeSetModel.interval = 60;
                [DHBleCommand setTimedBodyTemperature:tModeSetModel block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setTimedBodyTemperature OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 18){ //获取Muslim时间显示模式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand getMuslimTimeDisplayMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSInteger tMode = [data integerValue];
                        NSLog(@"getMuslimTimeDisplayMode OK mode %zd", tMode);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 19){ //设置Muslim时间显示模式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand setMuslimTimeDisplayMode:2 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setMuslimTimeDisplayMode OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 20){ //获取Muslim计数清零方式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand getMuslimCountResetMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSInteger tMode = [data integerValue];
                        NSLog(@"getMuslimCountResetMode OK mode %zd", tMode);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 21){ //设置Muslim计数清零方式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand setMuslimCountResetMode:1 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setMuslimCountResetMode OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 22){ //启动传感器原始数据 (示例: PPG+ACC)
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportSensorRawACC){
                [DHBleCommand ringControlSensorRaw:1 type:1 block:^(int code, id  _Nonnull data) {
                    NSLog(@"Start Sensor Raw code %d", code);
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 23){ //停止传感器原始数据
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportSensorRawACC){
                [DHBleCommand ringControlSensorRaw:2 type:1 block:^(int code, id  _Nonnull data) {
                    NSLog(@"Stop Sensor Raw code %d", code);
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 24){ //获取传感器历史数据
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportSensorRawPPG){
                [DHBleCommand ringGetHistorySensorRaw:^(int code, id  _Nonnull data) {
                    NSLog(@"Sensor History Raw sync finished code %d", code);
                } dataBlock:^(int code, int progress, id  _Nonnull data) {
                    if (code == 0 && data) {
                        NSArray *resultArray = data;
                        NSLog(@"Sensor History Raw count=%zd", resultArray.count);
                        for (NSDictionary *info in resultArray) {
                            NSLog(@"  sensorType=%@ seq=%@ count=%@", info[@"sensorType"], info[@"sequence"], info[@"count"]);
                        }
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 25){ //心率校正
            [DHBleCommand startFactoryTest:0x15 block:^(int code, id  _Nonnull data) {
                NSLog(@"startFactoryTest HR Calibration code %d", code);
            }];
        }
        else if (indexPath.row == 26){ //获取跌落提醒开关
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportFallDetect){
                [DHBleCommand getFallDetect:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getFallDetect OK: %@", data);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 27){ //设置跌落提醒开关
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportFallDetect){
                [DHBleCommand setFallDetect:1 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setFallDetect ON OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 28){ //获取计数提醒间隔
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportCountReminder){
                [DHBleCommand getCountReminderInterval:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"CountReminderInterval: %@ min", data);
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
        else if (indexPath.row == 29){ //设置计数提醒间隔60分钟
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportCountReminder){
                [DHBleCommand setCountReminderInterval:30 block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"setCountReminderInterval 30 OK");
                    }
                }];
            }
            else{
                SHOWHUD(@"Not Support!");
            }
        }
    }
    else if (indexPath.section == 2){ //多运动
        if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportWorkout3){
            WorkoutTypeController *typeC = [[WorkoutTypeController alloc] initWithNibName:@"WorkoutTypeController" bundle:nil];
            typeC.navTitle = @"All Run Type";
            typeC.isHideNavigationView = NO;
            typeC.isHideNavRightButton = YES;
            typeC.isHideNavLeftButton = NO;
            [self.navigationController pushViewController:typeC animated:YES];
        }
        else{
            SHOWHUD(@"Not Support!");
        }
    }
    else{
        NSString *tFilePath = @""; //bin文件,厂家提供

        if (tFilePath.length > 0){ //注意 有升级文件后再测试
            NSData *fileData = [NSData dataWithContentsOfFile:tFilePath];
            [DHBleCommand ringOtaWithFileData:fileData block:^(int code, CGFloat progress, id  _Nonnull data) {
                NSLog(@"OTA code %d progress %.2f", code, progress);
            }];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (void)fileSyncingSuccess {
    SHOWHUD(@"升级成功");
}

- (void)fileSyncingFailed {
    SHOWHUD(@"升级失败");
}

@end
