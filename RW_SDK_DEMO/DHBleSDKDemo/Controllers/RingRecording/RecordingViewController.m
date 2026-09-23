#import "RecordingViewController.h"
#import <DHBleSDK/DHBleCommand.h>
#import <DHBleSDK/DHBleCommandEnums.h>

@interface RecordingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, strong) NSArray<UIButton *> *commandButtons;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<NSDictionary *> *fileList;
@property (nonatomic, copy) NSArray<NSString *> *localFiles;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL statusKnown;
@property (nonatomic, assign) BOOL busy;
@end

@implementation RecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"rw_recording", nil);
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.fileList = @[];
    [self setupUI];
    [self reloadLocalFiles];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleProtocolPush:) name:BluetoothNotificationProtocolPush object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionChanged:) name:BluetoothNotificationConnectStateChange object:nil];
    [self queryStatus];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIButton *)buttonWithKey:(NSString *)key action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:NSLocalizedString(key, nil) forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintGreaterThanOrEqualToConstant:44].active = YES;
    return button;
}

- (void)setupUI {
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:16];
    self.statusLabel.text = NSLocalizedString(@"rw_record_querying", nil);
    self.resultLabel = [[UILabel alloc] init];
    self.resultLabel.numberOfLines = 0;
    self.resultLabel.font = [UIFont systemFontOfSize:13];
    self.resultLabel.textColor = UIColor.secondaryLabelColor;
    self.resultLabel.text = NSLocalizedString(@"rw_record_file_hint", nil);
    self.recordButton = [self buttonWithKey:@"rw_record_start" action:@selector(toggleRecording)];
    UIButton *query = [self buttonWithKey:@"rw_record_query" action:@selector(queryStatus)];
    UIButton *list = [self buttonWithKey:@"rw_record_list" action:@selector(loadFileList)];
    UIButton *format = [self buttonWithKey:@"rw_record_format" action:@selector(confirmFormat)];
    [format setTitleColor:UIColor.systemRedColor forState:UIControlStateNormal];
    self.commandButtons = @[self.recordButton, query, list, format];
    UIStackView *firstRow = [[UIStackView alloc] initWithArrangedSubviews:@[self.recordButton, query]];
    UIStackView *secondRow = [[UIStackView alloc] initWithArrangedSubviews:@[list, format]];
    firstRow.distribution = secondRow.distribution = UIStackViewDistributionFillEqually;
    UIStackView *header = [[UIStackView alloc] initWithArrangedSubviews:@[self.statusLabel, firstRow, secondRow, self.resultLabel]];
    header.axis = UILayoutConstraintAxisVertical;
    header.spacing = 8;
    header.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:header];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 72;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.tableView];
    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor constant:12],
        [header.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20],
        [header.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20],
        [self.tableView.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:8],
        [self.tableView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:safe.bottomAnchor]
    ]];
}

- (void)setBusy:(BOOL)busy {
    _busy = busy;
    [self updateButtons];
}

- (void)updateButtons {
    BOOL enabled = !self.busy && [DHBleCentralManager isConnected];
    for (UIButton *button in self.commandButtons) button.enabled = enabled;
    self.recordButton.enabled = enabled && self.statusKnown;
}

// 一次只执行一个页面操作，避免重复下载覆盖 SDK 当前文件传输回调。
- (BOOL)beginOperation {
    if (self.busy) return NO;
    if (![DHBleCentralManager isConnected]) {
        self.resultLabel.text = NSLocalizedString(@"rw_record_disconnected", nil);
        return NO;
    }
    self.busy = YES;
    self.resultLabel.text = NSLocalizedString(@"rw_record_processing", nil);
    return YES;
}

- (void)connectionChanged:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![DHBleCentralManager isConnected]) {
            self.statusKnown = NO;
            self.busy = NO;
            self.fileList = @[];
            self.statusLabel.text = NSLocalizedString(@"rw_record_disconnected", nil);
            self.resultLabel.text = self.statusLabel.text;
            [self.tableView reloadData];
        } else {
            [self updateButtons];
        }
    });
}

- (void)showResult:(BOOL)success code:(int)code {
    self.busy = NO;
    self.resultLabel.text = success ? NSLocalizedString(@"rw_record_success", nil) :
        [NSString stringWithFormat:NSLocalizedString(@"rw_record_failed", nil), code ?: -1];
}

