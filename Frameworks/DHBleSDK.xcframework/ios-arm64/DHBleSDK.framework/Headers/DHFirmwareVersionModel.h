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


@end

NS_ASSUME_NONNULL_END
