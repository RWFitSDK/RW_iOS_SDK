//
//  BaseTableViewCell.m
//  DHSFit
//
//  Created by DHS on 2022/5/31.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *subTitleLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UIImageView *rightImageView;

@end

@implementation BaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setModel:(BaseCellModel *)model {
    self.leftTitleLabel.text = model.leftTitle;
    self.subTitleLabel.text = model.subTitle;
    self.contentLabel.text = model.contentTitle;
    
    if (model.rightImage.length) {
        self.rightImageView.image = [UIImage imageNamed:model.rightImage];
    } else {
        self.rightImageView.image = [[UIImage alloc] init];
    }
    if (!model.isHideSwitch) {
        self.switchView.on = model.isOpen;
    }
    if (model.contentTitle.length) {
        [self.leftTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bgView).offset(-15);
        }];
    }
    
    self.switchView.hidden = model.isHideSwitch;
    self.rightImageView.hidden = model.isHideArrow;
}

- (void)setupSubViews {
    self.contentView.backgroundColor = HomeColor_BackgroundColor;
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(0);
        make.left.offset(15);
        make.right.offset(-15);
        make.bottom.offset(-10);
    }];
    
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(12);
        make.right.offset(-10);
        make.centerY.equalTo(self.bgView);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.right.equalTo(self.rightImageView.mas_left).offset(-10);
        make.width.offset(80);
    }];

    [self.leftTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgView);
        make.left.offset(15);
        make.right.equalTo(self.subTitleLabel.mas_left).offset(-5);
    }];
    
    [self.contentLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(15);
        make.top.equalTo(self.leftTitleLabel.mas_bottom).offset(10);
        make.width.equalTo(self.leftTitleLabel);
    }];

    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.offset(-10);
        make.centerY.equalTo(self.bgView);
    }];
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = HomeColor_BlockColor;
        _bgView.layer.cornerRadius = 10;
        _bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:_bgView];
    }
    return _bgView;
}

- (UILabel *)leftTitleLabel {
    if (!_leftTitleLabel) {
        _leftTitleLabel = [[UILabel alloc]init];
        _leftTitleLabel.textColor = HomeColor_TitleColor;
        _leftTitleLabel.font = HomeFont_TitleFont;
        _leftTitleLabel.numberOfLines = 2;
        [self.bgView addSubview:_leftTitleLabel];
    }
    return _leftTitleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [[UILabel alloc]init];
        _subTitleLabel.textColor = HomeColor_SubTitleColor;
        _subTitleLabel.font = HomeFont_SubTitleFont;
        _subTitleLabel.numberOfLines = 2;
        _subTitleLabel.textAlignment = NSTextAlignmentRight;
        [self.bgView addSubview:_subTitleLabel];
    }
    return _subTitleLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc]init];
        _contentLabel.textColor = HomeColor_SubTitleColor;
        _contentLabel.font = HomeFont_SubTitleFont;
        _contentLabel.numberOfLines = 2;
        [self.bgView addSubview:_contentLabel];
    }
    return _contentLabel;
}

- (UIImageView *)rightImageView {
    if (!_rightImageView) {
        _rightImageView = [[UIImageView alloc] init];
        _rightImageView.contentMode = UIViewContentModeRight;
        [self.bgView addSubview:_rightImageView];
    }
    return _rightImageView;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = HomeColor_MainColor;
        [self.bgView addSubview:_switchView];
    }
    return _switchView;
}

@end
