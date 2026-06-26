//
//  DHNetworkFunc.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHNetworkFunc : NSObject

@property (nonatomic, copy) NSString *baseURL;

+ (DHNetworkFunc *)shareInstance;

// POST请求
- (void)post:(NSString *)url andHeader:(NSDictionary *)header andParam:(id)param andBlock:(void (^)(NSInteger resultCode,NSString *message, id data))block;

// POST JSON请求
- (void)postJson:(NSString *)url andHeader:(NSDictionary *)header andParam:(id)param andBlock:(void (^)(NSInteger resultCode,NSString *message, id data))block;

// GET请求
- (void)get:(NSString *)url andHeader:(NSDictionary *)header andParam:(id)param andBlock:(void (^)(NSInteger resultCode,NSString *message, id data))block;

// 上传文件
- (void)uploadFile:(NSString *)url andHeader:(NSDictionary *)header andParam:(id)param andData:(NSData *)fileData andBlock:(void(^)(NSInteger resultCode,NSString *message,id data))block;

//下载文件
- (void)downloadFileWithParameter:(NSDictionary *)parameter progress:(nullable void (^)(NSProgress * _Nonnull))progress andBlock:(void(^)(NSInteger resultCode,NSString *message, id data))block;

@end

NS_ASSUME_NONNULL_END
