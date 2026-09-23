//
//  DHProgressHUD.m
//  DHBleSDKDemo
//

#import "DHProgressHUD.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "UIColor+DHColor.h"

static const NSTimeInterval kDHProgressHUDAutoDismissInterval = 1.5;
static const NSTimeInterval kDHProgressHUDMaxDismissInterval = 12.0;

static UIView *dh_hudContainerView(void) {
    // 优先取前台场景的 keyWindow, 兼容 iOS 15+ 场景 API
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *window in windowScene.windows.reverseObjectEnumerator) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    return UIApplication.sharedApplication.delegate.window;
}

@implementation DHProgressHUD

+ (MBProgressHUD *)makeHUD {
    UIView *view = dh_hudContainerView();
    if (!view) {
        return nil;
    }
    // 复用未隐藏的 HUD, 避免叠加
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    if (!hud) {
        hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    // 原 SVProgressHUD 全局样式迁移: 圆角 10 / 灰底 0.9 / 黑字 / PingFang 16
    hud.bezelView.color = [UIColor dh_colorWithHexString:@"#CCCCCC" alpha:0.9];
    hud.contentColor = [UIColor dh_colorWithHexString:@"#000000"];
    hud.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
    hud.bezelView.layer.cornerRadius = 10;
    hud.removeFromSuperViewOnHide = YES;
    hud.completionBlock = nil;
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = nil;
    return hud;
}

+ (void)show {
    [self makeHUD];
}

+ (void)showStatus:(NSString *)status {
    MBProgressHUD *hud = [self makeHUD];
    hud.label.text = status;
}

+ (void)showText:(NSString *)text {
    MBProgressHUD *hud = [self makeHUD];
    if (!hud) {
        return;
    }
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    [hud hideAnimated:YES afterDelay:kDHProgressHUDAutoDismissInterval];
}

+ (void)dismiss {
    UIView *view = dh_hudContainerView();
    if (!view) {
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD HUDForView:view];
    // 最长展示 12s 兜底由调用方场景保证, 这里立即隐藏
    [hud hideAnimated:YES];
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
