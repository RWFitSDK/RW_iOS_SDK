//
//  BaseNavigationView.h
//  DHSFit
//
//  Created by DHS on 2022/5/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseNavigationView : UIView

@property (nonatomic, strong) UILabel *navTitleLabel;

@property (nonatomic, strong) UIButton *navLeftButton;

@property (nonatomic, strong) UIButton *navRightButton;

@end

NS_ASSUME_NONNULL_END
