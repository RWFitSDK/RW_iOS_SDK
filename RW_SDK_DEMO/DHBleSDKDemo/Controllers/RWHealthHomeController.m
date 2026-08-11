//
//  RWHealthHomeController.m
//  DHBleSDKDemo
//

#import "RWHealthHomeController.h"
#import "RWHealthDetailController.h"
#import "WorkoutTypeController.h"
#import "ScanViewController.h"
#import <DHBleSDK/DHDailyStepModel.h>
#import <DHBleSDK/DHDailySleepModel.h>
#import <DHBleSDK/DHDailyHrModel.h>
#import <DHBleSDK/DHDailyBoModel.h>
#import <DHBleSDK/DHDailyHrvModel.h>
#import <DHBleSDK/DHDailyBpModel.h>

static UIColor *RWHealthColor(NSString *hex)
{
    return COLOR(hex);
}

@interface RWHealthCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@end

@implementation RWHealthCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;
    self.contentView.backgroundColor = UIColor.whiteColor;
    self.contentView.layer.cornerRadius = 12.0;
    self.contentView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.08].CGColor;
    self.contentView.layer.shadowOpacity = 1.0;
    self.contentView.layer.shadowRadius = 7.0;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 2);

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.titleLabel.textColor = RWHealthColor(@"#172033");
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.font = [UIFont boldSystemFontOfSize:17.0];
    self.valueLabel.textColor = RWHealthColor(@"#3568D4");
    self.detailLabel = [[UILabel alloc] init];
    self.detailLabel.font = [UIFont systemFontOfSize:12.0];
    self.detailLabel.textColor = RWHealthColor(@"#8A94A6");
    self.detailLabel.numberOfLines = 2;
    for (UIView *view in @[self.titleLabel, self.valueLabel, self.detailLabel]) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:view];
    }
    [NSLayoutConstraint activateConstraints:@[
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:14],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:14],
        [self.titleLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-14],
        [self.valueLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:13],
        [self.valueLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.valueLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.contentView.trailingAnchor constant:-14],
        [self.detailLabel.topAnchor constraintEqualToAnchor:self.valueLabel.bottomAnchor constant:6],
        [self.detailLabel.leadingAnchor constraintEqualToAnchor:self.titleLabel.leadingAnchor],
        [self.detailLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-14],
        [self.detailLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor constant:-10]
    ]];
    return self;
}

@end

@interface RWHealthHomeController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIView *deviceCard;
@property (nonatomic, strong) UILabel *deviceNameLabel;
@property (nonatomic, strong) UILabel *deviceStateLabel;
@property (nonatomic, strong) UIButton *deviceActionButton;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray<NSDictionary *> *healthItems;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *healthValues;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<NSString *> *> *healthRecords;
@property (nonatomic, assign) BOOL syncingHealthData;
@end

@implementation RWHealthHomeController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"rw_tab_home", nil);
    if (@available(iOS 11.0, *)) {
        self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = RWHealthColor(@"#F6F8FB");
    self.healthValues = [NSMutableDictionary dictionary];
    self.healthRecords = [NSMutableDictionary dictionary];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshState) name:BluetoothNotificationConnectStateChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realTimeHealthValueChanged:) name:BluetoothNotificationHealthRingMeasureValueChange object:nil];
    [self refreshState];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshState];
}

