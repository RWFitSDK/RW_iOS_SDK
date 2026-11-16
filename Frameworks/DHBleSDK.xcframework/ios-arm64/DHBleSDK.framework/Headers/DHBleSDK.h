//
//  DHBleSDK.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>


#pragma mark - Manager
#import <DHBleSDK/DHBleCentralManager.h>
#import <DHBleSDK/DHBleCommand.h>
#import <DHBleSDK/DHGratitudeModels.h>
// 发布脚本只为TXY产物保留此头文件；客户无需自行配置渠道宏。
#if __has_include(<DHBleSDK/TxyBleSdk.h>)
#import <DHBleSDK/TxyBleSdk.h>
#endif
#if __has_include(<DHBleSDK/TxyAudioTool.h>)
#import <DHBleSDK/TxyAudioTool.h>
#endif

#pragma mark - Transport（通用字节透传通道）
#import <DHBleSDK/DHPassthroughChannel.h>

//! Project version number for DHBleSDK.
FOUNDATION_EXPORT double DHBleSDKVersionNumber;

//! Project version string for DHBleSDK.
FOUNDATION_EXPORT const unsigned char DHBleSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <DHBleSDK/PublicHeader.h>
