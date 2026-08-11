//
//  RWHealthDetailController.m
//  DHBleSDKDemo
//

#import "RWHealthDetailController.h"

static UIColor *RWHealthDetailColor(NSString *hex)
{
    return COLOR(hex);
}

@interface RWHealthDetailController ()
@property (nonatomic, copy) NSString *healthTitle;
@property (nonatomic, strong) NSArray<NSString *> *lines;
@property (nonatomic, assign) NSInteger measurementType;
@property (nonatomic, copy) NSString *realtimeValue;
@property (nonatomic, assign) BOOL measuring;
@property (nonatomic, assign) BOOL measurementCommandPending;
@end

@implementation RWHealthDetailController

- (instancetype)initWithTitle:(NSString *)title lines:(NSArray<NSString *> *)lines measurementType:(NSInteger)measurementType
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (!self) return nil;
    self.healthTitle = title;
    self.lines = lines ?: @[];
    self.measurementType = measurementType;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.healthTitle;
    self.view.backgroundColor = RWHealthDetailColor(@"#F6F8FB");
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 52.0;
    self.realtimeValue = NSLocalizedString(@"rw_no_data", nil);
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(realtimeValueChanged:)
                                                 name:BluetoothNotificationHealthRingMeasureValueChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(measurementStateChanged:)
                                                 name:BluetoothNotificationHealthRingMeasureStateChange
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStateChanged:)
                                                 name:BluetoothNotificationConnectStateChange
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)controlMeasurementOpen:(BOOL)isOpen
{
    if (self.measurementCommandPending) return;
    if (![DHBleCentralManager isConnected]) {
        SHOWHUD(NSLocalizedString(@"rw_connect_first", nil))
        return;
    }
    self.measurementCommandPending = YES;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    __weak typeof(self) weakSelf = self;
    [DHBleCommand controlOpen:isOpen ? 1 : 0 dataType:self.measurementType block:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.measurementCommandPending = NO;
            NSString *message = nil;
            if (code == 0) {
                weakSelf.measuring = isOpen;
                message = NSLocalizedString(isOpen ? @"rw_measurement_started" : @"rw_measurement_stopped", nil);
            } else {
                NSString *format = NSLocalizedString(isOpen ? @"rw_measurement_start_failed" : @"rw_measurement_stop_failed", nil);
                message = [NSString stringWithFormat:format, code];
            }
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            SHOWHUD(message)
        });
    }];
}

- (NSInteger)realtimeDataTypeForMeasurementType
{
    switch (self.measurementType) {
        case BLE_KEY_HEART_RATE: return BLE_KEY_APP_REAL_TIME_HR_DATA;
        case BLE_KEY_BLOOD_OXYGEN: return BLE_KEY_APP_REAL_TIME_BLOOD_OXYGEN_DATA;
        case BLE_KEY_HRV: return BLE_KEY_APP_REAL_TIME_HRV_DATA;
        case BLE_KEY_STRESS: return BLE_KEY_APP_REAL_TIME_STRESS_DATA;
        case BLE_KEY_BLOOD_PRESSURE: return BLE_KEY_APP_REAL_TIME_BP_DATA;
        case BLE_KEY_BLOOD_SUGAR: return BLE_KEY_APP_REAL_BLOOD_SUGAR_DATA;
        case BLE_KEY_TEMPERATURE: return BLE_KEY_APP_REAL_TIME_TEMPERATURE_DATA;
        default: return 0;
    }
}

- (void)realtimeValueChanged:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if ([info[@"dataType"] integerValue] != [self realtimeDataTypeForMeasurementType]) return;
    NSString *value = nil;
    if (self.measurementType == BLE_KEY_BLOOD_PRESSURE) {
        value = [NSString stringWithFormat:@"%@/%@ mmHg", info[@"systolic"] ?: @"--", info[@"diastolic"] ?: @"--"];
    } else if (self.measurementType == BLE_KEY_BLOOD_SUGAR) {
        value = [NSString stringWithFormat:@"%.1f mmol/L", [info[@"dataValue"] doubleValue]];
    } else if (self.measurementType == BLE_KEY_TEMPERATURE) {
        value = [NSString stringWithFormat:@"%.1f ℃", [info[@"dataValue"] doubleValue] / 10.0];
    } else {
        NSString *unit = @"";
        if (self.measurementType == BLE_KEY_HEART_RATE) unit = @" bpm";
        else if (self.measurementType == BLE_KEY_BLOOD_OXYGEN) unit = @"%";
        else if (self.measurementType == BLE_KEY_HRV) unit = @" ms";
        value = [NSString stringWithFormat:@"%zd%@", [info[@"dataValue"] integerValue], unit];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.realtimeValue = value ?: NSLocalizedString(@"rw_no_data", nil);
        if (self.measurementType > 0) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (void)measurementStateChanged:(NSNotification *)notification
{
    // ringMeasure=0 对应设备主动返回的检测结束状态；普通控制响应不改变按钮状态。
    if ([notification.userInfo[@"ringMeasure"] integerValue] != 0) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.measuring = NO;
        self.measurementCommandPending = NO;
        if (self.measurementType > 0) {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    });
}

- (void)connectionStateChanged:(NSNotification *)notification
{
    if ([DHBleCentralManager isConnected]) return;
    self.measuring = NO;
    self.measurementCommandPending = NO;
    if (self.measurementType > 0) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.measurementType > 0 ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.measurementType > 0 && section == 0) return 2;
    return MAX(self.lines.count, 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (self.measurementType > 0 && section == 0) return NSLocalizedString(@"rw_realtime_measurement", nil);
    return NSLocalizedString(@"rw_data_details", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"healthDetail"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"healthDetail"];
    if (self.measurementType > 0 && indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (indexPath.row == 0) {
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:26.0];
            cell.textLabel.textAlignment = NSTextAlignmentNatural;
            cell.textLabel.textColor = RWHealthDetailColor(@"#3568D4");
            cell.textLabel.text = self.realtimeValue;
            cell.detailTextLabel.text = self.measuring ? NSLocalizedString(@"rw_measuring", nil) : NSLocalizedString(@"rw_measurement_not_started", nil);
            cell.detailTextLabel.textColor = RWHealthDetailColor(@"#8A94A6");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(self.measuring ? @"rw_stop_measurement" : @"rw_start_measurement", nil);
            cell.textLabel.textColor = self.measuring ? RWHealthDetailColor(@"#E5484D") : RWHealthDetailColor(@"#3568D4");
            cell.detailTextLabel.text = nil;
            cell.selectionStyle = self.measurementCommandPending ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = !self.measurementCommandPending;
        }
        return cell;
    }
    cell.userInteractionEnabled = YES;
    cell.textLabel.textAlignment = NSTextAlignmentNatural;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.textLabel.textColor = RWHealthDetailColor(@"#172033");
    cell.textLabel.text = self.lines.count ? self.lines[indexPath.row] : NSLocalizedString(@"rw_no_detail_data", nil);
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.measurementType > 0 && indexPath.section == 0 && indexPath.row == 1) {
        [self controlMeasurementOpen:!self.measuring];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.measurementType > 0 && indexPath.section == 0) return indexPath.row == 0 ? 88.0 : 54.0;
    return UITableViewAutomaticDimension;
}

@end
