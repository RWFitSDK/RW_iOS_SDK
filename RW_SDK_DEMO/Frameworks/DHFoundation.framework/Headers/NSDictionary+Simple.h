//
//  NSDictionary+Simple.h
//  XFoundation
//
//  Created by Z on 2020/10/12.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (Simple)

/// 字典转json字符串
- (NSString *)transToJsonString;

/// 用@""替换字典里的null
- (NSMutableDictionary *)replaceNullValueWithSpace;

- (NSString*)x_stringForKey:(id)key;

- (NSNumber*)x_numberForKey:(id)key;

- (NSDecimalNumber *)x_decimalNumberForKey:(id)key;

- (NSArray*)x_arrayForKey:(id)key;

- (NSDictionary*)x_dictionaryForKey:(id)key;

- (NSInteger)x_integerForKey:(id)key;

- (NSUInteger)x_unsignedIntegerForKey:(id)key;

- (BOOL)x_boolForKey:(id)key;

- (int16_t)x_int16ForKey:(id)key;

- (int32_t)x_int32ForKey:(id)key;

- (int64_t)x_int64ForKey:(id)key;

- (char)x_charForKey:(id)key;

- (short)x_shortForKey:(id)key;

- (float)x_floatForKey:(id)key;

- (double)x_doubleForKey:(id)key;

- (long long)x_longLongForKey:(id)key;

- (unsigned long long)x_unsignedLongLongForKey:(id)key;

- (NSDate *)x_dateForKey:(id)key dateFormat:(NSString *)dateFormat;

//CG
- (CGFloat)x_CGFloatForKey:(id)key;

- (CGPoint)x_pointForKey:(id)key;

- (CGSize)x_sizeForKey:(id)key;

- (CGRect)x_rectForKey:(id)key;


@end

NS_ASSUME_NONNULL_END
