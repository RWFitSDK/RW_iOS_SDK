//
//  BaseViewController.h
//  DHSFit
//
//  Created by DHS on 2022/5/30.
//

#import <UIKit/UIKit.h>
#import "BaseNavigationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

@property (nonatomic, copy) NSString *navTitle;

@property (nonatomic, copy) NSString *navRightImage;

@property (nonatomic, copy) NSString *navLeftImage;

@property (nonatomic, assign) BOOL isHideNavigationView;

@property (nonatomic, assign) BOOL isHideNavRightButton;

@property (nonatomic, assign) BOOL isHideNavLeftButton;

@property (nonatomic, strong) BaseNavigationView *navigationView;

- (void)navLeftButtonClick:(UIButton *)sender;

- (void)navRightButtonClick:(UIButton *)sender;

- (NSString *)modelDescriptionWithIndent:(NSInteger)level Object:(id)object;

@end

NS_ASSUME_NONNULL_END