- (void)setupViews
{
    self.deviceCard = [[UIView alloc] init];
    self.deviceCard.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceCard.backgroundColor = UIColor.whiteColor;
    self.deviceCard.layer.cornerRadius = 14.0;
    [self.view addSubview:self.deviceCard];

    UIView *ringIcon = [[UIView alloc] init];
    ringIcon.translatesAutoresizingMaskIntoConstraints = NO;
    ringIcon.backgroundColor = RWHealthColor(@"#EAF0FF");
    ringIcon.layer.cornerRadius = 24.0;
    UILabel *ringText = [[UILabel alloc] init];
    ringText.translatesAutoresizingMaskIntoConstraints = NO;
    ringText.text = @"◯";
    ringText.textColor = RWHealthColor(@"#3568D4");
    ringText.font = [UIFont boldSystemFontOfSize:24.0];
    ringText.textAlignment = NSTextAlignmentCenter;
    [ringIcon addSubview:ringText];

    self.deviceNameLabel = [[UILabel alloc] init];
    self.deviceNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceNameLabel.font = [UIFont boldSystemFontOfSize:18.0];
    self.deviceNameLabel.textColor = RWHealthColor(@"#172033");
    self.deviceStateLabel = [[UILabel alloc] init];
    self.deviceStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceStateLabel.font = [UIFont systemFontOfSize:13.0];
    self.deviceStateLabel.textColor = RWHealthColor(@"#667085");
    self.deviceActionButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.deviceActionButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.deviceActionButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.deviceActionButton.backgroundColor = RWHealthColor(@"#EDF2FF");
    self.deviceActionButton.layer.cornerRadius = 9.0;
    [self.deviceActionButton addTarget:self action:@selector(deviceAction) forControlEvents:UIControlEventTouchUpInside];
    for (UIView *view in @[ringIcon, self.deviceNameLabel, self.deviceStateLabel, self.deviceActionButton]) [self.deviceCard addSubview:view];

    UILabel *sectionTitle = [[UILabel alloc] init];
    sectionTitle.translatesAutoresizingMaskIntoConstraints = NO;
    sectionTitle.text = NSLocalizedString(@"rw_health_data", nil);
    sectionTitle.font = [UIFont boldSystemFontOfSize:19.0];
    sectionTitle.textColor = RWHealthColor(@"#172033");
    [self.view addSubview:sectionTitle];

    UILabel *hint = [[UILabel alloc] init];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    hint.text = NSLocalizedString(@"rw_pull_to_sync", nil);
    hint.font = [UIFont systemFontOfSize:13.0];
    hint.textColor = RWHealthColor(@"#8A94A6");
    [self.view addSubview:hint];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(2, 2, 18, 2);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = UIColor.clearColor;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    [self.collectionView registerClass:RWHealthCell.class forCellWithReuseIdentifier:@"RWHealthCell"];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(syncHealthData) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
    [self.view addSubview:self.collectionView];

    [NSLayoutConstraint activateConstraints:@[
        [self.deviceCard.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:14],
        [self.deviceCard.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [self.deviceCard.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [self.deviceCard.heightAnchor constraintEqualToConstant:88],
        [ringIcon.leadingAnchor constraintEqualToAnchor:self.deviceCard.leadingAnchor constant:14],
        [ringIcon.centerYAnchor constraintEqualToAnchor:self.deviceCard.centerYAnchor],
        [ringIcon.widthAnchor constraintEqualToConstant:48],
        [ringIcon.heightAnchor constraintEqualToConstant:48],
        [ringText.leadingAnchor constraintEqualToAnchor:ringIcon.leadingAnchor],
        [ringText.trailingAnchor constraintEqualToAnchor:ringIcon.trailingAnchor],
        [ringText.topAnchor constraintEqualToAnchor:ringIcon.topAnchor],
        [ringText.bottomAnchor constraintEqualToAnchor:ringIcon.bottomAnchor],
        [self.deviceNameLabel.leadingAnchor constraintEqualToAnchor:ringIcon.trailingAnchor constant:12],
        [self.deviceNameLabel.topAnchor constraintEqualToAnchor:self.deviceCard.topAnchor constant:20],
        [self.deviceNameLabel.trailingAnchor constraintLessThanOrEqualToAnchor:self.deviceActionButton.leadingAnchor constant:-8],
        [self.deviceStateLabel.leadingAnchor constraintEqualToAnchor:self.deviceNameLabel.leadingAnchor],
        [self.deviceStateLabel.topAnchor constraintEqualToAnchor:self.deviceNameLabel.bottomAnchor constant:6],
        [self.deviceActionButton.trailingAnchor constraintEqualToAnchor:self.deviceCard.trailingAnchor constant:-14],
        [self.deviceActionButton.centerYAnchor constraintEqualToAnchor:self.deviceCard.centerYAnchor],
        [self.deviceActionButton.widthAnchor constraintGreaterThanOrEqualToConstant:82],
        [self.deviceActionButton.heightAnchor constraintEqualToConstant:40],
        [sectionTitle.topAnchor constraintEqualToAnchor:self.deviceCard.bottomAnchor constant:20],
        [sectionTitle.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:18],
        [hint.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-18],
        [hint.centerYAnchor constraintEqualToAnchor:sectionTitle.centerYAnchor],
        [self.collectionView.topAnchor constraintEqualToAnchor:sectionTitle.bottomAnchor constant:10],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:14],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-14],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)refreshState
{
    BOOL connected = [DHBluetoothManager shareInstance].isConnected || [DHBleCentralManager isConnected];
    if (!connected && self.syncingHealthData) {
        self.syncingHealthData = NO;
        [self.refreshControl endRefreshing];
        HUDDISS
    }
    NSString *uuid = [DHBleCentralManager currentBindedUUID] ?: @"";
    NSString *name = [[DHBluetoothManager shareInstance] savedDeviceName];
    self.deviceNameLabel.text = name.length ? name : NSLocalizedString(@"rw_unbound_device", nil);
    self.deviceStateLabel.text = connected ? NSLocalizedString(@"rw_connected", nil) : (uuid.length ? NSLocalizedString(@"rw_saved_disconnected", nil) : NSLocalizedString(@"rw_disconnected", nil));
    NSString *actionTitle = !uuid.length ? NSLocalizedString(@"rw_add_device", nil) : (connected ? NSLocalizedString(@"rw_connected", nil) : NSLocalizedString(@"rw_reconnect", nil));
    [self.deviceActionButton setTitle:actionTitle forState:UIControlStateNormal];
    self.deviceActionButton.enabled = !connected;
    [self rebuildHealthItems];
}

- (void)rebuildHealthItems
{
    DeviceFuncV2Model *menu = [DHBluetoothManager shareInstance].deviceFuncV2Model;
    NSMutableArray *items = [NSMutableArray array];
    void (^add)(BOOL, NSString *, NSString *, NSString *, NSInteger) = ^(BOOL supported, NSString *itemId, NSString *title, NSString *unit, NSInteger measurementType) {
        if (supported) [items addObject:@{@"id":itemId, @"title":title, @"unit":unit ?: @"", @"measurement":@(measurementType)}];
    };
    if (menu) {
        add(menu.isDataTypeActivity, @"step", NSLocalizedString(@"rw_steps", nil), NSLocalizedString(@"rw_unit_steps", nil), 0);
        add(menu.isDataTypeSleep, @"sleep", NSLocalizedString(@"rw_sleep", nil), NSLocalizedString(@"rw_unit_minutes", nil), 0);
        add(menu.isDataTypeHeart, @"heart", NSLocalizedString(@"rw_heart_rate", nil), @"bpm", BLE_KEY_HEART_RATE);
        add(menu.isDataTypeSPO2, @"spo2", NSLocalizedString(@"rw_blood_oxygen", nil), @"%", BLE_KEY_BLOOD_OXYGEN);
        add(menu.isDataTypeHRV, @"hrv", @"HRV", @"ms", BLE_KEY_HRV);
        add(menu.isDataTypeStress, @"stress", NSLocalizedString(@"rw_stress", nil), @"", BLE_KEY_STRESS);
        add(menu.isDataTypeBloodPressure, @"bp", NSLocalizedString(@"rw_blood_pressure", nil), @"mmHg", BLE_KEY_BLOOD_PRESSURE);
        add(menu.isDataTypeBloodSugar, @"sugar", NSLocalizedString(@"rw_blood_sugar", nil), @"mmol/L", BLE_KEY_BLOOD_SUGAR);
        add(menu.isDataTypeTemperature, @"temperature", NSLocalizedString(@"rw_temperature", nil), @"℃", BLE_KEY_TEMPERATURE);
        add(menu.isDataTypeMuslimCount, @"muslim", NSLocalizedString(@"rw_tasbeeh_count", nil), NSLocalizedString(@"rw_unit_times", nil), 0);
        add(menu.isSupportWorkout3, @"workout", NSLocalizedString(@"rw_multi_sport", nil), @"", 0);
    }
    self.healthItems = items;
    [self.collectionView reloadData];
}

- (void)deviceAction
{
    if (![DHBleCentralManager currentBindedUUID].length) {
        ScanViewController *vc = [[ScanViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (![DHBleCentralManager isConnected]) {
        [DHBleCentralManager checkAndAutoReconnectDevice];
    }
}

- (void)syncHealthData
{
    if (![DHBleCentralManager isConnected]) {
        [self.refreshControl endRefreshing];
        SHOWHUD(NSLocalizedString(@"rw_connect_first", nil))
        return;
    }
    self.syncingHealthData = YES;
    [self.healthValues removeAllObjects];
    [self.healthRecords removeAllObjects];
    NSString *initialSyncMessage = [NSString stringWithFormat:NSLocalizedString(@"rw_syncing_progress", nil), 0];
    SHOWHUDNODISS(initialSyncMessage)
    __weak typeof(self) weakSelf = self;
    [DHBleCommand startDataSyncing:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.syncingHealthData = NO;
            [weakSelf.refreshControl endRefreshing];
            HUDDISS
            NSString *message = code == 0 ? NSLocalizedString(@"rw_sync_complete", nil) : [NSString stringWithFormat:NSLocalizedString(@"rw_sync_failed", nil), code];
            SHOWHUD(message)
            [weakSelf.collectionView reloadData];
        });
    } datablcok:^(int code, int progress, id data) {
        if (code == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!weakSelf.syncingHealthData) return;
                [SVProgressHUD showWithStatus:[NSString stringWithFormat:NSLocalizedString(@"rw_syncing_progress", nil), progress]];
                [weakSelf consumeHealthModels:data];
            });
        }
    }];
}