- (void)updateStatus:(NSDictionary *)info {
    self.statusKnown = YES;
    self.isRecording = [info[@"isRecording"] boolValue];
    self.statusLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rw_record_status", nil),
        NSLocalizedString(self.isRecording ? @"rw_record_active" : @"rw_record_idle", nil),
        [info[@"duration"] integerValue],
        [NSByteCountFormatter stringFromByteCount:[info[@"remainingCapacity"] longLongValue] countStyle:NSByteCountFormatterCountStyleFile],
        [NSByteCountFormatter stringFromByteCount:[info[@"totalCapacity"] longLongValue] countStyle:NSByteCountFormatterCountStyleFile]];
    [self.recordButton setTitle:NSLocalizedString(self.isRecording ? @"rw_record_stop" : @"rw_record_start", nil) forState:UIControlStateNormal];
    self.recordButton.tintColor = self.isRecording ? UIColor.systemRedColor : UIColor.systemBlueColor;
    [self updateButtons];
}

- (void)handleProtocolPush:(NSNotification *)notification {
    if ([notification.userInfo[@"dataType"] unsignedIntegerValue] != DHDevicePushTypeRecordStatus) return;
    NSDictionary *info = notification.userInfo[@"dataValue"];
    if (![info isKindOfClass:NSDictionary.class]) return;
    dispatch_async(dispatch_get_main_queue(), ^{ [self updateStatus:info]; });
}

- (void)queryStatus {
    if (![self beginOperation]) return;
    __weak typeof(self) weakSelf = self;
    [DHBleCommand getRecordStatus:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = code == 0 && [data isKindOfClass:NSDictionary.class];
            if (success) [weakSelf updateStatus:data];
            [weakSelf showResult:success code:code];
        });
    }];
}

- (void)toggleRecording {
    if (!self.statusKnown || ![self beginOperation]) return;
    __weak typeof(self) weakSelf = self;
    [DHBleCommand recordControl:!self.isRecording block:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = code == 0 && [data isKindOfClass:NSNumber.class] && [data intValue] == 0;
            [weakSelf showResult:success code:code ?: ([data isKindOfClass:NSNumber.class] ? [data intValue] : -1)];
            if (success) [weakSelf queryStatus];
        });
    }];
}

- (void)loadFileList {
    if (![self beginOperation]) return;
    __weak typeof(self) weakSelf = self;
    [DHBleCommand getRecordFileList:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = code == 0 && [data isKindOfClass:NSArray.class];
            if (success) {
                weakSelf.fileList = data;
                [weakSelf.tableView reloadData];
            }
            [weakSelf showResult:success code:code];
        });
    }];
}

- (void)confirmFormat {
    [self confirmDeleteWithMessage:NSLocalizedString(@"rw_record_format_warning", nil) action:^{
        if (![self beginOperation]) return;
        __weak typeof(self) weakSelf = self;
        [DHBleCommand formatRecordStorage:^(int code, id data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                BOOL success = code == 0 && [data isKindOfClass:NSNumber.class] && [data intValue] == 0;
                [weakSelf showResult:success code:code ?: ([data isKindOfClass:NSNumber.class] ? [data intValue] : -1)];
                if (success) { weakSelf.fileList = @[]; [weakSelf.tableView reloadData]; [weakSelf queryStatus]; }
            });
        }];
    }];
}

- (NSString *)recordingDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Recording"];
}

- (void)reloadLocalFiles {
    NSMutableArray *files = [NSMutableArray array];
    for (NSString *name in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self recordingDirectory] error:nil]) {
        if ([name.pathExtension.lowercaseString isEqualToString:@"opus"]) [files addObject:[[self recordingDirectory] stringByAppendingPathComponent:name]];
    }
    self.localFiles = [files sortedArrayUsingSelector:@selector(compare:)];
    [self.tableView reloadData];
}

