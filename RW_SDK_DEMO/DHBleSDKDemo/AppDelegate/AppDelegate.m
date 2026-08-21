//
//  AppDelegate.m
//  DHBleSDKDemo
//
//  Created by DHS on 2022/6/23.
//

#import "AppDelegate.h"
#import "NewHomeController.h"
#import "RWHealthHomeController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [NSThread sleepForTimeInterval:2.0];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }

    [self initBleSDK];

    [self.window setRootViewController:[self buildRootViewController]];
    [self.window makeKeyAndVisible];

    [self registerHUD];

    return YES;
}

- (UIViewController *)buildRootViewController
{
    RWHealthHomeController *homeController = [[RWHealthHomeController alloc] init];
    UINavigationController *homeNavigation = [[UINavigationController alloc] initWithRootViewController:homeController];
    [self configureNavigationController:homeNavigation];
    homeNavigation.tabBarItem.title = NSLocalizedString(@"rw_tab_home", nil);

    NewHomeController *deviceController = [[NewHomeController alloc] init];
    UINavigationController *deviceNavigation = [[UINavigationController alloc] initWithRootViewController:deviceController];
    [self configureNavigationController:deviceNavigation];
    deviceNavigation.tabBarItem.title = NSLocalizedString(@"rw_tab_device", nil);

    if (@available(iOS 13.0, *)) {
        homeNavigation.tabBarItem.image = [UIImage systemImageNamed:@"heart.text.square"];
        deviceNavigation.tabBarItem.image = [UIImage systemImageNamed:@"circle.grid.2x2"];
    }

    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[homeNavigation, deviceNavigation];
    tabBarController.tabBar.tintColor = COLOR(@"#3568D4");
    tabBarController.tabBar.backgroundColor = UIColor.whiteColor;
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = UIColor.whiteColor;
        tabBarController.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            tabBarController.tabBar.scrollEdgeAppearance = appearance;
        }
    }
    return tabBarController;
}

- (void)configureNavigationController:(UINavigationController *)navigationController
{
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.barTintColor = UIColor.whiteColor;
    navigationController.navigationBar.tintColor = COLOR(@"#3568D4");
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: COLOR(@"#172033")};
    if (@available(iOS 11.0, *)) {
        navigationController.navigationBar.prefersLargeTitles = NO;
    }
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = UIColor.whiteColor;
        appearance.shadowColor = UIColor.clearColor;
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: COLOR(@"#172033")};
        navigationController.navigationBar.standardAppearance = appearance;
        navigationController.navigationBar.compactAppearance = appearance;
        navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
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
    //可在任意连接发生前提前设置；Demo使用1234测试设备密码认证。
    [DHBleCommand prepareAutoPassword:@"1234"];
    //Demo里工具类初始化,可选择;
    [DHBluetoothManager shareInstance];
    [DHBleCentralManager initWithServiceUuids:@[]];

//    [DHBleCommand preparePasswordReset:@"2345"];
}

@end
