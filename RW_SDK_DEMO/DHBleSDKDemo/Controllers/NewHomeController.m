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

static UIColor *RWColor(NSString *hex)
{
    return COLOR(hex);
}

static NSString *RWChoiceText(NSString *english, NSString *chinese)
{
    BOOL isChinese = [[[NSLocale preferredLanguages] firstObject] hasPrefix:@"zh"];
    return isChinese ? chinese : english;
}

static NSString *RWMonitoringDetail(BOOL enabled, NSInteger interval)
{
    return enabled ? [NSString stringWithFormat:RWChoiceText(@"Every %zd min", @"每%zd分钟"), interval] : RWChoiceText(@"Off", @"关闭");
}

typedef void (^RWPickerSelectionBlock)(NSInteger selectedIndex);
typedef void (^RWMonitoringSelectionBlock)(BOOL enabled, NSInteger interval);

@interface RWPickerSheetController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, copy) NSString *pickerTitle;
@property (nonatomic, copy) NSArray<NSString *> *options;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) RWPickerSelectionBlock selectionBlock;
@property (nonatomic, strong) UIPickerView *pickerView;
- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                selectedIndex:(NSInteger)selectedIndex
                    selection:(RWPickerSelectionBlock)selection;
@end

@implementation RWPickerSheetController

