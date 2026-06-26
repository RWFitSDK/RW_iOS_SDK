//
//  DHDailyStepModel.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHDailyStepModel : NSObject
 
/// 日期时间戳（秒）
@property (nonatomic, copy) NSString *timestamp;
/// 日期yyyyMMdd
@property (nonatomic, copy) NSString *date;

/// 里程（米）
@property (nonatomic, assign) NSInteger distance;
/// 消耗（卡路里）
@property (nonatomic, assign) NSInteger calorie;
/// 步数（步）
@property (nonatomic, assign) NSInteger step;

/// 计步项 例：@[@{@"index":@0,@"step":@100,@"calorie":@10000,@"distance":@50},...]
/// index（序号）step（步数）calorie（消耗） distance（里程）单位同上
/// index从0开始，固定24个item，对应一天24小时
@property (nonatomic,strong) NSMutableArray <NSDictionary *>*items;

@property (nonatomic, assign) BOOL isJLType;

@end

NS_ASSUME_NONNULL_END
