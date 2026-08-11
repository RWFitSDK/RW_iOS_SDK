//
//  RWHealthDetailController.h
//  DHBleSDKDemo
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RWHealthDetailController : UITableViewController
- (instancetype)initWithTitle:(NSString *)title
                        lines:(nullable NSArray<NSString *> *)lines
              measurementType:(NSInteger)measurementType;
@end

NS_ASSUME_NONNULL_END
