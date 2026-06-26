//
//  BaseViewController.m
//  DHSFit
//
//  Created by DHS on 2022/5/30.
//

#import "BaseViewController.h"
#import <objc/runtime.h>

@implementation BaseViewController

#pragma mark - vc lift cycle 生命周期

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController.interactivePopGestureRecognizer setEnabled:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = HomeColor_BackgroundColor;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    [self setupNavigationView];
}

#pragma mark - custom action for UI 界面处理有关

- (void)navLeftButtonClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightButtonClick:(UIButton *)sender {
    
}


- (void)setupNavigationView {
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.offset(0);
        make.height.offset(kNavAndStatusHeight);
    }];
    self.navigationView.hidden = self.isHideNavigationView;
    
    if (!self.isHideNavigationView) {
        [self.navigationView.navLeftButton addTarget:self action:@selector(navLeftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationView.navRightButton addTarget:self action:@selector(navRightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationView.navTitleLabel.text = self.navTitle;
        self.navigationView.navRightButton.hidden = self.isHideNavRightButton;
        self.navigationView.navLeftButton.hidden = self.isHideNavLeftButton;
        
        if (self.navRightImage) {
            [self.navigationView.navRightButton setImage:[UIImage imageNamed:self.navRightImage] forState:UIControlStateNormal];
        }
        if (self.navLeftImage) {
            [self.navigationView.navLeftButton setImage:[UIImage imageNamed:self.navLeftImage] forState:UIControlStateNormal];
        }
    }
}

- (NSString *)modelDescriptionWithIndent:(NSInteger)level Object:(id)object{
    uint count;
    objc_property_t *properties = class_copyPropertyList([object class], &count);
    NSMutableString *mStr = [NSMutableString string];
    NSMutableString *tab = [NSMutableString stringWithString:@""];
    for (int index = 0; index < level; index ++) {
        [tab appendString:@"\t"];
    }
    [mStr appendString:@"{\n"];
    for (int index = 0; index < count; index ++) {
        NSString *lastSymbol = index + 1 == count ? @"" : @";";
        objc_property_t property = properties[index];
        NSString *name = @(property_getName(property));
        id value = [object valueForKey:name];
        [mStr appendFormat:@"\t%@%@ = %@%@\n",
         tab,
         name,
         value,
         lastSymbol];
    }
    [mStr appendFormat:@"%@}",tab];
    free(properties);
    return [NSString stringWithFormat:@"<%@ : %p> %@",
            NSStringFromClass([object class]),
            object,
            mStr];
}


#pragma mark - get and set 属性的set和get方法

- (BaseNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[BaseNavigationView alloc] init];
        [self.view addSubview:_navigationView];
    }
    return _navigationView;
}

@end