- (instancetype)initWithTitle:(NSString *)title
                      options:(NSArray<NSString *> *)options
                selectedIndex:(NSInteger)selectedIndex
                    selection:(RWPickerSelectionBlock)selection
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _pickerTitle = [title copy];
        _options = [options copy];
        _selectedIndex = MIN(MAX(selectedIndex, 0), MAX((NSInteger)options.count - 1, 0));
        _selectionBlock = [selection copy];
        self.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.32];

    UIControl *backdrop = [[UIControl alloc] init];
    backdrop.translatesAutoresizingMaskIntoConstraints = NO;
    [backdrop addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backdrop];

    UIView *sheetView = [[UIView alloc] init];
    sheetView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 13.0, *)) {
        sheetView.backgroundColor = UIColor.systemBackgroundColor;
        sheetView.layer.cornerCurve = kCACornerCurveContinuous;
    } else {
        sheetView.backgroundColor = UIColor.whiteColor;
    }
    if (@available(iOS 11.0, *)) {
        sheetView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    sheetView.layer.cornerRadius = 18;
    sheetView.clipsToBounds = YES;
    [self.view addSubview:sheetView];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton setTitle:NSLocalizedString(@"rw_cancel", nil) forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [sheetView addSubview:cancelButton];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = self.pickerTitle;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.minimumScaleFactor = 0.8;
    [sheetView addSubview:titleLabel];

    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [confirmButton setTitle:NSLocalizedString(@"rw_confirm", nil) forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(confirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [sheetView addSubview:confirmButton];

    UIView *separator = [[UIView alloc] init];
    separator.translatesAutoresizingMaskIntoConstraints = NO;
    separator.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    [sheetView addSubview:separator];

    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [sheetView addSubview:self.pickerView];

    NSLayoutConstraint *pickerBottomConstraint = nil;
    if (@available(iOS 11.0, *)) {
        pickerBottomConstraint = [self.pickerView.bottomAnchor constraintEqualToAnchor:sheetView.safeAreaLayoutGuide.bottomAnchor];
    } else {
        pickerBottomConstraint = [self.pickerView.bottomAnchor constraintEqualToAnchor:sheetView.bottomAnchor];
    }
    [NSLayoutConstraint activateConstraints:@[
        [backdrop.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [backdrop.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [backdrop.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [backdrop.bottomAnchor constraintEqualToAnchor:sheetView.topAnchor],
        [sheetView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [sheetView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [sheetView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [sheetView.heightAnchor constraintEqualToConstant:300],
        [cancelButton.leadingAnchor constraintEqualToAnchor:sheetView.leadingAnchor constant:12],
        [cancelButton.topAnchor constraintEqualToAnchor:sheetView.topAnchor constant:8],
        [cancelButton.widthAnchor constraintGreaterThanOrEqualToConstant:56],
        [cancelButton.heightAnchor constraintEqualToConstant:44],
        [confirmButton.trailingAnchor constraintEqualToAnchor:sheetView.trailingAnchor constant:-12],
        [confirmButton.topAnchor constraintEqualToAnchor:sheetView.topAnchor constant:8],
        [confirmButton.widthAnchor constraintGreaterThanOrEqualToConstant:56],
        [confirmButton.heightAnchor constraintEqualToConstant:44],
        [titleLabel.leadingAnchor constraintEqualToAnchor:cancelButton.trailingAnchor constant:8],
        [titleLabel.trailingAnchor constraintEqualToAnchor:confirmButton.leadingAnchor constant:-8],
        [titleLabel.centerYAnchor constraintEqualToAnchor:cancelButton.centerYAnchor],
        [separator.topAnchor constraintEqualToAnchor:cancelButton.bottomAnchor constant:4],
        [separator.leadingAnchor constraintEqualToAnchor:sheetView.leadingAnchor],
        [separator.trailingAnchor constraintEqualToAnchor:sheetView.trailingAnchor],
        [separator.heightAnchor constraintEqualToConstant:0.5],
        [self.pickerView.topAnchor constraintEqualToAnchor:separator.bottomAnchor],
        [self.pickerView.leadingAnchor constraintEqualToAnchor:sheetView.leadingAnchor],
        [self.pickerView.trailingAnchor constraintEqualToAnchor:sheetView.trailingAnchor],
        pickerBottomConstraint
    ]];
    if (self.options.count > 0) {
        [self.pickerView selectRow:self.selectedIndex inComponent:0 animated:NO];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.options.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.options[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedIndex = row;
}

- (void)cancelButtonClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)confirmButtonClick
{
    NSInteger selectedIndex = self.selectedIndex;
    RWPickerSelectionBlock selectionBlock = self.selectionBlock;
    [self dismissViewControllerAnimated:YES completion:^{
        if (selectionBlock) selectionBlock(selectedIndex);
    }];
}

@end

static NSString *RWLocalizedFunctionTitle(NSString *title)
{
    NSUInteger firstChineseIndex = NSNotFound;
    for (NSUInteger index = 0; index < title.length; index++) {
        unichar character = [title characterAtIndex:index];
        if (character >= 0x4E00 && character <= 0x9FFF) {
            firstChineseIndex = index;
            break;
        }
    }
    if (firstChineseIndex == NSNotFound) return title;
    BOOL isChinese = [[[NSLocale preferredLanguages] firstObject] hasPrefix:@"zh"];
    NSString *result = isChinese ? [title substringFromIndex:firstChineseIndex] : [title substringToIndex:firstChineseIndex];
    if (isChinese) {
        NSUInteger leftCount = 0;
        NSUInteger rightCount = 0;
        for (NSUInteger index = 0; index < result.length; index++) {
            unichar character = [result characterAtIndex:index];
            if (character == '(' || character == 0xFF08) leftCount++;
            if (character == ')' || character == 0xFF09) rightCount++;
        }
        while (rightCount > leftCount && result.length > 0) {
            unichar lastCharacter = [result characterAtIndex:result.length - 1];
            if (lastCharacter != ')' && lastCharacter != 0xFF09) break;
            result = [result substringToIndex:result.length - 1];
            rightCount--;
        }
    } else {
        result = [result stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -—("]];
    }
    return [result stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}


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
@property (nonatomic, strong) NSArray<NSNumber *> *visibleBaseIndexes;
@property (nonatomic, strong) NSArray<NSNumber *> *visibleHealthIndexes;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *functionDetailValues;


@property (nonatomic, strong) NSArray *groupTitleArr;


@end

@implementation NewHomeController

- (void)showPickerWithTitle:(NSString *)title
                    options:(NSArray<NSString *> *)options
              selectedIndex:(NSInteger)selectedIndex
                  selection:(RWPickerSelectionBlock)selection
{
    if (options.count == 0) return;
    RWPickerSheetController *picker = [[RWPickerSheetController alloc] initWithTitle:title
                                                                            options:options
                                                                      selectedIndex:selectedIndex
                                                                          selection:selection];
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)showMonitoringPickerWithTitle:(NSString *)title selection:(RWMonitoringSelectionBlock)selection
{
    NSArray<NSNumber *> *intervals = @[@0, @10, @30, @60];
    NSArray<NSString *> *options = @[RWChoiceText(@"Off", @"关闭"),
                                     RWChoiceText(@"Every 10 minutes", @"每10分钟"),
                                     RWChoiceText(@"Every 30 minutes", @"每30分钟"),
                                     RWChoiceText(@"Every 60 minutes", @"每60分钟")];
    [self showPickerWithTitle:title options:options selectedIndex:3 selection:^(NSInteger selectedIndex) {
        if (selection) selection(selectedIndex > 0, intervals[selectedIndex].integerValue);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"rw_tab_device", nil);
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = HomeColor_BackgroundColor;
    self.functionDetailValues = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view from its nib.
    self.groupTitleArr = @[@"Basic function commands-基础功能指令", @"Health data synchronization-健康数据同步(实时单次与全天检测)", @"Workout-多运动", @"Firmware upgrade-固件升级"];

    self.functionBaseList = @[@"SDK Version", @"Get Bluetooth MAC address(获取蓝牙Mac地址)", @"Set user information(设置用户信息)", @"Get firmware information(获取固件信息)", @"Get Battery(获取电量)", @"Get Video Switch(获取视频控制开关)", @"Set Video Switch(设置视频控制开关)", @"Get LED brightness level(获取LED亮屏强度)", @"Set LED brightness level(设置LED亮屏强度)", @"Get Wearing position(获取佩戴位置)", @"Set Wearing position(设置佩戴位置)",@"Activate and deactivate the camera(启动与关闭拍照)", @"Find Device(查找设备)", @"Shut down and restore to factory settings(关机,恢复出厂设置)", @"Alarm Clock - Get Alarm Clock(闹钟-获取闹钟)", @"Alarm clock - Set alarm(闹钟-设置闹钟)", @"Alarm Clock - Delete all alarms(闹钟-删除所有闹钟)", @"Get the number of vibrations-震动次数获取",@"Set the number of vibrations-震动次数设置", @"Get screen sleep mode-睡眠模式获取", @"Set screen sleep mode-睡眠模式设置", @"Get Message push notification switch-消息推送开关获取", @"Set Message push notification switch-消息推送开关设置", @"Check if receiving likes/comments is enabled-获取赞念是否打开", @"Set whether the likes feature is enabled.-设置赞念是否打开", @"Get heart rate alarm configuration-获取心率报警配置", @"Set heart rate alarm configuration-设置心率报警配置", @"Get blood oxygen alarm configuration-获取血氧报警配置", @"Set blood oxygen alarm configuration-设置血氧报警配置", @"Set Time Format-设置12/24小时时间显示格式", @"Get Alarm Vibration Duration-获取闹钟震动时长", @"Set Alarm Vibration Duration-设置闹钟震动时长", @"Get Vibration Interval-获取震动间隔时长", @"Set Vibration Interval-设置震动间隔时长"];

    self.functionHealthList = @[@"Real-time, single-instance health data monitoring-实时单次启动健康数据检测(心率,血氧,HRV, 压力, 血糖)", @"Get HeartRate Monitor(获取心率监听)", @"Set HeartRate Monitor(设置心率监听)",@"Get Blood oxygen Monitor(获取血氧监听)", @"Set Blood oxygen Monitor(设置血氧监听)",@"Get HRV Monitor(获取HRV监听)", @"Set HRV Monitor(设置HRV监听)",@"Get PPG Monitor(获取PPG监听)", @"Set PPG Monitor(设置PPG监听)",@"Get Stress Monitor(获取压力监听)", @"Set Stress Monitor(设置压力监听)",@"Get Blood Sugar Monitor(获取血糖监听)", @"Set Blood Sugar Monitor(设置血糖监听)", @"Sync all your health data(同步所有健康数据)", @"Get Blood Pressure Monitor(获取血压监听)", @"Set Blood Pressure Monitor(设置血压监听)", @"Get Temperature Monitor(获取定时体温监测)", @"Set Temperature Monitor(设置定时体温监测)", @"Get Muslim Time Display Mode(获取Muslim时间显示模式)", @"Set Muslim Time Display Mode(设置Muslim时间显示模式)", @"Get Muslim Count Reset Mode(获取Muslim计数清零方式)", @"Set Muslim Count Reset Mode(设置Muslim计数清零方式)", @"PPG Raw Data(PPG原始数据：启动、停止采集或获取历史)", @"HR Calibration(心率校正)", @"Get Fall Detect(获取跌落提醒开关)", @"Set Fall Detect(设置跌落提醒)", @"Get Count Reminder(获取计数提醒间隔)", @"Set Count Reminder(设置计数提醒间隔)"];

    self.functionWorkoutList = @[@"Workout-多运动"];

    self.functionOTAList = @[@"Firmware upgrade ota - 固件升级"];
    [self rebuildVisibleFunctionIndexes];



    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectStateChange:) name:BluetoothNotificationConnectStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectLoginOKChange:) name:BluetoothNotificationConnectLoginOKChange object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRingMeasureValueChange:) name:BluetoothNotificationHealthRingMeasureValueChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRingMeasureStateChange:) name:BluetoothNotificationHealthRingMeasureStateChange object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cameraTakePictureNotification) name:BluetoothNotificationCameraTakePicture object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(healthOverAlert:) name:BluetoothNotificationRingHealthOverAlert object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorRawDataNotification:) name:BluetoothNotificationSensorRawData object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorRawStopNotification:) name:BluetoothNotificationHealthRingSenorStopChange object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchEventNotification:) name:BluetoothNotificationTouchEvent object:nil];

    // 设备信息已改为 tableHeaderView 展示。移除 XIB 中的旧头部视图，
    // 避免旧的“表格位于标签下方”约束与新的表格铺满约束冲突。
    [self.infoDeviceNameLb removeFromSuperview];
    [self.infoDeviceStateLb removeFromSuperview];
    [self.infoDeviceMacLb removeFromSuperview];
    [self.infoDeviceBindBt removeFromSuperview];
    [self.functionTb mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.bottom.offset(0);
    }];
    [self setupDeviceHeaderView];
    [self updateDeviceHeaderView];
    [self setupLogShareButton];
}

#pragma mark - Log sharing

- (void)setupLogShareButton
{
    UIBarButtonItem *shareItem = nil;
    if (@available(iOS 13.0, *)) {
        UIImage *shareImage = [UIImage systemImageNamed:@"square.and.arrow.up"];
        shareItem = [[UIBarButtonItem alloc] initWithImage:shareImage
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(shareLogButtonClick:)];
    } else {
        shareItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"rw_logs", nil)
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(shareLogButtonClick:)];
    }
    shareItem.accessibilityLabel = NSLocalizedString(@"rw_share_logs", nil);
    self.navigationItem.rightBarButtonItem = shareItem;
}

- (void)shareLogButtonClick:(UIBarButtonItem *)sender
{
    [self shareLogArchiveFromSourceView:self.view];
}

- (void)shareLogArchiveFromSourceView:(UIView *)sourceView
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *logDirectoryPath = [documentsPath stringByAppendingPathComponent:@"DeviceLog"];
    if (![self directoryContainsFilesAtPath:logDirectoryPath]) {
        SHOWHUD(NSLocalizedString(@"rw_no_logs", nil));
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

    SHOWHUDNODISS(NSLocalizedString(@"rw_packaging_logs", nil));
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
                SHOWHUD(NSLocalizedString(@"rw_share_logs_failed", nil));
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
        // 断开后清除本次连接读取/设置的展示值，避免换设备后显示旧数据。
        [self.functionDetailValues removeAllObjects];
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
        [self.functionDetailValues removeAllObjects];
    }
    [self rebuildVisibleFunctionIndexes];
    [self.functionTb reloadData];
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

    UIView *ringIcon = [[UIView alloc] initWithFrame:CGRectMake(15, 48, 48, 48)];
    ringIcon.backgroundColor = RWColor(@"#EAF0FF");
    ringIcon.layer.cornerRadius = 24.0;
    UILabel *ringText = [[UILabel alloc] initWithFrame:ringIcon.bounds];
    ringText.text = @"◯";
    ringText.textAlignment = NSTextAlignmentCenter;
    ringText.textColor = RWColor(@"#3568D4");
    ringText.font = [UIFont boldSystemFontOfSize:24.0];
    [ringIcon addSubview:ringText];

    self.headerStatusLb = [self createHeaderLabelWithFrame:CGRectMake(15, 10, kScreenWidth - 30, 20) font:HomeFont_TitleFont];
    self.headerNameLb = [self createHeaderLabelWithFrame:CGRectMake(76, 38, kScreenWidth - 91, 18) font:HomeFont_ContentFont];
    self.headerMacLb = [self createHeaderLabelWithFrame:CGRectMake(76, 62, kScreenWidth - 91, 18) font:HomeFont_ContentFont];
    self.headerUuidLb = [self createHeaderLabelWithFrame:CGRectMake(76, 86, kScreenWidth - 91, 18) font:HomeFont_ContentFont];
    self.headerDeviceModelLb = [self createHeaderLabelWithFrame:CGRectMake(76, 110, kScreenWidth - 91, 18) font:HomeFont_ContentFont];

    CGFloat buttonTop = 138;
    CGFloat buttonSpace = 8;
    CGFloat buttonWidth = (kScreenWidth - 30 - buttonSpace) / 2.0;
    self.retryConnectBt = [self createHeaderButtonWithFrame:CGRectMake(15, buttonTop, buttonWidth, 34) title:NSLocalizedString(@"rw_reconnect", nil) action:@selector(retryConnectButtonClick)];
    self.searchDeviceBt = [self createHeaderButtonWithFrame:CGRectMake(15 + buttonWidth + buttonSpace, buttonTop, buttonWidth, 34) title:NSLocalizedString(@"rw_scan_device", nil) action:@selector(searchDeviceButtonClick)];

    [headerView addSubview:ringIcon];
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

    self.headerStatusLb.text = isConnected ? NSLocalizedString(@"rw_connected", nil) : (hasSavedDevice ? NSLocalizedString(@"rw_saved_disconnected", nil) : NSLocalizedString(@"rw_unbound_device", nil));
    self.headerNameLb.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"rw_name", nil), name.length ? name : @"-"];
    self.headerMacLb.text = [NSString stringWithFormat:@"MAC: %@", mac.length ? mac : @"-"];
    self.headerUuidLb.text = [NSString stringWithFormat:@"UDID: %@", uuid.length ? uuid : @"-"];
    self.headerDeviceModelLb.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"rw_device_model", nil), deviceModel.length ? deviceModel : @"-"];

    self.retryConnectBt.enabled = hasSavedDevice && !isConnected;
    [self.searchDeviceBt setTitle:hasSavedDevice ? NSLocalizedString(@"rw_unbind_device", nil) : NSLocalizedString(@"rw_scan_device", nil) forState:UIControlStateNormal];
}

