//
//  DHBleSDKDemoTests.m
//  DHBleSDKDemoTests
//
//  Created by DHS on 2022/6/23.
//

#import <XCTest/XCTest.h>
#import <DHBleSDK/DHBleSDK.h>
#import "../DHBleSDKDemo/Controllers/RWActigraphyController.h"
#import "../DHBleSDKDemo/Controllers/RWHealthHomeController.h"
#import "../DHBleSDKDemo/Managers/DHBluetoothManager.h"
#import "../DHBleSDKDemo/Controllers/NewHomeController.h"

@interface NewHomeController (BatteryDisplayTests)
- (void)protocolPushNotification:(NSNotification *)note;
- (void)displayBattery:(DHBatteryInfoModel *)model source:(NSString *)source;
- (void)updateDetailText:(NSString *)text section:(NSInteger)section sourceRow:(NSInteger)row;
@end
@interface RWBatteryDisplayCapture : NewHomeController
@property NSString *batteryText;
@property NSInteger batterySection;
@property NSInteger batteryRow;
@end
@implementation RWBatteryDisplayCapture
- (void)updateDetailText:(NSString *)text section:(NSInteger)section sourceRow:(NSInteger)row {
    self.batteryText = text; self.batterySection = section; self.batteryRow = row;
}
@end
@interface RWBatteryDisplayTests : XCTestCase
@end
@implementation RWBatteryDisplayTests
- (void)testChargingAndUnpluggedPushUpdateExistingBatteryItem {
    RWBatteryDisplayCapture *page = [RWBatteryDisplayCapture new];
    BOOL chinese = [[[NSLocale preferredLanguages] firstObject] hasPrefix:@"zh"];
    for (NSNumber *status in @[@1, @0]) {
        DHBatteryInfoModel *model = [DHBatteryInfoModel new]; model.battery = 25; model.status = status.integerValue;
        NSNotification *note = [NSNotification notificationWithName:BluetoothNotificationProtocolPush object:nil
            userInfo:@{@"dataType": @(DHDevicePushTypePower), @"dataValue": model}];
        [page protocolPushNotification:note];
        NSString *label = status.integerValue == 1 ? (chinese ? @"充电中" : @"Charging") : (chinese ? @"未充电" : @"Not charging");
        XCTAssertEqualObjects(page.batteryText, [@"25% · " stringByAppendingString:label]);
        XCTAssertEqual(page.batterySection, 0); XCTAssertEqual(page.batteryRow, 4);
    }
}
- (void)testQueryUsesSameBatteryDisplayAndUnknownStateIsNotShownAsUnplugged {
    RWBatteryDisplayCapture *page = [RWBatteryDisplayCapture new];
    DHBatteryInfoModel *model = [DHBatteryInfoModel new]; model.battery = 50; model.status = 2;
    [page displayBattery:model source:@"query"];
    XCTAssertTrue([page.batteryText hasPrefix:@"50% · "]);
    XCTAssertTrue([page.batteryText containsString:@"2"]);
    XCTAssertFalse([page.batteryText containsString:@"未充电"]);
    XCTAssertFalse([page.batteryText containsString:@"Not charging"]);
}
@end

@interface RWActigraphyController (DemoTests)
- (NSString *)boundDeviceIdentifier;
- (BOOL)canSync;
- (void)syncRecords;
- (void)connectionStateChanged:(NSNotification *)notification;
- (void)requestRecords:(void(^)(int code, NSArray<DHActigraphySyncModel *> * _Nullable records))completion;
@end

@interface RWHealthHomeController (ActigraphyDemoTests)
- (void)rebuildHealthItems;
- (void)collectionView:(UICollectionView *)view didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface RWActigraphyDemoCapture : RWActigraphyController
@property (nonatomic, assign) BOOL ready;
@property (nonatomic, copy) NSString *mockIdentifier;
@property (nonatomic, assign) NSInteger requests;
@property (nonatomic, copy) void(^pending)(int code, NSArray *records);
@end

@implementation RWActigraphyDemoCapture
- (NSString *)boundDeviceIdentifier { return self.mockIdentifier ?: @"ring-a"; }
- (BOOL)canSync { return self.ready; }
- (void)requestRecords:(void(^)(int code, NSArray<DHActigraphySyncModel *> * _Nullable records))completion {
    self.requests++;
    self.pending = completion;
}
@end

@interface RWActigraphyDemoTests : XCTestCase
@property (nonatomic, strong) RWActigraphyDemoCapture *controller;
@end

