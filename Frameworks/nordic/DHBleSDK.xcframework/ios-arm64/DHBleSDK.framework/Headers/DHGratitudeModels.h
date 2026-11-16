#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface DHGratitudeConfigModel : NSObject
@property (nonatomic, assign) NSUInteger countPerStar;
@property (nonatomic, assign) NSUInteger starsPerMoon;
@end

/// 轮次记录。时间均为Unix秒；尚未发生或时间未知时为0。
@interface DHGratitudeRoundModel : DHGratitudeConfigModel
@property (nonatomic, assign) UInt64 count;
@property (nonatomic, assign) NSUInteger stars;
@property (nonatomic, assign) BOOL moonReached;
@property (nonatomic, assign) BOOL rewarded;
@property (nonatomic, assign) int64_t startTime;
@property (nonatomic, assign) int64_t reachedTime;
@property (nonatomic, assign) int64_t rewardTime;
@end

@interface DHGratitudeVoiceSlotModel : NSObject
@property (nonatomic, assign) NSUInteger slot;
@property (nonatomic, assign) BOOL available;
@property (nonatomic, assign) NSUInteger durationMs;
@property (nonatomic, assign) UInt32 fileLength;
@property (nonatomic, assign) UInt16 fileCrc16;
@end

typedef void (^DHGratitudeCallback)(int code, id _Nullable data);
typedef void (^DHGratitudeVoiceProgress)(NSUInteger sentBytes, NSUInteger totalBytes);
NS_ASSUME_NONNULL_END