- (void)consumeHealthModels:(id)data
{
    NSArray *models = [data isKindOfClass:NSArray.class] ? data : (data ? @[data] : @[]);
    for (id model in models) {
        NSString *itemId = nil;
        NSString *valueText = nil;
        NSMutableArray<NSString *> *lines = [NSMutableArray array];
        NSString *date = [model respondsToSelector:@selector(date)] ? [model valueForKey:@"date"] : @"";
        if ([model isKindOfClass:DHDailyStepModel.class]) {
            itemId = @"step";
            valueText = [NSString stringWithFormat:@"%@ %@", [model valueForKey:@"step"], NSLocalizedString(@"rw_unit_steps", nil)];
        } else if ([model isKindOfClass:DHDailySleepModel.class]) {
            itemId = @"sleep";
            valueText = [NSString stringWithFormat:@"%@ %@", [model valueForKey:@"duration"], NSLocalizedString(@"rw_unit_minutes", nil)];
        } else if ([model isKindOfClass:DHDailyHrModel.class]) itemId = @"heart";
        else if ([model isKindOfClass:DHDailyBoModel.class]) itemId = @"spo2";
        else if ([model isKindOfClass:DHDailyHrvModel.class]) itemId = @"hrv";
        else if ([model isKindOfClass:DHDailyPressureModel.class]) itemId = @"stress";
        else if ([model isKindOfClass:DHDailyBpModel.class]) itemId = @"bp";
        else if ([model isKindOfClass:DHDailyBloodSugarModel.class]) itemId = @"sugar";
        else if ([model isKindOfClass:DHDailyTempModel.class]) itemId = @"temperature";
        else if ([model isKindOfClass:DHDailyMuslimCountModel.class]) {
            itemId = @"muslim";
            valueText = [NSString stringWithFormat:@"%@ %@", [model valueForKey:@"muslimcount"], NSLocalizedString(@"rw_unit_times", nil)];
        }
        if (!itemId) continue;
        NSArray *modelItems = [model respondsToSelector:@selector(items)] ? [model valueForKey:@"items"] : @[];
        for (NSDictionary *entry in modelItems) {
            [lines addObject:[NSString stringWithFormat:@"%@ · %@", date.length ? date : @"--", entry]];
        }
        NSDictionary *last = [modelItems.lastObject isKindOfClass:NSDictionary.class] ? modelItems.lastObject : nil;
        if (!valueText && last) valueText = [self valueTextForItemId:itemId entry:last];
        if (valueText.length) self.healthValues[itemId] = valueText;
        if (lines.count) {
            NSMutableArray<NSString *> *allLines = [NSMutableArray arrayWithArray:self.healthRecords[itemId] ?: @[]];
            [allLines addObjectsFromArray:lines];
            self.healthRecords[itemId] = allLines;
        }
    }
    [self.collectionView reloadData];
}