- (void)downloadFile:(NSDictionary *)item {
    if (![self beginOperation]) return;
    __weak typeof(self) weakSelf = self;
    UInt32 fileId = [item[@"fileId"] unsignedIntValue];
    [DHBleCommand transferRecordFile:fileId block:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) self = weakSelf;
            if (!self) return;
            BOOL success = code == 0 && [data isKindOfClass:NSData.class];
            NSError *error = nil;
            if (success) {
                NSString *directory = [self recordingDirectory];
                success = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
                // SDK 已将原始录音封装为 Ogg Opus，直接保存，无需 AI 或解码库。
                NSString *name = [NSString stringWithFormat:@"%u_%@_%.0f.opus", fileId, item[@"duration"], NSDate.date.timeIntervalSince1970];
                NSString *path = [directory stringByAppendingPathComponent:name];
                if (success) success = [data writeToFile:path options:NSDataWritingAtomic error:&error];
                if (success) NSLog(@"Recording saved: %@ (%lu bytes)", path, (unsigned long)[data length]);
            }
            [self showResult:success code:code];
            if (error) self.resultLabel.text = error.localizedDescription;
            if (success) { self.resultLabel.text = NSLocalizedString(@"rw_record_saved", nil); [self reloadLocalFiles]; }
        });
    } progressBlock:^(int code, CGFloat progress, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.busy) weakSelf.resultLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rw_record_progress", nil), progress * 100];
        });
    }];
}

- (void)deleteDeviceFile:(UInt32)fileId {
    if (![self beginOperation]) return;
    __weak typeof(self) weakSelf = self;
    [DHBleCommand deleteRecordFile:fileId block:^(int code, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL success = code == 0 && [data isKindOfClass:NSNumber.class] && [data intValue] == 0;
            [weakSelf showResult:success code:code ?: ([data isKindOfClass:NSNumber.class] ? [data intValue] : -1)];
            if (success) [weakSelf loadFileList];
        });
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 2; }
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return section == 0 ? self.fileList.count : self.localFiles.count; }
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return NSLocalizedString(section == 0 ? @"rw_record_device_files" : @"rw_record_local_files", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecordingFile"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RecordingFile"];
    cell.textLabel.numberOfLines = cell.detailTextLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        NSDictionary *item = self.fileList[indexPath.row];
        // 文件列表保留设备时间：从 2000 年起计秒，转换方式沿用 RingRecording。
        NSTimeInterval timestamp = [item[@"timestamp"] doubleValue];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        cell.textLabel.text = [NSString stringWithFormat:@"ID: %@  %@", item[@"fileId"], [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timestamp]]];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"rw_record_file_detail", nil), [item[@"duration"] integerValue],
            [NSByteCountFormatter stringFromByteCount:[item[@"fileSize"] longLongValue] countStyle:NSByteCountFormatterCountStyleFile]];
    } else {
        NSString *path = self.localFiles[indexPath.row];
        cell.textLabel.text = path.lastPathComponent;
        cell.detailTextLabel.text = [NSByteCountFormatter stringFromByteCount:[[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize] countStyle:NSByteCountFormatterCountStyleFile];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.busy && indexPath.section == 0) return;
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIView *source = [tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.section == 0) {
        NSDictionary *item = self.fileList[indexPath.row];
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_download", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [self downloadFile:item]; }]];
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self confirmDeleteWithMessage:NSLocalizedString(@"rw_record_delete_warning", nil) action:^{ [self deleteDeviceFile:[item[@"fileId"] unsignedIntValue]]; }];
        }]];
    } else {
        NSString *path = self.localFiles[indexPath.row];
        [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_share", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIActivityViewController *share = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:path]] applicationActivities:nil];
            [self presentPopover:share source:source];
        }]];
        // Bundle 内的演示样例只允许使用和分享，不提供删除。
        BOOL isBundledSample = [path hasPrefix:[NSBundle.mainBundle.bundlePath stringByAppendingString:@"/"]];
        if (!isBundledSample) {
            [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self confirmDeleteWithMessage:path.lastPathComponent action:^{
                    NSError *error = nil;
                    if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) self.resultLabel.text = error.localizedDescription;
                    [self reloadLocalFiles];
                }];
            }]];
        }
    }
    [sheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentPopover:sheet source:source];
}

- (void)presentPopover:(UIViewController *)controller source:(UIView *)source {
    controller.popoverPresentationController.sourceView = source ?: self.view;
    controller.popoverPresentationController.sourceRect = (source ?: self.view).bounds;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)confirmDeleteWithMessage:(NSString *)message action:(void (^)(void))action {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"rw_record_confirm", nil) message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"rw_record_confirm", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *item) { action(); }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
