#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DHPassthroughWriteType) {
    DHPassthroughWriteWithoutResponse,
    DHPassthroughWriteWithResponse,
};

@protocol DHPassthroughChannelListener <NSObject>
- (void)passthroughChannelDidBecomeReady:(NSInteger)channelId;
- (void)passthroughChannel:(NSInteger)channelId didReceiveData:(NSData *)data;
- (void)passthroughChannel:(NSInteger)channelId didBecomeUnavailable:(NSError *)error;
- (void)passthroughChannelDidDisconnect:(NSInteger)channelId;
@end

/// Raw BLE channels. Call on main; callbacks are also delivered on main.
/// 通用字节透传。调用与回调均在主线程；调用方持有 listener，结束使用时注销。
@interface DHPassthroughChannel : NSObject
/// Returns 0 for invalid UUID, reserved/occupied service, or a service awaiting reconnect.
/// 注册跨普通断连保留，重连且 RW 初始化成功后重新准备；就绪回调晚于本方法返回。
+ (NSInteger)registerPassthroughChannel:(NSString *)serviceUUID
                            notifyUUID:(NSString *)notifyUUID
                             writeUUID:(NSString *)writeUUID
                              listener:(id<DHPassthroughChannelListener>)listener;
/// WWR success means submitted to CoreBluetooth; WR success means ATT acknowledged.
/// 本次写入只回调一次，不代表第三方业务协议已执行成功。
+ (void)writePassthroughChannel:(NSInteger)channelId data:(NSData *)data
                          type:(DHPassthroughWriteType)type
                    completion:(nullable void (^)(BOOL submitted, NSError *_Nullable error))completion;
+ (void)unregisterPassthroughChannel:(NSInteger)channelId;
/// Current maximum WWR packet length, or 0 before ready.
+ (NSInteger)maximumWriteLengthForChannel:(NSInteger)channelId;
@end
NS_ASSUME_NONNULL_END
