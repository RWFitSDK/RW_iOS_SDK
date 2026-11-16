#import "RWActigraphyController.h"

@interface RWActigraphyController ()
@property (nonatomic, copy, readwrite) NSArray<DHActigraphySyncModel *> *records;
@property (nonatomic, strong) UIButton *syncButton;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, copy) NSString *deviceIdentifier;
@property (nonatomic, strong) NSObject *syncToken;
@end

@implementation RWActigraphyController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _records = @[];
        _deviceIdentifier = [self boundDeviceIdentifier];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"rw_actigraphy", nil);
    self.view.backgroundColor = COLOR(@"#F6F8FB");
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 156)];
    UIView *card = [[UIView alloc] init];
    card.backgroundColor = UIColor.whiteColor;
    card.layer.cornerRadius = 12;
    [header addSubview:card];
    self.syncButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.syncButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.syncButton addTarget:self action:@selector(syncRecords) forControlEvents:UIControlEventTouchUpInside];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.hidesWhenStopped = YES;
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.font = [UIFont systemFontOfSize:13];
    self.statusLabel.textColor = COLOR(@"#667085");
    self.statusLabel.numberOfLines = 2;
    self.statusLabel.text = NSLocalizedString(@"rw_actigraphy_sync_hint", nil);
    for (UIView *view in @[self.syncButton, self.spinner, self.statusLabel]) [card addSubview:view];
    [card mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(header).insets(UIEdgeInsetsMake(12, 16, 12, 16));
    }];
    [self.syncButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(card).offset(16);
        make.trailing.equalTo(self.spinner.mas_leading).offset(-12);
        make.height.mas_equalTo(44);
    }];
    [self.spinner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(card).offset(-16);
        make.centerY.equalTo(self.syncButton);
        make.width.height.mas_equalTo(24);
    }];
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.syncButton.mas_bottom).offset(8);
        make.leading.equalTo(card).offset(16);
        make.trailing.equalTo(card).offset(-16);
        make.bottom.lessThanOrEqualTo(card).offset(-12);
    }];
    self.tableView.tableHeaderView = header;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStateChanged:)
                                                 name:BluetoothNotificationConnectStateChange object:nil];
    [self refreshControls];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshControls];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)boundDeviceIdentifier { return [DHBleCentralManager currentBindedUUID] ?: @""; }

- (BOOL)canSync
{
    return [DHBleCentralManager isConnected] && [DHBluetoothManager shareInstance].deviceFuncV2Model.isSupportActigraphy;
}

- (void)requestRecords:(void(^)(int code, NSArray<DHActigraphySyncModel *> * _Nullable records))completion
{
    [DHBleCommand syncActigraphy:completion];
}

- (void)refreshControls
{
    BOOL syncing = self.syncToken != nil;
    self.syncButton.enabled = !syncing && [self canSync] && [self.deviceIdentifier isEqualToString:[self boundDeviceIdentifier]];
    [self.syncButton setTitle:NSLocalizedString(syncing ? @"rw_actigraphy_syncing" : @"rw_actigraphy_sync", nil)
                    forState:UIControlStateNormal];
    if (syncing) [self.spinner startAnimating];
    else [self.spinner stopAnimating];
}

- (void)syncRecords
{
    if (self.syncToken) return;
    if (![self canSync] || ![self.deviceIdentifier isEqualToString:[self boundDeviceIdentifier]]) {
        self.statusLabel.text = NSLocalizedString(@"rw_connect_first", nil);
        [self refreshControls];
        return;
    }
    NSObject *token = [[NSObject alloc] init];
    self.syncToken = token;
    self.statusLabel.text = NSLocalizedString(@"rw_actigraphy_syncing", nil);
    [self refreshControls];
    __weak typeof(self) weakSelf = self;
    [self requestRecords:^(int code, NSArray<DHActigraphySyncModel *> *records) {
        RWActigraphyController *controller = weakSelf;
        if (!controller || controller.syncToken != token) return;
        controller.syncToken = nil;
        if (![controller.deviceIdentifier isEqualToString:[controller boundDeviceIdentifier]]) {
            controller.records = @[];
            controller.statusLabel.text = NSLocalizedString(@"rw_connect_first", nil);
        } else if (code == 0) {
            controller.records = [records sortedArrayUsingComparator:^NSComparisonResult(DHActigraphySyncModel *a, DHActigraphySyncModel *b) {
                return a.timestamp > b.timestamp ? NSOrderedAscending : (a.timestamp < b.timestamp ? NSOrderedDescending : NSOrderedSame);
            }] ?: @[];
            controller.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rw_actigraphy_sync_complete", nil),
                                           (unsigned long)controller.records.count];
            NSUInteger values = 0;
            for (DHActigraphySyncModel *record in controller.records) values += record.validCount;
            NSLog(@"[RWSDK Demo] Actigraphy sync complete groups=%lu values=%lu", (unsigned long)controller.records.count, (unsigned long)values);
            if (controller.onRecordsUpdated) controller.onRecordsUpdated(controller.records);
        } else {
            controller.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rw_sync_failed", nil), code];
            NSLog(@"[RWSDK Demo] Actigraphy sync failed code=%d", code);
        }
        [controller refreshControls];
        [controller.tableView reloadData];
    }];
}

- (void)connectionStateChanged:(NSNotification *)notification
{
    BOOL changed = ![self.deviceIdentifier isEqualToString:[self boundDeviceIdentifier]];
    if (![self canSync] || changed) {
        self.syncToken = nil;
        self.statusLabel.text = NSLocalizedString(@"rw_connect_first", nil);
    }
    if (changed) {
        self.records = @[];
        [self.tableView reloadData];
    }
    [self refreshControls];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return MAX(self.records.count, 1);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"rw_data_details", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"actigraphy"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"actigraphy"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont monospacedSystemFontOfSize:12 weight:UIFontWeightRegular];
    cell.detailTextLabel.textColor = COLOR(@"#667085");
    cell.detailTextLabel.numberOfLines = 0;
    if (self.records.count == 0) {
        cell.textLabel.text = NSLocalizedString(@"rw_actigraphy_empty", nil);
        cell.detailTextLabel.text = nil;
    } else {
        DHActigraphySyncModel *record = self.records[indexPath.row];
        NSString *time = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:record.timestamp]];
        cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", time,
                              [NSString stringWithFormat:NSLocalizedString(@"rw_actigraphy_valid_count", nil), (unsigned long)record.validCount]];
        NSString *values = [[record.activityCounts valueForKey:@"stringValue"] componentsJoinedByString:@", "];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"activityCounts: [%@]", values];
    }
    return cell;
}

@end