- (NSString *)valueTextForItemId:(NSString *)itemId entry:(NSDictionary *)entry
{
    if ([itemId isEqualToString:@"bp"]) {
        return [NSString stringWithFormat:@"%@/%@ mmHg", entry[@"systolic"] ?: @"--", entry[@"diastolic"] ?: @"--"];
    }
    id value = entry[@"value"] ?: @"--";
    if ([itemId isEqualToString:@"temperature"] && [value respondsToSelector:@selector(doubleValue)]) {
        return [NSString stringWithFormat:@"%.1f ℃", [value doubleValue] / 10.0];
    }
    NSString *unit = @"";
    for (NSDictionary *item in self.healthItems) if ([item[@"id"] isEqual:itemId]) { unit = item[@"unit"]; break; }
    return [NSString stringWithFormat:@"%@%@%@", value, unit.length ? @" " : @"", unit];
}

- (void)realTimeHealthValueChanged:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    NSInteger type = [info[@"dataType"] integerValue];
    NSString *itemId = nil;
    if (type == BLE_KEY_APP_REAL_TIME_HR_DATA) itemId = @"heart";
    else if (type == BLE_KEY_APP_REAL_TIME_BLOOD_OXYGEN_DATA) itemId = @"spo2";
    else if (type == BLE_KEY_APP_REAL_TIME_HRV_DATA) itemId = @"hrv";
    else if (type == BLE_KEY_APP_REAL_TIME_STRESS_DATA) itemId = @"stress";
    else if (type == BLE_KEY_APP_REAL_BLOOD_SUGAR_DATA) itemId = @"sugar";
    else if (type == BLE_KEY_APP_REAL_TIME_TEMPERATURE_DATA) itemId = @"temperature";
    else if (type == BLE_KEY_APP_REAL_TIME_MUSLIM_COUNT) itemId = @"muslim";
    else if (type == BLE_KEY_APP_REAL_TIME_BP_DATA) itemId = @"bp";
    if (!itemId) return;
    NSString *value = [itemId isEqualToString:@"bp"]
        ? [NSString stringWithFormat:@"%@/%@ mmHg", info[@"systolic"] ?: @"--", info[@"diastolic"] ?: @"--"]
        : [self valueTextForItemId:itemId entry:@{@"value":info[@"dataValue"] ?: @0}];
    self.healthValues[itemId] = value;
    dispatch_async(dispatch_get_main_queue(), ^{ [self.collectionView reloadData]; });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.healthItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RWHealthCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RWHealthCell" forIndexPath:indexPath];
    NSDictionary *item = self.healthItems[indexPath.item];
    cell.titleLabel.text = item[@"title"];
    cell.valueLabel.text = self.healthValues[item[@"id"]] ?: ([item[@"id"] isEqual:@"workout"] ? NSLocalizedString(@"rw_select_sport", nil) : NSLocalizedString(@"rw_no_data", nil));
    cell.detailLabel.text = [item[@"id"] isEqual:@"workout"] ? NSLocalizedString(@"rw_enter_multi_sport", nil) : NSLocalizedString(@"rw_view_details", nil);
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat width = floor((collectionView.bounds.size.width - 14) / 2.0);
    return CGSizeMake(width, 112);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = self.healthItems[indexPath.item];
    if ([item[@"id"] isEqual:@"workout"]) {
        WorkoutTypeController *controller = [[WorkoutTypeController alloc] initWithNibName:@"WorkoutTypeController" bundle:nil];
        controller.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:controller animated:YES];
        return;
    }
    RWHealthDetailController *detail = [[RWHealthDetailController alloc] initWithTitle:item[@"title"]
                                                                                 lines:self.healthRecords[item[@"id"]]
                                                                       measurementType:[item[@"measurement"] integerValue]];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
