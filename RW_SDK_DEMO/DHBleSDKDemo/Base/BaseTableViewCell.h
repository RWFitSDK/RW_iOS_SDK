//
//  BaseTableViewCell.h
//  DHSFit
//
//  Created by DHS on 2022/5/31.
//

#import <UIKit/UIKit.h>
#import "BaseCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewCell : UITableViewCell

@property (nonatomic, strong) BaseCellModel *model;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) UILabel *leftTitleLabel;

@end

NS_ASSUME_NONNULL_END
