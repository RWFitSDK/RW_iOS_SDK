//
//  BaseCellModel.h
//  DHSFit
//
//  Created by DHS on 2022/5/31.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseCellModel : NSObject

@property (nonatomic, copy) NSString *leftTitle;

@property (nonatomic, copy) NSString *subTitle;

@property (nonatomic, copy) NSString *contentTitle;

@property (nonatomic, copy) NSString *rightImage;

@property (nonatomic, assign) NSInteger switchViewTag;

@property (nonatomic, assign) BOOL isOpen;

@property (nonatomic, assign) BOOL isHideSwitch;

@property (nonatomic, assign) BOOL isHideArrow;

@end

NS_ASSUME_NONNULL_END
