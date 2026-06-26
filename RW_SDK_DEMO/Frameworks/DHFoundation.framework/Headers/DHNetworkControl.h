//
//  DHNetworkControl.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHNetworkControl : NSObject

/// 获取当前网络名称    据说苹果5G名称获取异常
+ (NSString *)getNetworkName;

/// 判断有无网络
+(BOOL)networkReachabilityStatus;

#pragma mark 登录注册接口

/// 用户注册
/// @param param 参数 {@"account" : @"test@163.com",@"password" : @"ab123456",@"verifyCode":@"1234" }
/// @param header 头部
/// @param block 回调
+ (void)registerWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 用户登录
/// @param param 参数 {@"username" : @"test@163.com",@"password" : @"ab123456" }
/// @param header 头部
/// @param block 回调
+ (void)loginWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 第三方登录
/// @param param 参数 {@"type" : @"1",@"openId" : @"xxx" } 备注type 0其他，1微信，2facebook，3google，4apple
/// @param header 头部
/// @param block 回调
+ (void)thirdLoginWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

#pragma mark 用户接口

/// 发送邮箱验证码
/// @param param 参数  {@"account" : @"test@163.com",@"verifyCodeType" : @"1" } 备注verifyCodeType: 0注册，1找回密码，2绑定账号，3注销账户
/// @param header 头部
/// @param block 回调
+ (void)sendEmailCodeWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 找回密码
/// @param param 参数 {@"account" : @"test@163.com",@"password" : @"ab123456",@"verifyCode" : @"1234" }
/// @param header 头部
/// @param block 回调
+ (void)resetPasswordWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 更改密码
/// @param param 参数 {@"oldPassword" : @"xx" ,@"newPassword" : @"xx" }
/// @param header 头部
/// @param block 回调
+ (void)updatePasswordWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 更新用户信息
/// @param param 参数 {@"portraitUrl" : @"http://xxx.png",@"name" : @"xx",@"sex" : @"xx",@"birthday" : @"xx",@"height" : @"xx",@"weight" : @"xx" }
/// @param header 头部
/// @param block 回调
+ (void)updateUserInformWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询用户信息
/// @param param 参数 nil
/// @param header 头部
/// @param block 回调
+ (void)queryUserInformWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(nullable void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 保存数据同步配置
/// @param param 参数 {@"dataSyncUser" : @"Y" ,@"dataSyncSport" : @"Y",@"dataSyncHealth" : @"Y" }
/// @param header 头部
/// @param block 回调
+ (void)saveSwitchWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询数据同步配置
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)querySwitchWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(nullable void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 退出登录
/// @param param 参数 nil
/// @param header 头部
/// @param block 回调
+ (void)signoutWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 注销用户
/// @param param 参数 {@"password" : @"xx" ,@"verifyCode" : @"666666" }
/// @param header 头部
/// @param block 回调
+ (void)deleteAccountWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询APP版本
/// @param param 参数 {@"type" : @"1"}
/// @param header 头部
/// @param block 回调
+ (void)queryAppVersionWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 第三方绑定
/// @param param 参数 {@"account":@"xx",@"password":@"xx",@"verifyCode" : @"xxx" }
/// @param header 头部
/// @param block 回调
+ (void)thirdLoginBindWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 意见反馈
/// @param param 参数 {@"desc" : @"xx" ,@"pictureUrls" : @"xx,xx" ,@"logUrls" : @"xx,xx" ,@"contact" : @"xx"  }
/// @param header 头部
/// @param block 回调
+ (void)feedbackWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

#pragma mark 设备模块

/// 查询固件版本
/// @param param 参数 {@"deviceId" : @"xx" ,@"currentVersion" : @"xx" }
/// @param header 头部
/// @param block 回调
+ (void)queryFirmwareVersionWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询天气数据
/// @param param 参数 {@"lon" : @"xx"  ,@"lat" : @"xx" }
/// @param header 头部
/// @param block 回调
+ (void)queryWeatherWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询设备首页推荐表盘
/// @param param 参数 {@"deviceNo" : @"xx"  }
/// @param header 头部
/// @param block 回调
+ (void)queryMainRecommendDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询推荐表盘 {@"deviceNo" : @"xx"  }
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)queryRecommendDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询所有表盘
/// @param param 参数 {@"classify" : @"2"  ,@"pageIndex" : @"1" ,@"pageSize" : @"10" ,@"deviceNo" : @"xx" } classify说明：-1:所有,1:首页推荐，2，热门推荐，3:最新推荐
/// @param header 头部
/// @param block 回调
+ (void)queryAllDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询已安装表盘
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)queryInstalledDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 查询自定义表盘
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)queryCustomDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 保存表盘
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)saveDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 删除表盘
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)deleteDialWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 设备激活
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)activatingDeviceWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

#pragma mark 文件上传

/// 文件上传
/// @param fileData 文件
/// @param header 头部
/// @param block 回调
+ (void)uploadFile:(NSData *)fileData andHeader:(NSDictionary *)header andParam:(NSDictionary *)param andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

#pragma mark 文件下载

/// 文件下载
/// @param parameter 参数
/// @param progress 进度回调
/// @param block 回调
+ (void)downloadFileWithParameter:(NSDictionary *)parameter progress:(nullable void (^)(NSProgress * _Nonnull))progress andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

#pragma mark 数据相关

/// 清除数据
/// @param param 参数 nil
/// @param header 头部
/// @param block 回调
+ (void)clearDataWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 删除运动数据
/// @param param 参数 {@"timestamp" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)deleteSportDataWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 步数数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadStepWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 睡眠数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadSleepWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 心率数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadHeartRateWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 血压数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadBpWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 血氧数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadBoWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 呼吸训练数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadBreathWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 体温数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadTempWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 运动数据上传
/// @param param 参数
/// @param header 头部
/// @param block 回调
+ (void)uploadSportWithParam:(NSArray *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 步数数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadStepWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 睡眠数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadSleepWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 心率数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadHeartRateWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 血压数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadBpWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 血氧数据上传
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadBoWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 呼吸训练数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadBreathWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 体温数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadTempWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

/// 运动数据下载
/// @param param 参数 {@"startDate" : @"x" ,@"endDate" : @"x" }
/// @param header 头部
/// @param block 回调
+ (void)downloadSportWithParam:(NSDictionary *)param andHeader:(NSDictionary *)header andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;


@end

NS_ASSUME_NONNULL_END
