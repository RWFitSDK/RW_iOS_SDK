#import <UIKit/UIKit.h>
#import <DHBleSDK/DHActigraphySyncModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface RWActigraphyController : UITableViewController
@property (nonatomic, copy, readonly) NSArray<DHActigraphySyncModel *> *records;
@property (nonatomic, copy, nullable) void(^onRecordsUpdated)(NSArray<DHActigraphySyncModel *> *records);
@end

NS_ASSUME_NONNULL_END