@implementation RWActigraphyDemoTests
- (void)setUp {
    [super setUp];
    self.controller = [[RWActigraphyDemoCapture alloc] init];
    self.controller.ready = YES;
    self.controller.mockIdentifier = @"ring-a";
    [self.controller loadViewIfNeeded];
}
- (void)tearDown {
    self.controller.pending = nil;
    self.controller = nil;
    [super tearDown];
}
- (DHActigraphySyncModel *)record:(int64_t)time values:(NSArray *)values {
    DHActigraphySyncModel *record = [[DHActigraphySyncModel alloc] init];
    record.timestamp = time;
    record.validCount = values.count;
    record.activityCounts = values;
    return record;
}
- (void)testEntryDoesNotSyncAutomaticallyAndEmptyHintUsesDetailButton {
    XCTAssertEqual(self.controller.requests, 0);
    UITableViewCell *cell = [self.controller tableView:self.controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    XCTAssertEqualObjects(cell.textLabel.text, NSLocalizedString(@"rw_actigraphy_empty", nil));
    XCTAssertNil(cell.detailTextLabel.text);
}
- (void)testBusyDisablesButtonAndSuccessUpdatesRecordsOnce {
    __block NSInteger updates = 0;
    self.controller.onRecordsUpdated = ^(NSArray *records) { updates++; XCTAssertEqual(records.count, 2u); };
    [self.controller syncRecords];
    [self.controller syncRecords];
    XCTAssertEqual(self.controller.requests, 1);
    XCTAssertFalse([[self.controller valueForKey:@"syncButton"] isEnabled]);
    XCTAssertTrue([[self.controller valueForKey:@"spinner"] isAnimating]);
    self.controller.pending(0, @[[self record:900 values:@[@358]], [self record:1800 values:@[@1, @2]]]);
    XCTAssertEqual(updates, 1);
    XCTAssertEqual(self.controller.records.firstObject.timestamp, 1800);
    XCTAssertTrue([[self.controller valueForKey:@"syncButton"] isEnabled]);
    XCTAssertFalse([[self.controller valueForKey:@"spinner"] isAnimating]);
    [self.controller syncRecords];
    XCTAssertEqual(self.controller.requests, 2);
}
- (void)testValuesUseBracketsAndCommaSeparatedList {
    [self.controller syncRecords];
    self.controller.pending(0, @[[self record:900 values:@[@358]], [self record:1800 values:@[@1, @65535, @0]]]);
    UITableViewCell *first = [self.controller tableView:self.controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITableViewCell *second = [self.controller tableView:self.controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    XCTAssertEqualObjects(first.detailTextLabel.text, @"activityCounts: [1, 65535, 0]");
    XCTAssertTrue([first.textLabel.text containsString:@"3/30"]);
    XCTAssertEqualObjects(second.detailTextLabel.text, @"activityCounts: [358]");
    XCTAssertEqual(first.detailTextLabel.numberOfLines, 0);
}
- (void)testFailurePreservesExistingDataAndAllowsRetry {
    [self.controller syncRecords];
    self.controller.pending(0, @[[self record:900 values:@[@358]]]);
    [self.controller syncRecords];
    self.controller.pending(3, nil);
    XCTAssertEqual(self.controller.records.count, 1u);
    XCTAssertTrue([[self.controller valueForKey:@"statusLabel"] text].length > 0);
    XCTAssertTrue([[self.controller valueForKey:@"syncButton"] isEnabled]);
    XCTAssertFalse([[self.controller valueForKey:@"spinner"] isAnimating]);
}
- (void)testUnavailableDeviceDoesNotStartSync {
    self.controller.ready = NO;
    [self.controller syncRecords];
    XCTAssertEqual(self.controller.requests, 0);
    XCTAssertFalse([[self.controller valueForKey:@"syncButton"] isEnabled]);
    XCTAssertFalse([[self.controller valueForKey:@"spinner"] isAnimating]);
}
- (void)testFullGroupUsesMultilineSelfSizingRow {
    NSMutableArray *values = [NSMutableArray array];
    for (NSUInteger i = 0; i < 30; i++) [values addObject:@65535];
    self.controller.view.frame = CGRectMake(0, 0, 390, 844);
    [self.controller syncRecords];
    self.controller.pending(0, @[[self record:1800 values:values], [self record:900 values:@[@358]]]);
    [self.controller.tableView layoutIfNeeded];
    CGFloat fullHeight = [self.controller.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].size.height;
    CGFloat shortHeight = [self.controller.tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]].size.height;
    XCTAssertGreaterThan(fullHeight, shortHeight);
}
- (void)testDisconnectIgnoresOldCallbackAndReconnectCanRetry {
    [self.controller syncRecords];
    void(^oldCompletion)(int, NSArray *) = self.controller.pending;
    self.controller.ready = NO;
    [self.controller connectionStateChanged:nil];
    XCTAssertFalse([[self.controller valueForKey:@"spinner"] isAnimating]);
    XCTAssertFalse([[self.controller valueForKey:@"syncButton"] isEnabled]);
    self.controller.ready = YES;
    [self.controller connectionStateChanged:nil];
    [self.controller syncRecords];
    oldCompletion(0, @[[self record:900 values:@[@358]]]);
    XCTAssertEqual(self.controller.records.count, 0u);
    XCTAssertTrue([[self.controller valueForKey:@"spinner"] isAnimating]);
    self.controller.pending(0, @[]);
    XCTAssertFalse([[self.controller valueForKey:@"spinner"] isAnimating]);
    XCTAssertTrue([[self.controller valueForKey:@"syncButton"] isEnabled]);
}
- (void)testSwitchDeviceDropsResultsAndDoesNotSyncWrongDevice {
    [self.controller syncRecords];
    self.controller.mockIdentifier = @"ring-b";
    [self.controller connectionStateChanged:nil];
    self.controller.pending(0, @[[self record:900 values:@[@358]]]);
    XCTAssertEqual(self.controller.records.count, 0u);
    [self.controller syncRecords];
    XCTAssertEqual(self.controller.requests, 1);
    XCTAssertFalse([[self.controller valueForKey:@"syncButton"] isEnabled]);
}
- (void)testHomeCapabilityGateAndCachedPageAreIndependentOfHealthData {
    DHBluetoothManager *bluetooth = [DHBluetoothManager shareInstance];
    DeviceFuncV2Model *saved = bluetooth.deviceFuncV2Model;
    @try {
        DeviceFuncV2Model *menu = [[DeviceFuncV2Model alloc] init];
        bluetooth.deviceFuncV2Model = menu;
        RWHealthHomeController *home = [[RWHealthHomeController alloc] init];
        [home loadViewIfNeeded];
        NSArray *items = [home valueForKey:@"healthItems"];
        XCTAssertFalse([[items valueForKey:@"id"] containsObject:@"actigraphy"]);
        menu.isSupportActigraphy = YES;
        [home rebuildHealthItems];
        items = [home valueForKey:@"healthItems"];
        NSArray *ids = [items valueForKey:@"id"];
        XCTAssertTrue([ids containsObject:@"step"]);
        NSUInteger index = [ids indexOfObject:@"actigraphy"];
        XCTAssertNotEqual(index, NSNotFound);
        NSIndexPath *path = [NSIndexPath indexPathForItem:index inSection:0];
        UICollectionView *collection = [home valueForKey:@"collectionView"];
        [home collectionView:collection didSelectItemAtIndexPath:path];
        RWActigraphyController *detail = [home valueForKey:@"actigraphyController"];
        [detail setValue:@[[self record:900 values:@[@358]]] forKey:@"records"];
        [[home valueForKey:@"healthValues"] removeAllObjects];
        [[home valueForKey:@"healthRecords"] removeAllObjects];
        [home collectionView:collection didSelectItemAtIndexPath:path];
        XCTAssertEqual(detail, [home valueForKey:@"actigraphyController"]);
        XCTAssertEqual(detail.records.count, 1u);
        UICollectionViewCell *cell = [home collectionView:collection cellForItemAtIndexPath:path];
        NSString *expected = [NSString stringWithFormat:NSLocalizedString(@"rw_actigraphy_groups", nil), 1UL];
        XCTAssertEqualObjects([[cell valueForKey:@"valueLabel"] text], expected);
        menu.isSupportActigraphy = NO;
        [home rebuildHealthItems];
        XCTAssertFalse([[[home valueForKey:@"healthItems"] valueForKey:@"id"] containsObject:@"actigraphy"]);
    } @finally {
        bluetooth.deviceFuncV2Model = saved;
    }
}
@end

@interface DHBleSDKDemoTests : XCTestCase

@end

@implementation DHBleSDKDemoTests

- (void)testScanAppearanceDisplaysSizeAndSupportsWrappingAndCellReuse {
    Class cellClass = NSClassFromString(@"RWScanDeviceCell");
    Class modelClass = NSClassFromString(@"RWScanDeviceCellModel");
    XCTAssertNotNil(cellClass);
    XCTAssertNotNil(modelClass);
    UITableViewCell *cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"size-test"];
    NSObject *model = [[modelClass alloc] init];
    [model setValue:@"Ring" forKey:@"leftTitle"];
    [model setValue:@"70" forKey:@"subTitle"];
    [model setValue:@"有屏戒指 · 银色 · 9号" forKey:@"deviceFormText"];
    [cell setValue:model forKey:@"model"];
    UILabel *label = [cell valueForKey:@"deviceFormLabel"];
    XCTAssertEqualObjects(label.text, @"有屏戒指 · 银色 · 9号");
    XCTAssertEqual(label.numberOfLines, 0);
    XCTAssertFalse(label.hidden);
    [model setValue:@"" forKey:@"deviceFormText"];
    [cell setValue:model forKey:@"model"];
    XCTAssertTrue(label.hidden);
    XCTAssertEqualObjects(label.text, @"");
}

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
