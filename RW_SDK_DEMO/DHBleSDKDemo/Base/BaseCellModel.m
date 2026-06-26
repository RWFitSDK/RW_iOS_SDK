//
//  BaseCellModel.m
//  DHSFit
//
//  Created by DHS on 2022/5/31.
//

#import "BaseCellModel.h"

@implementation BaseCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.leftTitle = @"";
        self.subTitle = @"";
        self.contentTitle = @"";
        self.rightImage = @"public_cell_arrow";
        self.switchViewTag = 0;
        self.isOpen = NO;
        self.isHideSwitch = YES;
        self.isHideArrow = NO;
    }
    return self;
}

@end
