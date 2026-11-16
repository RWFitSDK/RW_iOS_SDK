//
//  DHFirmwareVersionModel.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHFirmwareVersionModel : NSObject

/// 固件版本 例：1.0.0
@property (nonatomic, copy) NSString *firmwareVersion;
/// 设备型号 例：DW01
@property (nonatomic, copy) NSString *deviceModel;

@property (nonatomic, copy) NSString *uiVersion; //UI版本号
/// 产品形态：0无屏戒指、1有屏戒指、2无屏手链、3有屏手链、4无屏手环、5有屏手环、6手表；-1未提供或不支持。
/// Product form: 0/1 ring, 2/3 bracelet, 4/5 wristband (without/with a screen), 6 watch; -1 unavailable or unsupported.
@property (nonatomic, assign) NSInteger deviceForm;
/// 设备外观颜色：0未设置、1黑色、2粉色、3红色、4银色、5金色；-1未提供或不支持。
/// Device body color: 0 not set, 1 black, 2 pink, 3 red, 4 silver, 5 gold; -1 unavailable or unsupported.
@property (nonatomic, assign) NSInteger deviceBodyColor;
/// 尺寸号，0未设置，-1未提供或不支持。Size number; 0 not set, -1 unavailable.
@property (nonatomic, assign) NSInteger deviceSize;
/// 客户型号；未提供时与原设备型号一致。Customer model; defaults to the original device model when unavailable.
@property (nonatomic, copy) NSString *customerModel;


@end

NS_ASSUME_NONNULL_END
