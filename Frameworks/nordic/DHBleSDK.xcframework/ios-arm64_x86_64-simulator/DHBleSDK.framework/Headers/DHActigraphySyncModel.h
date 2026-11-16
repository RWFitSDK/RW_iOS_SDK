#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHActigraphySyncModel : NSObject
/// 区间起点，Unix秒时间戳。
@property (nonatomic, assign) int64_t timestamp;
/// 有效项数，1～30。
@property (nonatomic, assign) NSUInteger validCount;
/// 体动值列表，每30秒一个值，仅包含有效项。
@property (nonatomic, copy) NSArray<NSNumber *> *activityCounts;
@end

NS_ASSUME_NONNULL_END
