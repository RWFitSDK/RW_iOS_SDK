//
//  BaseNavigationView.m
//  DHSFit
//
//  Created by DHS on 2022/5/30.
//

#import "BaseNavigationView.h"

@implementation BaseNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = HomeColor_BackgroundColor;
    [self.navLeftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.bottom.offset(0);
        make.height.width.offset(44);
    }];
    
    [self.navRightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(0);
        make.bottom.offset(0);
        make.height.width.offset(44);
    }];
    
    [self.navTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.navLeftButton.mas_right);
        make.right.equalTo(self.navRightButton.mas_left);
        make.bottom.offset(0);
        make.height.offset(44);
    }];
}

- (UIButton *)navLeftButton {
    if (!_navLeftButton) {
        _navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navLeftButton setImage:[UIImage imageNamed:@"public_nav_back"] forState:UIControlStateNormal];
        
        [self addSubview:_navLeftButton];
    }
    return _navLeftButton;
}

- (UIButton *)navRightButton {
    if (!_navRightButton) {
        _navRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_navRightButton setImage:[UIImage imageNamed:@"public_nav_confirm"] forState:UIControlStateNormal];
        [self addSubview:_navRightButton];
    }
    return _navRightButton;
}

- (UILabel *)navTitleLabel {
    if (!_navTitleLabel) {
        _navTitleLabel = [[UILabel alloc]init];
        _navTitleLabel.textColor = HomeColor_TitleColor;
        _navTitleLabel.font = HomeFont_TitleFont;
        _navTitleLabel.text = @"";
        _navTitleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_navTitleLabel];
    }
    return _navTitleLabel;
}

@end