- (void)retryConnectButtonClick
{
    if ([DHBleCentralManager isPoweredOff]) {
        SHOWHUD(NSLocalizedString(@"rw_bluetooth_off", nil))
        return;
    }
    if (![DHBleCentralManager currentBindedUUID].length) {
        SHOWHUD(NSLocalizedString(@"rw_no_saved_device", nil))
        return;
    }
    [DHBleCentralManager checkAndAutoReconnectDevice];
}

- (void)searchDeviceButtonClick
{
    if ([DHBleCentralManager currentBindedUUID].length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"rw_unbind_device", nil)
                                                                       message:NSLocalizedString(@"rw_unbind_message", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"rw_cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        __weak typeof(self) weakSelf = self;
        UIAlertAction *continueAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"rw_unbind", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[DHBluetoothManager shareInstance] clearSavedDeviceInfo];
            [DHBleCentralManager setBindedStatus:NO];
            [DHBleCentralManager disconnectDevice];
            [weakSelf updateDeviceHeaderView];
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
    vc.hidesBottomBarWhenPushed = YES;
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

- (void)sensorRawStopNotification:(NSNotification *)ntf
{
    NSLog(@"PPG raw collection stopped: %@", ntf.userInfo ?: @{});
    SHOWHUD(NSLocalizedString(@"rw_ppg_complete", nil))
}

- (void)showPpgRawDataActionsFromSourceView:(UIView *)sourceView
{
    DeviceFuncV2Model *functionMenu = [DHBluetoothManager shareInstance].deviceFuncV2Model;
    if (!functionMenu || !functionMenu.isSupportSensorRawPPG) {
        SHOWHUD(NSLocalizedString(@"rw_not_supported", nil))
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"rw_ppg_raw_data", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_start_ppg", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf startPpgRawData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_stop_ppg", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf stopPpgRawData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_get_ppg_history", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf getPpgRawHistory];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    UIPopoverPresentationController *popover = alert.popoverPresentationController;
    if (popover) {
        popover.sourceView = sourceView ?: self.view;
        popover.sourceRect = sourceView ? sourceView.bounds : self.view.bounds;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startPpgRawData
{
    // PPG固定使用sensorType=2，与Android和微信小程序Demo保持一致。
    [DHBleCommand ringControlSensorRaw:1 type:2 block:^(int code, id  _Nonnull data) {
        NSLog(@"Start PPG Raw code %d", code);
        NSString *message = code == 0 ? NSLocalizedString(@"rw_ppg_started", nil) : [NSString stringWithFormat:NSLocalizedString(@"rw_measurement_start_failed", nil), code];
        SHOWHUD(message)
    }];
}

- (void)stopPpgRawData
{
    [DHBleCommand ringControlSensorRaw:2 type:2 block:^(int code, id  _Nonnull data) {
        NSLog(@"Stop PPG Raw code %d", code);
        NSString *message = code == 0 ? NSLocalizedString(@"rw_stop_command_sent", nil) : [NSString stringWithFormat:NSLocalizedString(@"rw_measurement_stop_failed", nil), code];
        SHOWHUD(message)
    }];
}

- (void)getPpgRawHistory
{
    SHOWHUDNODISS(NSLocalizedString(@"rw_reading_ppg_history", nil))
    __block NSInteger groupCount = 0;
    __block NSInteger sampleCount = 0;
    [DHBleCommand ringGetHistorySensorRaw:^(int code, id  _Nonnull data) {
        HUDDISS
        if (code == 0) {
            NSString *message = groupCount > 0
                ? [NSString stringWithFormat:NSLocalizedString(@"rw_ppg_history_result", nil), (long)groupCount, (long)sampleCount]
                : NSLocalizedString(@"rw_ppg_history_empty", nil);
            SHOWHUD(message)
        } else {
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"rw_read_failed", nil), code];
            SHOWHUD(message)
        }
        NSLog(@"PPG History Raw sync finished code=%d groups=%ld samples=%ld", code, (long)groupCount, (long)sampleCount);
    } dataBlock:^(int code, int progress, id  _Nonnull data) {
        if (code != 0 || ![data isKindOfClass:[NSArray class]]) return;
        groupCount = 0;
        sampleCount = 0;
        for (NSDictionary *info in (NSArray *)data) {
            if ([info[@"sensorType"] integerValue] != 1) continue;
            groupCount += 1;
            NSArray *ppgData = info[@"ppgData"];
            sampleCount += [ppgData isKindOfClass:[NSArray class]] ? ppgData.count : [info[@"count"] integerValue];
        }
    }];
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
- (void)rebuildVisibleFunctionIndexes
{
    DeviceFuncV2Model *menu = [DHBluetoothManager shareInstance].deviceFuncV2Model;
    NSMutableArray<NSNumber *> *base = [NSMutableArray arrayWithArray:@[@0, @1, @2, @3, @4, @29]];
    NSMutableArray<NSNumber *> *health = [NSMutableArray array];
    if (menu) {
        void (^addPair)(NSMutableArray<NSNumber *> *, BOOL, NSInteger, NSInteger) = ^(NSMutableArray<NSNumber *> *target, BOOL supported, NSInteger first, NSInteger second) {
            if (supported) {
                [target addObject:@(first)];
                [target addObject:@(second)];
            }
        };
        addPair(base, menu.isVideoHid, 5, 6);
        addPair(base, menu.isLEDLight, 7, 8);
        addPair(base, menu.isWearDir, 9, 10);
        if (menu.isTakePhoto) [base addObject:@11];
        if (menu.isFindDevice) [base addObject:@12];
        if (menu.isPowerOff || menu.isResetFactory) [base addObject:@13];
        if (menu.isAlarm) [base addObjectsFromArray:@[@14, @15, @16]];
        addPair(base, menu.isSupportMotoVibrationLevel, 17, 18);
        addPair(base, menu.isBackLightSleepMode, 19, 20);
        addPair(base, menu.isPushMsg, 21, 22);
        addPair(base, menu.isSupportMuslimCountSwitch, 23, 24);
        addPair(base, menu.isSupportHrSp02Alert, 25, 26);
        addPair(base, menu.isSupportSp02Alert, 27, 28);
        addPair(base, menu.isSupportAlarmVibrationDuration, 30, 31);
        addPair(base, menu.isSupportVibrationInterval, 32, 33);

        // 实时单次检测统一放在首页的健康详情页，设备设置页不重复显示。
        addPair(health, menu.isDataTypeHeart, 1, 2);
        addPair(health, menu.isDataTypeSPO2, 3, 4);
        addPair(health, menu.isDataTypeHRV, 5, 6);
        addPair(health, menu.isSupportPPGMonitoring, 7, 8);
        addPair(health, menu.isDataTypeStress, 9, 10);
        addPair(health, menu.isDataTypeBloodSugar, 11, 12);
        // 全量健康数据同步统一由首页下拉刷新触发，设备设置页不重复显示。
        addPair(health, menu.isDataTypeBloodPressure, 14, 15);
        addPair(health, menu.isSupportTemperatureMonitoring, 16, 17);
        if (menu.isSupportMuslimTimeDisplayMode) [health addObjectsFromArray:@[@18, @19, @20, @21]];
        if (menu.isSupportSensorRawPPG) [health addObject:@22];
        if (menu.isDataTypeHeart) [health addObject:@23];
        addPair(health, menu.isSupportFallDetect, 24, 25);
        addPair(health, menu.isSupportCountReminder, 26, 27);
    }
    [base sortUsingSelector:@selector(compare:)];
    self.visibleBaseIndexes = base;
    self.visibleHealthIndexes = health;
}

- (NSString *)detailTextForSection:(NSInteger)section sourceRow:(NSInteger)row
{
    NSString *storedValue = self.functionDetailValues[[NSString stringWithFormat:@"%zd-%zd", section, row]];
    if (storedValue.length > 0) return storedValue;
    NSString *read = RWChoiceText(@"Read", @"读取");
    NSString *select = RWChoiceText(@"Select", @"选择");
    NSString *run = RWChoiceText(@"Run", @"执行");
    if (section == 0) {
        switch (row) {
            case 0: return [DHBleCommand getSDKVersion];
            case 1: case 3: case 4: case 5: case 7: case 9: case 14:
            case 17: case 19: case 21: case 23: case 25: case 27: case 30: case 32:
                return read;
            case 6: return RWChoiceText(@"Off / Video", @"关闭 / 视频");
            case 8: return @"0–3";
            case 10: return RWChoiceText(@"Left / Right", @"左手 / 右手");
            case 11: return RWChoiceText(@"Enter / Exit", @"进入 / 退出");
            case 13: return RWChoiceText(@"Power", @"电源操作");
            case 15: return RWChoiceText(@"Preset", @"预设");
            case 16: return RWChoiceText(@"Delete", @"删除");
            case 18: case 31: return @"0–6";
            case 20: return RWChoiceText(@"Time range", @"时间段");
            case 22: case 24: return RWChoiceText(@"On / Off", @"开 / 关");
            case 26: return @"100–200 bpm";
            case 28: return @"85–95%";
            case 29: return @"12 / 24h";
            case 33: return @"100–1000 ms";
            default: return run;
        }
    }
    if (section == 1) {
        switch (row) {
            case 1: case 3: case 5: case 7: case 9: case 11: case 14: case 16:
            case 18: case 20: case 24: case 26:
                return read;
            case 2: case 4: case 6: case 8: case 10: case 12: case 15: case 17:
                return RWChoiceText(@"0 / 10 / 30 / 60 min", @"关 / 10 / 30 / 60分");
            case 19: case 21: return select;
            case 22: return RWChoiceText(@"Start / Stop / History", @"启动 / 停止 / 历史");
            case 23: return RWChoiceText(@"Calibrate", @"校正");
            case 25: return RWChoiceText(@"On / Off", @"开 / 关");
            case 27: return @"0 / 30 / 60 / 90 / 120 min";
            default: return run;
        }
    }
    if (section == 3) return RWChoiceText(@"Select file", @"选择文件");
    return select;
}

- (void)updateDetailText:(NSString *)text section:(NSInteger)section sourceRow:(NSInteger)sourceRow
{
    if (text.length == 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.functionDetailValues[[NSString stringWithFormat:@"%zd-%zd", section, sourceRow]] = text;
        NSArray<NSNumber *> *indexes = section == 0 ? self.visibleBaseIndexes : self.visibleHealthIndexes;
        NSUInteger visibleRow = [indexes indexOfObject:@(sourceRow)];
        if (visibleRow != NSNotFound) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:visibleRow inSection:section];
            [self.functionTb reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (NSIndexPath *)sourceIndexPathForVisibleIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row < self.visibleBaseIndexes.count) {
        return [NSIndexPath indexPathForRow:self.visibleBaseIndexes[indexPath.row].integerValue inSection:indexPath.section];
    }
    if (indexPath.section == 1 && indexPath.row < self.visibleHealthIndexes.count) {
        return [NSIndexPath indexPathForRow:self.visibleHealthIndexes[indexPath.row].integerValue inSection:indexPath.section];
    }
    return indexPath;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groupTitleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? 60 : 0.01;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self tableView:tableView numberOfRowsInSection:section] > 0 ? RWLocalizedFunctionTitle(self.groupTitleArr[section]) : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0){
        return self.visibleBaseIndexes.count;
    }
    else if (section == 1){
        return self.visibleHealthIndexes.count;
    }
    else if (section == 2){
        // 多运动仅保留在首页，设备设置页不重复显示。
        return 0;
    }
    else{
        return  self.functionOTAList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"RWDeviceFunctionCell";
    UITableViewCell *tCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!tCell){
        tCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    tCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    tCell.textLabel.font = [UIFont systemFontOfSize:14.0];
    tCell.textLabel.numberOfLines = 1;
    tCell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    tCell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
    if (@available(iOS 13.0, *)) {
        tCell.detailTextLabel.textColor = UIColor.secondaryLabelColor;
    } else {
        tCell.detailTextLabel.textColor = UIColor.grayColor;
    }
    tCell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    tCell.detailTextLabel.minimumScaleFactor = 0.75;

    if (indexPath.section == 0){
        NSInteger sourceRow = self.visibleBaseIndexes[indexPath.row].integerValue;
        tCell.textLabel.text = RWLocalizedFunctionTitle([self.functionBaseList objectAtIndex:sourceRow]);
        tCell.detailTextLabel.text = [self detailTextForSection:0 sourceRow:sourceRow];
    }
    else if (indexPath.section == 1){
        NSInteger sourceRow = self.visibleHealthIndexes[indexPath.row].integerValue;
        tCell.textLabel.text = RWLocalizedFunctionTitle([self.functionHealthList objectAtIndex:sourceRow]);
        tCell.detailTextLabel.text = [self detailTextForSection:1 sourceRow:sourceRow];
    }
    else if (indexPath.section == 2){
        tCell.textLabel.text = RWLocalizedFunctionTitle([self.functionWorkoutList objectAtIndex:indexPath.row]);
        tCell.detailTextLabel.text = nil;
    }
    else{
        tCell.textLabel.text = RWLocalizedFunctionTitle([self.functionOTAList objectAtIndex:indexPath.row]);
        tCell.detailTextLabel.text = [self detailTextForSection:3 sourceRow:indexPath.row];
    }
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSIndexPath *visibleIndexPath = indexPath;
    indexPath = [self sourceIndexPathForVisibleIndexPath:indexPath];

    if (indexPath.section == 0){
        if (indexPath.row == 0){ //sdk version
            NSLog(@"%@", [DHBleCommand getSDKVersion]);
        }
        else if (indexPath.row == 1){ //mac
            [DHBleCommand ringGetMacAddress:^(int code, id  _Nonnull data) {
                DHDeviceInfoModel *tDeviceInfoData = data;
                NSLog(@"mac: %@", tDeviceInfoData.macAddr);
                if (code == 0) [self updateDetailText:tDeviceInfoData.macAddr section:0 sourceRow:1];
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
                    [self updateDetailText:RWChoiceText(@"Demo profile", @"示例资料") section:0 sourceRow:2];
                }
            }];
        }
        else if (indexPath.row == 3){ //Get firmware information
            [DHBleCommand getFirmwareVersion:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSLog(@"getFirmwareVersion OK");
                    DHFirmwareVersionModel *model = data;
                    NSLog(@"型号 %@ 固件版本 %@ UI版本 %@", model.deviceModel, model.firmwareVersion, model.uiVersion);
                    [self updateDetailText:model.firmwareVersion section:0 sourceRow:3];
                }
            }];
        }
        else if (indexPath.row == 4){ //Get Battery
            [DHBleCommand getBattery:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHBatteryInfoModel *model = data;
                    NSLog(@"getBattery OK 电量值 %zd", model.battery);
                    [self updateDetailText:[NSString stringWithFormat:@"%zd%%", model.battery] section:0 sourceRow:4];
                }
            }];
        }
        else if (indexPath.row == 5){// 获取视频控制开关
            [DHBleCommand getVideoHid:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHVideoHidSetModel *model = data;
                    NSLog(@"getVideoHid OK 开关 %d", model.isOpen);
                    NSString *value = model.isOpen ? RWChoiceText(@"Video", @"视频") : RWChoiceText(@"Off", @"关闭");
                    [self updateDetailText:value section:0 sourceRow:5];
                }
            }];
        }
        else if (indexPath.row == 6){ //设置视频控制开关
            // 当前 Demo 内置 framework 的该字段仍为 BOOL，先只提供可可靠发送的开关值。
            NSArray *options = @[RWChoiceText(@"Off", @"关闭"), RWChoiceText(@"Video", @"视频")];
            [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[6]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                DHVideoHidSetModel *model = [[DHVideoHidSetModel alloc] init];
                model.isOpen = selectedIndex == 1;
                [DHBleCommand setVideoHid:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setVideoHid mode=%zd code=%d", selectedIndex, code);
                    if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:6];
                }];
            }];
        }
        else if (indexPath.row == 7){// 获取LED高屏强度
            [DHBleCommand getRingLEDLight:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHLedLightSetModel *model = data;
                    NSLog(@"getRingLEDLight OK 开关 %d", model.isOpen);
                    NSString *value = model.isOpen ? [NSString stringWithFormat:RWChoiceText(@"Level %zd", @"%zd级"), model.lightLevel] : RWChoiceText(@"Off", @"关闭");
                    [self updateDetailText:value section:0 sourceRow:7];
                }
            }];
        }
        else if (indexPath.row == 8){ //设置LED高屏强度
            NSArray *options = @[RWChoiceText(@"Off", @"关闭"),
                                 RWChoiceText(@"Level 1 · Dim", @"1级 · 微光"),
                                 RWChoiceText(@"Level 2 · Soft", @"2级 · 柔光"),
                                 RWChoiceText(@"Level 3 · Bright", @"3级 · 强光")];
            [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[8]) options:options selectedIndex:3 selection:^(NSInteger selectedIndex) {
                DHLedLightSetModel *model = [[DHLedLightSetModel alloc] init];
                model.isOpen = selectedIndex > 0;
                model.lightLevel = MAX(selectedIndex, 1);
                [DHBleCommand setRingLEDLight:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setRingLEDLight level=%zd code=%d", selectedIndex, code);
                    if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:8];
                }];
            }];
        }
        else if (indexPath.row == 9){// 获取佩戴位置
            [DHBleCommand getRingWearHand:^(int code, id  _Nonnull data) {
                if (code == 0){
                    NSInteger tWearHand = [data intValue];
                    NSLog(@"getRingWearHand OK 佩戴位置 %zd", tWearHand);
                    [self updateDetailText:(tWearHand == 0 ? RWChoiceText(@"Left", @"左手") : RWChoiceText(@"Right", @"右手")) section:0 sourceRow:9];
                }
            }];
        }
        else if (indexPath.row == 10){ //设置佩戴位置
            NSArray *options = @[RWChoiceText(@"Left hand", @"左手"), RWChoiceText(@"Right hand", @"右手")];
            [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[10]) options:options selectedIndex:0 selection:^(NSInteger selectedIndex) {
                [DHBleCommand setRingWearHand:(uint8_t)selectedIndex block:^(int code, id  _Nonnull data) {
                    NSLog(@"setRingWearHand value=%zd code=%d", selectedIndex, code);
                    if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:10];
                }];
            }];
        }
        else if (indexPath.row == 11){ // 启动与关闭拍照

            //APP进相机界面启动 1为控制设备进对应界面, 0为控制设备退出
            //BluetoothNotificationCameraTakePicture 设备发出拍照通知,进行拍照
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isTakePhoto){

                NSArray *options = @[RWChoiceText(@"Exit camera mode", @"退出拍照模式"), RWChoiceText(@"Enter camera mode", @"进入拍照模式")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[11]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand controlCamera:selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"controlCamera mode=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:11];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 12){ // 查找设备
            [DHBleCommand controlFindDeviceBegin:^(int code, id  _Nonnull data) {

            }];
        }
        else if (indexPath.row == 13){ // 关机,恢复出厂设置
            // 1关机 2 恢复出厂
            NSArray *options = @[RWChoiceText(@"Shut down", @"设备关机"), RWChoiceText(@"Restore factory settings", @"恢复出厂设置")];
            [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[13]) options:options selectedIndex:0 selection:^(NSInteger selectedIndex) {
                [DHBleCommand controlDevice:selectedIndex + 1 block:^(int code, id  _Nonnull data) {
                    NSLog(@"controlDevice type=%zd code=%d", selectedIndex + 1, code);
                }];
            }];
        }
        else if (indexPath.row == 14){ //Alarm-Get Alarms
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isAlarm){
                [DHBleCommand getAlarms:^(int code, id  _Nonnull data) {
                    NSArray *tAlarmList = data;
                    NSLog(@"getAlarms %zd", tAlarmList.count);
                    if (code == 0) [self updateDetailText:[NSString stringWithFormat:RWChoiceText(@"%zd alarms", @"%zd个闹钟"), tAlarmList.count] section:0 sourceRow:14];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
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
                NSArray *options = @[RWChoiceText(@"07:00 · Saturday", @"07:00 · 周六"),
                                     RWChoiceText(@"08:00 · Once", @"08:00 · 单次"),
                                     RWChoiceText(@"Both demo alarms", @"两个示例闹钟")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[15]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    NSArray *alarms = selectedIndex == 0 ? @[tAlarm1] : (selectedIndex == 1 ? @[tAlarm2] : @[tAlarm1, tAlarm2]);
                    [DHBleCommand setAlarms:alarms block:^(int code, id  _Nonnull data) {
                        NSLog(@"setAlarms preset=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:15];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 16){ //Alarm-delete all Alarms
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isAlarm){
                [DHBleCommand setAlarms:@[] block:^(int code, id  _Nonnull data) {
                    if (code == 0) [self updateDetailText:RWChoiceText(@"0 alarms", @"0个闹钟") section:0 sourceRow:16];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 17){ //震动次数获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMotoVibrationLevel){
                [DHBleCommand getRingMotorLevel:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHVibrationLevelModel *tVibrationModel = data;
                        NSLog(@"getRingMotorLevel Level %d num %d", tVibrationModel.vibrationLevel, tVibrationModel.vibrationNumber);
                        NSString *value = [NSString stringWithFormat:RWChoiceText(@"Level %zd · %zd times", @"%zd级 · %zd次"), tVibrationModel.vibrationLevel, tVibrationModel.vibrationNumber];
                        [self updateDetailText:value section:0 sourceRow:17];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 18){ //震动次数设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMotoVibrationLevel){
                NSMutableArray *options = [NSMutableArray array];
                for (NSInteger count = 0; count <= 6; count++) {
                    [options addObject:[NSString stringWithFormat:RWChoiceText(@"%zd times", @"%zd次"), count]];
                }
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[18]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    NSInteger motorLevel = selectedIndex == 0 ? 0 : 1;
                    [DHBleCommand setRingMotorLevel:motorLevel motorNum:selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setRingMotorLevel count=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:18];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 19){ //睡眠模式获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isBackLightSleepMode){
                [DHBleCommand getDisplaySleepMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHBrightTimeSetModel *tModel = data;
                        NSLog(@"getDisplaySleepMode sleepOpen %d sleepStartHour %d sleepStartMin %d", tModel.sleepOpen, tModel.sleepStartHour, tModel.sleepEndMin);
                        NSString *value = tModel.sleepOpen ? [NSString stringWithFormat:@"%02zd:%02zd–%02zd:%02zd", tModel.sleepStartHour, tModel.sleepStartMin, tModel.sleepEndHour, tModel.sleepEndMin] : RWChoiceText(@"Off", @"关闭");
                        [self updateDetailText:value section:0 sourceRow:19];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 20){ //睡眠模式设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isBackLightSleepMode){
                NSArray *options = @[RWChoiceText(@"Off", @"关闭"), @"20:00–06:00", @"22:00–08:00", @"23:00–07:00"];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[20]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    DHBrightTimeSetModel *model = [[DHBrightTimeSetModel alloc] init];
                    model.sleepOpen = selectedIndex > 0;
                    NSArray<NSArray<NSNumber *> *> *ranges = @[@[@0, @0], @[@20, @6], @[@22, @8], @[@23, @7]];
                    model.sleepStartHour = ranges[selectedIndex][0].integerValue;
                    model.sleepStartMin = 0;
                    model.sleepEndHour = ranges[selectedIndex][1].integerValue;
                    model.sleepEndMin = 0;
                    [DHBleCommand setDisplaySleepMode:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setDisplaySleepMode option=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:20];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 21){ //消息推送开关获取
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isPushMsg){
                [DHBleCommand ringGetAncs:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHAncsSetModel *ancsModel = data;
                        [self updateDetailText:(ancsModel.isSMS ? RWChoiceText(@"SMS On", @"短信开启") : RWChoiceText(@"SMS Off", @"短信关闭")) section:0 sourceRow:21];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 22){ //消息推送开关设置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isPushMsg){
                NSArray *options = @[RWChoiceText(@"SMS Off", @"短信提醒关闭"), RWChoiceText(@"SMS On", @"短信提醒开启")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[22]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                    DHAncsSetModel *model = [[DHAncsSetModel alloc] init];
                    model.isSMS = selectedIndex == 1;
                    [DHBleCommand ringSetAncs:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"ringSetAncs SMS=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:22];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 23){ //获取赞念是否打开
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimCountSwitch){
                [DHBleCommand getMuslimCountSwitch:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        Boolean tOpen = [data boolValue];
                        NSLog(@"getMuslimCountSwitch tOpen %d", tOpen);
                        [self updateDetailText:(tOpen ? RWChoiceText(@"On", @"开启") : RWChoiceText(@"Off", @"关闭")) section:0 sourceRow:23];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 24){ //设置赞念是否打开
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimCountSwitch){
                NSArray *options = @[RWChoiceText(@"Off", @"关闭"), RWChoiceText(@"On", @"开启")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[24]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand setMuslimCountSwitch:selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setMuslimCountSwitch value=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:24];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 25){ //获取心率报警配置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                [DHBleCommand getHRAlert:^(int code, id  _Nonnull data) {
                    if (code == 0){
                    DHHRAlertModel *model = data;
                    NSLog(@"getHRAlert %d %zd", model.isOpen, model.overValue);
                    NSString *value = model.isOpen ? [NSString stringWithFormat:@"> %zd bpm", model.overValue] : RWChoiceText(@"Off", @"关闭");
                    [self updateDetailText:value section:0 sourceRow:25];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 26){ //设置心率报警配置
            // BluetoothNotificationRingHealthOverAlert
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportHrSp02Alert){
                NSMutableArray *options = [NSMutableArray arrayWithObject:RWChoiceText(@"Off", @"关闭")];
                for (NSInteger value = 100; value <= 200; value += 10) {
                    [options addObject:[NSString stringWithFormat:RWChoiceText(@"Above %zd bpm", @"高于 %zd 次/分"), value]];
                }
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[26]) options:options selectedIndex:7 selection:^(NSInteger selectedIndex) {
                    DHHRAlertModel *model = [[DHHRAlertModel alloc] init];
                    model.isOpen = selectedIndex > 0;
                    model.overValue = selectedIndex > 0 ? 100 + (selectedIndex - 1) * 10 : 0xff;
                    model.underValue = 0xff;
                    [DHBleCommand setHRAlert:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setHRAlert value=%zd code=%d", model.overValue, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:26];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 27){ //获取血氧报警配置
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportSp02Alert){
                [DHBleCommand getSP02Alert:^(int code, id  _Nonnull data) {
                    if (code == 0){
                    DHHRAlertModel *model = data;
                    NSLog(@"getSP02Alert %d %zd", model.isOpen, model.overValue);
                    NSString *value = model.isOpen ? [NSString stringWithFormat:@"< %zd%%", model.overValue] : RWChoiceText(@"Off", @"关闭");
                    [self updateDetailText:value section:0 sourceRow:27];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 28){ //设置血氧报警配置
            // BluetoothNotificationRingHealthOverAlert
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportSp02Alert){
                NSMutableArray *options = [NSMutableArray arrayWithObject:RWChoiceText(@"Off", @"关闭")];
                for (NSInteger value = 85; value <= 95; value++) {
                    [options addObject:[NSString stringWithFormat:RWChoiceText(@"Below %zd%%", @"低于 %zd%%"), value]];
                }
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[28]) options:options selectedIndex:10 selection:^(NSInteger selectedIndex) {
                    DHHRAlertModel *model = [[DHHRAlertModel alloc] init];
                    model.isOpen = selectedIndex > 0;
                    model.overValue = selectedIndex > 0 ? 85 + selectedIndex - 1 : 0xff;
                    [DHBleCommand setSP02Alert:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setSP02Alert value=%zd code=%d", model.overValue, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:28];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 29){
            NSArray *options = @[RWChoiceText(@"24-hour", @"24小时制"), RWChoiceText(@"12-hour", @"12小时制")];
            [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[29]) options:options selectedIndex:0 selection:^(NSInteger selectedIndex) {
                [DHBleCommand ringSetTimeformat:(UInt8)selectedIndex block:^(int code, id  _Nonnull data) {
                    NSLog(@"ringSetTimeformat value=%zd code=%d", selectedIndex, code);
                    if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:29];
                }];
            }];
        }
        else if (indexPath.row == 30){ //获取闹钟震动时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportAlarmVibrationDuration){
                [DHBleCommand getAlarmVibrationDuration:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getAlarmVibrationDuration count %@", data);
                        [self updateDetailText:[NSString stringWithFormat:RWChoiceText(@"%@ times", @"%@次"), data] section:0 sourceRow:30];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 31){ //设置闹钟震动时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportAlarmVibrationDuration){
                NSMutableArray *options = [NSMutableArray array];
                for (NSInteger count = 0; count <= 6; count++) {
                    [options addObject:[NSString stringWithFormat:RWChoiceText(@"%zd times", @"%zd次"), count]];
                }
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[31]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand setAlarmVibrationDuration:(UInt8)selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setAlarmVibrationDuration count=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:31];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 32){ //获取震动间隔时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportVibrationInterval){
                [DHBleCommand getVibrationInterval:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getVibrationInterval %@ms", data);
                        [self updateDetailText:[NSString stringWithFormat:@"%@ ms", data] section:0 sourceRow:32];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 33){ //设置震动间隔时长
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportVibrationInterval){
                NSMutableArray *options = [NSMutableArray array];
                for (NSInteger interval = 100; interval <= 1000; interval += 100) {
                    [options addObject:[NSString stringWithFormat:@"%zd ms", interval]];
                }
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionBaseList[33]) options:options selectedIndex:4 selection:^(NSInteger selectedIndex) {
                    NSInteger interval = (selectedIndex + 1) * 100;
                    [DHBleCommand setVibrationInterval:(UInt16)interval block:^(int code, id  _Nonnull data) {
                        NSLog(@"setVibrationInterval value=%zd code=%d", interval, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:0 sourceRow:33];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
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
                    [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:1];
                }
            }];
        }
        else if (indexPath.row == 2){ //设置心率监听
            [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[2]) selection:^(BOOL enabled, NSInteger interval) {
                DHHeartRateModeSetModel *model = [[DHHeartRateModeSetModel alloc] init];
                model.isOpen = enabled;
                model.startHour = 0;
                model.startMinute = 0;
                model.endHour = 23;
                model.endMinute = 59;
                model.interval = interval;
                [DHBleCommand setHeartRateMode:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setHeartRateMode open=%d interval=%zd code=%d", enabled, interval, code);
                    if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:2];
                }];
            }];
        }
        else if (indexPath.row == 3){// 获取血氧监听
            [DHBleCommand getBoMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHBoModeSetModel *model = data;
                    NSLog(@"getBoMode OK 开关 %d 检测周期 %zd", model.isOpen, model.interval);
                    [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:3];
                }
            }];
        }
        else if (indexPath.row == 4){ //设置血氧监听
            [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[4]) selection:^(BOOL enabled, NSInteger interval) {
                DHBoModeSetModel *model = [[DHBoModeSetModel alloc] init];
                model.isOpen = enabled;
                model.startHour = 0;
                model.startMinute = 0;
                model.endHour = 23;
                model.endMinute = 59;
                model.interval = interval;
                [DHBleCommand setBoMode:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setBoMode open=%d interval=%zd code=%d", enabled, interval, code);
                    if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:4];
                }];
            }];
        }
        else if (indexPath.row == 5){// 获取HRV监听
            [DHBleCommand getHrvMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHHrvModeSetModel *model = data;
                    NSLog(@"getBoMode OK 开关 %d", model.isOpen);
                    [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:5];
                }
            }];
        }
        else if (indexPath.row == 6){ //设置HRV监听
            [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[6]) selection:^(BOOL enabled, NSInteger interval) {
                DHHrvModeSetModel *model = [[DHHrvModeSetModel alloc] init];
                model.isOpen = enabled;
                model.startHour = 0;
                model.startMinute = 0;
                model.endHour = 23;
                model.endMinute = 59;
                model.interval = interval;
                [DHBleCommand setHrvMode:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setHrvMode open=%d interval=%zd code=%d", enabled, interval, code);
                    if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:6];
                }];
            }];
        }
        else if (indexPath.row == 7){// 获取PPG监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportPPGMonitoring){
                [DHBleCommand getPPGMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHrvModeSetModel *model = data;
                        NSLog(@"getPPGMode OK 开关 %d", model.isOpen);
                        [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:7];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 8){ //设置PPG监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportPPGMonitoring){
                [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[8]) selection:^(BOOL enabled, NSInteger interval) {
                    DHHrvModeSetModel *model = [[DHHrvModeSetModel alloc] init];
                    model.isOpen = enabled;
                    model.startHour = 0;
                    model.startMinute = 0;
                    model.endHour = 23;
                    model.endMinute = 59;
                    model.interval = interval;
                    [DHBleCommand setPPGMode:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setPPGMode open=%d interval=%zd code=%d", enabled, interval, code);
                        if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:8];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 9){// 获取Stress监听
            [DHBleCommand getStressMode:^(int code, id  _Nonnull data) {
                if (code == 0){
                    DHStressModeSetModel *model = data;
                    NSLog(@"getStressMode OK 开关 %d", model.isOpen);
                    [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:9];
                }
            }];
        }
        else if (indexPath.row == 10){ //设置HRV监听
            [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[10]) selection:^(BOOL enabled, NSInteger interval) {
                DHStressModeSetModel *model = [[DHStressModeSetModel alloc] init];
                model.isOpen = enabled;
                model.startHour = 0;
                model.startMinute = 0;
                model.endHour = 23;
                model.endMinute = 59;
                model.interval = interval;
                [DHBleCommand setStressMode:model block:^(int code, id  _Nonnull data) {
                    NSLog(@"setStressMode open=%d interval=%zd code=%d", enabled, interval, code);
                    if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:10];
                }];
            }];
        }
        else if (indexPath.row == 11){// 获取血糖监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodSugar){

                [DHBleCommand getBloodSugarMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHBloodSugarModeSetModel *model = data;
                        NSLog(@"getBloodSugarMode OK 开关 %d", model.isOpen);
                        [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:11];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 12){ //设置血糖监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodSugar){
                [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[12]) selection:^(BOOL enabled, NSInteger interval) {
                    DHBloodSugarModeSetModel *model = [[DHBloodSugarModeSetModel alloc] init];
                    model.isOpen = enabled;
                    model.startHour = 0;
                    model.startMinute = 0;
                    model.endHour = 23;
                    model.endMinute = 59;
                    model.interval = interval;
                    [DHBleCommand setBloodSugarMode:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setBloodSugarMode open=%d interval=%zd code=%d", enabled, interval, code);
                        if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:12];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
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
                        [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:14];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 15){ //设置血压监听
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isDataTypeBloodPressure){
                [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[15]) selection:^(BOOL enabled, NSInteger interval) {
                    DHBpModeSetModel *model = [[DHBpModeSetModel alloc] init];
                    model.isOpen = enabled;
                    model.startHour = 0;
                    model.startMinute = 0;
                    model.endHour = 23;
                    model.endMinute = 59;
                    model.interval = interval;
                    [DHBleCommand setBpMode:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setBpMode open=%d interval=%zd code=%d", enabled, interval, code);
                        if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:15];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 16){ //获取定时体温监测
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportTemperatureMonitoring){
                [DHBleCommand getTimedBodyTemperature:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        DHHeartRateModeSetModel *model = data;
                        NSLog(@"getTimedBodyTemperature OK 开关 %d 检测周期 %zd", model.isOpen, model.interval);
                        [self updateDetailText:RWMonitoringDetail(model.isOpen, model.interval) section:1 sourceRow:16];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 17){ //设置定时体温监测
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportTemperatureMonitoring){
                [self showMonitoringPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[17]) selection:^(BOOL enabled, NSInteger interval) {
                    DHHeartRateModeSetModel *model = [[DHHeartRateModeSetModel alloc] init];
                    model.isOpen = enabled;
                    model.startHour = 0;
                    model.startMinute = 0;
                    model.endHour = 23;
                    model.endMinute = 59;
                    model.interval = interval;
                    [DHBleCommand setTimedBodyTemperature:model block:^(int code, id  _Nonnull data) {
                        NSLog(@"setTimedBodyTemperature open=%d interval=%zd code=%d", enabled, interval, code);
                        if (code == 0) [self updateDetailText:RWMonitoringDetail(enabled, interval) section:1 sourceRow:17];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 18){ //获取Muslim时间显示模式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand getMuslimTimeDisplayMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSInteger tMode = [data integerValue];
                        NSLog(@"getMuslimTimeDisplayMode OK mode %zd", tMode);
                        [self updateDetailText:[NSString stringWithFormat:RWChoiceText(@"Mode %zd", @"模式%zd"), tMode] section:1 sourceRow:18];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 19){ //设置Muslim时间显示模式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                NSArray *options = @[RWChoiceText(@"Mode 0", @"模式0"), RWChoiceText(@"Mode 1", @"模式1"), RWChoiceText(@"Mode 2", @"模式2")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[19]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand setMuslimTimeDisplayMode:selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setMuslimTimeDisplayMode value=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:1 sourceRow:19];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 20){ //获取Muslim计数清零方式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                [DHBleCommand getMuslimCountResetMode:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSInteger tMode = [data integerValue];
                        NSLog(@"getMuslimCountResetMode OK mode %zd", tMode);
                        [self updateDetailText:[NSString stringWithFormat:RWChoiceText(@"Mode %zd", @"模式%zd"), tMode] section:1 sourceRow:20];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 21){ //设置Muslim计数清零方式
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportMuslimTimeDisplayMode){
                NSArray *options = @[RWChoiceText(@"Mode 0", @"模式0"), RWChoiceText(@"Mode 1", @"模式1")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[21]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand setMuslimCountResetMode:selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setMuslimCountResetMode value=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:1 sourceRow:21];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 22){ //PPG原始数据
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:visibleIndexPath];
            [self showPpgRawDataActionsFromSourceView:cell ?: tableView];
        }
        else if (indexPath.row == 23){ //心率校正
            [DHBleCommand startFactoryTest:0x15 block:^(int code, id  _Nonnull data) {
                NSLog(@"startFactoryTest HR Calibration code %d", code);
            }];
        }
        else if (indexPath.row == 24){ //获取跌落提醒开关
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportFallDetect){
                [DHBleCommand getFallDetect:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"getFallDetect OK: %@", data);
                        [self updateDetailText:([data boolValue] ? RWChoiceText(@"On", @"开启") : RWChoiceText(@"Off", @"关闭")) section:1 sourceRow:24];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 25){ //设置跌落提醒开关
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportFallDetect){
                NSArray *options = @[RWChoiceText(@"Off", @"关闭"), RWChoiceText(@"On", @"开启")];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[25]) options:options selectedIndex:1 selection:^(NSInteger selectedIndex) {
                    [DHBleCommand setFallDetect:(UInt8)selectedIndex block:^(int code, id  _Nonnull data) {
                        NSLog(@"setFallDetect value=%zd code=%d", selectedIndex, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:1 sourceRow:25];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 26){ //获取计数提醒间隔
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportCountReminder){
                [DHBleCommand getCountReminderInterval:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        NSLog(@"CountReminderInterval: %@ min", data);
                        [self updateDetailText:([data integerValue] == 0 ? RWChoiceText(@"Off", @"关闭") : [NSString stringWithFormat:@"%@ min", data]) section:1 sourceRow:26];
                    }
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
        else if (indexPath.row == 27){ //设置计数提醒间隔60分钟
            if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportCountReminder){
                NSArray<NSNumber *> *intervals = @[@0, @30, @60, @90, @120];
                NSArray *options = @[RWChoiceText(@"Off", @"关闭"), @"30 min", @"60 min", @"90 min", @"120 min"];
                [self showPickerWithTitle:RWLocalizedFunctionTitle(self.functionHealthList[27]) options:options selectedIndex:2 selection:^(NSInteger selectedIndex) {
                    NSInteger interval = intervals[selectedIndex].integerValue;
                    [DHBleCommand setCountReminderInterval:(UInt8)interval block:^(int code, id  _Nonnull data) {
                        NSLog(@"setCountReminderInterval value=%zd code=%d", interval, code);
                        if (code == 0) [self updateDetailText:options[selectedIndex] section:1 sourceRow:27];
                    }];
                }];
            }
            else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
            }
        }
    }
    else if (indexPath.section == 2){ //多运动
        if ([DHBluetoothManager shareInstance].deviceFuncV2Model && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportWorkout3){
            WorkoutTypeController *typeC = [[WorkoutTypeController alloc] initWithNibName:@"WorkoutTypeController" bundle:nil];
            [self.navigationController pushViewController:typeC animated:YES];
        }
        else{
                SHOWHUD(NSLocalizedString(@"rw_not_supported", nil));
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
    SHOWHUD(NSLocalizedString(@"rw_upgrade_success", nil));
}

- (void)fileSyncingFailed {
    SHOWHUD(NSLocalizedString(@"rw_upgrade_failed", nil));
}

@end
