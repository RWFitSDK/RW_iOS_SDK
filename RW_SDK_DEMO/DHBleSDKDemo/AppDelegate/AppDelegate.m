//
//  AppDelegate.m
//  DHBleSDKDemo
//
//  Created by DHS on 2022/6/23.
//

#import "AppDelegate.h"
#import "ScanViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:2.0];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [self initBleSDK];
    
    ScanViewController *vc = [[ScanViewController alloc] init];
    vc.navTitle = @"搜索设备";
    vc.navRightImage = @"public_nav_refresh";
    vc.isHideNavLeftButton = YES;
    UINavigationController *scanVC = [[UINavigationController alloc] initWithRootViewController:vc];
    [self.window setRootViewController:scanVC];
    
    [self registerHUD];
    
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window{
    return UIInterfaceOrientationMaskPortrait;//默认全局不支持横屏
}

-(void)registerHUD{
    [SVProgressHUD setDefaultMaskType:(SVProgressHUDMaskTypeClear)];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setErrorImage:[UIImage imageNamed:@"nil"]];
    [SVProgressHUD setSuccessImage:[UIImage imageNamed:@"nil"]];
    [SVProgressHUD setInfoImage:[UIImage imageNamed:@"nil"]];
    [SVProgressHUD setCornerRadius:10];
    [SVProgressHUD setBackgroundColor:COLORANDALPHA(@"#CCCCCC", 0.9)];
    [SVProgressHUD setForegroundColor:HomeColor_TitleColor];
    [SVProgressHUD setFont:HomeFont_TitleFont];
    [SVProgressHUD setMinimumDismissTimeInterval:1.5];
    [SVProgressHUD setMaximumDismissTimeInterval:12.0];

}

- (void)initBleSDK{
    [DHBleCentralManager setLogStatus:YES];
    [DHBleCentralManager initWithServiceUuids:@[]];
    
    //Demo里工具类初始化,可选择;
    [DHBluetoothManager shareInstance];
}

@end
