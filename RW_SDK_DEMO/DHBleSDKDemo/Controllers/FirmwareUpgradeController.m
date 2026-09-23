//
//  FirmwareUpgradeController.m
//  DHBleSDKDemo
//

#import "FirmwareUpgradeController.h"
#import <DHBleSDK/DHBleCommand.h>
#import <DHBleSDK/DHBleCommandEnums.h>
#import <DHBleSDK/DHBleCentralManager.h>
#import <DHBleSDK/DHFirmwareVersionModel.h>

@interface FirmwareUpgradeController ()
@property (nonatomic, strong) UILabel *deviceInfoLabel;
@property (nonatomic, strong) UIButton *firmwareButton;
@property (nonatomic, strong) UIButton *upgradeButton;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, copy) NSArray<NSString *> *firmwareNames;
@property (nonatomic, copy) NSString *selectedFirmware;
@property (nonatomic, assign) BOOL upgrading;
@end

@implementation FirmwareUpgradeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Firmware Upgrade - 固件升级";
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    self.firmwareNames = @[@"YCLY02_2.3.1_2.fot", @"YCLY02_2.3.2_2.fot"];
    [self setupUI];
    [self queryFirmwareInfo];
}

- (void)setupUI {
    self.deviceInfoLabel = [[UILabel alloc] init];
    self.deviceInfoLabel.numberOfLines = 0;
    self.deviceInfoLabel.font = [UIFont systemFontOfSize:16];
    self.deviceInfoLabel.text = @"Device info querying... - 设备信息获取中...";

    self.firmwareButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.firmwareButton setTitle:@"Select Firmware - 选择固件" forState:UIControlStateNormal];
    self.firmwareButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.firmwareButton addTarget:self action:@selector(chooseFirmware) forControlEvents:UIControlEventTouchUpInside];

    self.upgradeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.upgradeButton setTitle:@"Start Upgrade - 开始升级" forState:UIControlStateNormal];
    self.upgradeButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.upgradeButton addTarget:self action:@selector(startUpgrade) forControlEvents:UIControlEventTouchUpInside];
    self.upgradeButton.enabled = NO;

    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.progress = 0;

    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.numberOfLines = 0;
    self.statusLabel.font = [UIFont systemFontOfSize:13];
    self.statusLabel.textColor = UIColor.secondaryLabelColor;
    self.statusLabel.text = @"Select a firmware file to upgrade - 请先选择固件文件";

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[self.deviceInfoLabel,
                                                                         self.firmwareButton,
                                                                         self.upgradeButton,
                                                                         self.progressView,
                                                                         self.statusLabel]];
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    [self.view addSubview:stack];

    [stack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(20);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
    }];
    [self.firmwareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(44);
    }];
    [self.upgradeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(44);
    }];
}

- (void)queryFirmwareInfo {
    [DHBleCommand getFirmwareVersion:^(int code, id _Nonnull data) {
        if (code == 0 && [data isKindOfClass:[DHFirmwareVersionModel class]]) {
            DHFirmwareVersionModel *model = data;
            self.deviceInfoLabel.text = [NSString stringWithFormat:
                @"Model - 型号: %@\nFirmware - 固件版本: %@\nUI Version - UI版本: %@",
                model.deviceModel ?: @"-",
                model.firmwareVersion ?: @"-",
                model.uiVersion ?: @"-"];
        }
        else{
            self.deviceInfoLabel.text = [NSString stringWithFormat:
                @"Get device info failed - 获取设备信息失败 code=%d", code];
        }
    }];
}

- (void)chooseFirmware {
    if (self.upgrading) return;
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"Select Firmware - 选择固件"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *name in self.firmwareNames) {
        [sheet addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            self.selectedFirmware = name;
            [self.firmwareButton setTitle:name forState:UIControlStateNormal];
            self.upgradeButton.enabled = YES;
            self.statusLabel.text = [NSString stringWithFormat:@"Selected - 已选择: %@", name];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"Cancel - 取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)startUpgrade {
    if (self.upgrading || self.selectedFirmware.length == 0) return;
    if (![DHBleCentralManager isConnected]) {
        self.statusLabel.text = @"Device not connected - 设备未连接";
        return;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:self.selectedFirmware.stringByDeletingPathExtension
                                                         ofType:self.selectedFirmware.pathExtension];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (fileData.length == 0) {
        self.statusLabel.text = [NSString stringWithFormat:@"%@ not found in bundle", self.selectedFirmware];
        return;
    }

    self.upgrading = YES;
    self.firmwareButton.enabled = NO;
    self.upgradeButton.enabled = NO;
    self.progressView.progress = 0;
    self.statusLabel.text = [NSString stringWithFormat:@"Upgrading %@ (%lu bytes) - 升级中...",
                             self.selectedFirmware, (unsigned long)fileData.length];
    NSLog(@"ringOta file %@ size %lu", self.selectedFirmware, (unsigned long)fileData.length);

    [DHBleCommand ringOtaWithFileData:fileData block:^(int code, CGFloat progress, id _Nonnull data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"OTA code %d progress %.2f", code, progress);
            if (code == 0 && progress >= 1.0) {
                self.upgrading = NO;
                self.statusLabel.text = @"Upgrade success - 升级成功, 设备重启后可重新进入页面查看新版本";
                [self popAfterUpgradeFinished];
            }
            else if (code != 0) {
                self.upgrading = NO;
                self.statusLabel.text = [NSString stringWithFormat:@"Upgrade failed - 升级失败 code=%d", code];
                [self popAfterUpgradeFinished];
            }
            else {
                self.progressView.progress = progress;
                self.statusLabel.text = [NSString stringWithFormat:@"Upgrading - 升级中 %d%%", (int)(progress * 100)];
            }
        });
    }];
}

// 升级结束后(成功或失败)停留片刻展示结果再返回上一页
- (void)popAfterUpgradeFinished {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

@end
