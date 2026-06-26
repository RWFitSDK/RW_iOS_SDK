//
//  WorkoutRunningController.h
//  DHBleSDKDemo
//
//  Created by DHS on 2026/1/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorkoutRunningController : UIViewController
@property (nonatomic, assign) BleActivityMode bleActivityMode;
@property (nonatomic, assign) WorkoutControlType controllType; //0x01开始 0x03暂停 0x02继续 0x04结束
@end

NS_ASSUME_NONNULL_END
