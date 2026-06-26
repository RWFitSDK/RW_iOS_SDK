//
//  ScanViewController.m
//  DHBleSDKDemo
//
//  Created by DHS on 2022/7/22.
//

#import "ScanViewController.h"
#import "NewHomeController.h"

@interface ScanViewController ()<UITableViewDelegate,UITableViewDataSource,DHBleConnectDelegate>

#pragma mark - UI
/// 列表视图
@property (nonatomic, strong) UITableView *myTableView;

#pragma mark - Data
/// 列表数据源
@property (nonatomic, strong) NSMutableArray *dataArray;
/// 列表数据源
@property (nonatomic, strong) NSMutableArray *deviceArray;

@property (nonatomic, strong) DHPeripheralModel *deviceModel;

/// 列表数据源
@property (nonatomic, strong) NSArray *deviceTempArray;

@property (nonatomic, assign) BOOL isReady;

@end

@implementation ScanViewController

#pragma mark - vc lift cycle 生命周期

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [DHBleCentralManager stopScan];
    [DHBleCentralManager shareInstance].connectDelegate = [DHBluetoothManager shareInstance];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [DHBleCentralManager shareInstance].connectDelegate = self;
    [self performSelector:@selector(startScan) withObject:nil afterDelay:0.2];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)navRightButtonClick:(UIButton *)sender {
    [self startScan];
}

#pragma mark - custom action for UI 界面处理有关

- (void)setupUI {
    [self.myTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.top.equalTo(self.navigationView.mas_bottom).offset(10);
        make.bottom.offset(-kBottomHeight);
    }];
}

- (void)startAnimation {
    CABasicAnimation *animation =  [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = [NSNumber numberWithFloat:0.f];
    animation.toValue =  [NSNumber numberWithFloat: M_PI *2];
    animation.duration  = 0.5;
    animation.autoreverses = NO;
    animation.fillMode =kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.repeatCount = MAXFLOAT;
    [self.navigationView.navRightButton.layer addAnimation:animation forKey:nil];
    self.navigationView.navRightButton.userInteractionEnabled = NO;
}

- (void)removeAnimation {
    [self.navigationView.navRightButton.layer removeAllAnimations];
    self.navigationView.navRightButton.userInteractionEnabled = YES;
}

- (void)startScan {
    if ([DHBleCentralManager isPoweredOff]) {
        SHOWHUD(@"手机蓝牙未开启")
        return;
    }
    
    self.isReady = YES;
    self.deviceTempArray = [NSArray array];
    [self.deviceArray removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.myTableView reloadData];
    [self removeAnimation];
    [self startAnimation];
    [DHBleCentralManager startScan];
    
    [self performSelector:@selector(checkTimeout) withObject:nil afterDelay:5.0];
}

- (void)checkTimeout {
    [self removeAnimation];
    [DHBleCentralManager stopScan];
}

- (void)checkConnecting {
    [DHBluetoothManager shareInstance].isConnected = NO;
    SHOWHUD(@"连接失败")
    
    [DHBleCentralManager disconnectDevice];
}

#pragma mark - DHBleConnectDelegate

- (void)centralManagerDidDiscoverPeripheral:(NSArray <DHPeripheralModel *>*)peripherals {
    
    if (self.isReady) {
        self.isReady = NO;
        self.deviceTempArray = peripherals;
        [self performSelector:@selector(updateTableView) withObject:nil afterDelay:0.5];
    }
}

- (void)updateTableView {
    [self.deviceArray removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.deviceArray addObjectsFromArray:self.deviceTempArray];
    for (DHPeripheralModel *model in self.deviceArray) {
        if (model.macAddr.length == 0) {
            continue;
        }
        BaseCellModel *cellModel = [[BaseCellModel alloc] init];
        cellModel.leftTitle = model.name;
        cellModel.subTitle = [NSString stringWithFormat:@"%ld",(long)model.rssi];
        cellModel.contentTitle = model.macAddr;
        [self.dataArray addObject:cellModel];
    }
    [self.myTableView reloadData];
    self.isReady = YES;
}

- (void)centralManagerDidConnectPeripheral:(CBPeripheral *)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    SHOWHUD(@"连接成功")
    [DHBluetoothManager shareInstance].isConnected = YES;
    
}

- (void)centralManagerDidFunctionMenu:(DeviceFuncV2Model *)deviceFuncModel peripheral:(DHPeripheralModel *)peripheral
{
    NSLog(@"centralManagerDidFunctionMenu");
    [DHBleCentralManager shareInstance].connectDelegate = [DHBluetoothManager shareInstance];
    
    [DHBluetoothManager shareInstance].deviceFuncV2Model = deviceFuncModel;
    
    [[DHBluetoothManager shareInstance] bindedOk];
    
    self.deviceModel = peripheral;
    
    NewHomeController *vc = [[NewHomeController alloc] init];
    vc.deviceModel = self.deviceModel;
    vc.navTitle = self.deviceModel.name;
    vc.isHideNavRightButton = YES;
    vc.isHideNavLeftButton = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)centralManagerDidDisconnectPeripheral:(CBPeripheral *)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [DHBluetoothManager shareInstance].isConnected = NO;
    
    [DHBluetoothManager shareInstance].deviceFuncV2Model = nil; //断开清理,防止使用老值

    HUDDISS
}

- (void)centralManagerDidFailedPeripheral:(CBPeripheral *)peripheral {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [DHBluetoothManager shareInstance].isConnected = NO;
    
    [DHBluetoothManager shareInstance].deviceFuncV2Model = nil; //断开清理,防止使用老值

    HUDDISS
}

- (void)centralManagerDidUpdateState:(BOOL)isOn {
    if (!isOn) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [DHBluetoothManager shareInstance].isConnected = NO;
        HUDDISS
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BaseTableViewCell" forIndexPath:indexPath];
    BaseCellModel *cellModel = self.dataArray[indexPath.row];
    cell.model = cellModel;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([DHBleCentralManager isPoweredOff]) {
        SHOWHUD(@"手机蓝牙未开启")
        return;
    }
    SHOWHUDNODISS(@"正在连接")
    [self removeAnimation];
    [DHBleCentralManager stopScan];

    DHPeripheralModel *deviceModel = self.deviceArray[indexPath.row];
    [DHBleCentralManager connectDeviceWithModel:deviceModel];
    self.deviceModel = deviceModel;
    
    [self performSelector:@selector(checkConnecting) withObject:nil afterDelay:10.0];
    
}

#pragma mark - get and set 属性的set和get方法

- (UITableView *)myTableView {
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _myTableView.backgroundColor = HomeColor_BackgroundColor;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _myTableView.rowHeight = 90;
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [_myTableView registerClass:[BaseTableViewCell class] forCellReuseIdentifier:@"BaseTableViewCell"];
        [self.view addSubview:_myTableView];
    }
    return _myTableView;
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableArray *)deviceArray {
    if (!_deviceArray) {
        _deviceArray = [NSMutableArray array];
    }
    return _deviceArray;
}

@end
