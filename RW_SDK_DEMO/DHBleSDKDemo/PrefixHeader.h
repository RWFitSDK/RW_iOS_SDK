//
//  PrefixHeader.h
//  DHBleSDKDemo
//
//  Created by DHS on 2022/6/24.
//

#ifndef PrefixHeader_h
#define PrefixHeader_h

#import <DHFoundation/DHFoundation.h>
#import <DHUIKit/DHUIKit.h>
#import <DHBleSDK/DHBleSDK.h>

#import "DHBluetoothManager.h"
#import "BaseTableViewCell.h"

#define COLOR(HEXSTR) [DHUIHelp colorWithHexString:HEXSTR]
#define HEXColor(_hex_)  [DHUIHelp colorWithHexString:((__bridge NSString *)CFSTR(#_hex_))]
#define COLORANDALPHA(HEXSTR, ALPHA) [DHUIHelp colorWithHexString:HEXSTR alpha:ALPHA]

#define HomeColor_BackgroundColor COLOR(@"#EEEEEE")
#define HomeColor_BlockColor COLOR(@"#FFFFFF")
#define HomeColor_MainColor COLOR(@"#FFD700")

#define HomeColor_TitleColor COLOR(@"#000000")
#define HomeColor_SubTitleColor COLOR(@"#666666")
#define HomeColor_ContentColor COLOR(@"#000000")
#define HomeColor_ButtonColor COLOR(@"#FFFFFF")

#define HomeFont_TitleFont [UIFont fontWithName:@"PingFangSC-Regular" size:16]
#define HomeFont_SubTitleFont [UIFont fontWithName:@"PingFangSC-Regular" size:12]
#define HomeFont_ContentFont [UIFont fontWithName:@"PingFangSC-Regular" size:14]
#define HomeFont_ButtonFont [UIFont fontWithName:@"PingFangSC-Medium" size:16]

#define HomeColor_LineColor COLOR(@"#C0C0C0")

//获取当前屏幕是2x还是3x
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenScale [UIScreen mainScreen].scale

//获取导航栏、状态栏、tabbar的高度

#define kStatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height

#define kNavigationHeight 44.0

#define kNavAndStatusHeight (kStatusHeight+kNavigationHeight)

#define kTabBarHeight 49.0

#define X_IS_iPhoneX        kStatusHeight > 20              // 判断是否是刘海屏系列

#define kBottomHeight       (X_IS_iPhoneX ? 34.0f : 0.0f)   // 底部安全区域

#define WEAKSELF __weak typeof(self) weakSelf = self;

//配置吐司
#define SHOWINDETERMINATE [SVProgressHUD show];
#define SHOWHUD(s) [SVProgressHUD showImage:[UIImage imageNamed:@"nil"] status:s];
#define SHOWHUDNODISS(s) [SVProgressHUD showWithStatus:s];
#define HUDDISS [SVProgressHUD dismiss];




//设备连接状态变化
#define BluetoothNotificationConnectStateChange @"BluetoothNotificationConnectStateChange"
//设备已认证登陆OK
#define BluetoothNotificationConnectLoginOKChange @"BluetoothNotificationConnectLoginOKChange"

//同步数据进度
#define BluetoothNotificationDataSyncing @"BluetoothNotificationDataSyncing"
//同步表盘进度
#define BluetoothNotificationDialSyncing @"BluetoothNotificationDialSyncing"
//同步文件进度
#define BluetoothNotificationFileSyncing @"BluetoothNotificationFileSyncing"


#endif /* PrefixHeader_h */
