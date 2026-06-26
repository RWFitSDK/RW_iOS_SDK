//
//  NSArray+Simple.h
//  XFoundation
//
//  Created by xiongze on 2018/7/26.
//  Copyright © 2018年 hedongyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSArray (Simple)

/// 数组转json字符串
- (NSString *)transToJsonString;

-(id)x_objectWithIndex:(NSUInteger)index;

- (NSString*)x_stringWithIndex:(NSUInteger)index;

- (NSNumber*)x_numberWithIndex:(NSUInteger)index;

- (NSDecimalNumber *)x_decimalNumberWithIndex:(NSUInteger)index;

- (NSArray*)x_arrayWithIndex:(NSUInteger)index;

- (NSDictionary*)x_dictionaryWithIndex:(NSUInteger)index;

- (NSInteger)x_integerWithIndex:(NSUInteger)index;

- (NSUInteger)x_unsignedIntegerWithIndex:(NSUInteger)index;

- (BOOL)x_boolWithIndex:(NSUInteger)index;

- (int16_t)x_int16WithIndex:(NSUInteger)index;

- (int32_t)x_int32WithIndex:(NSUInteger)index;

- (int64_t)x_int64WithIndex:(NSUInteger)index;

- (char)x_charWithIndex:(NSUInteger)index;

- (short)x_shortWithIndex:(NSUInteger)index;

- (float)x_floatWithIndex:(NSUInteger)index;

- (double)x_doubleWithIndex:(NSUInteger)index;

- (NSDate *)x_dateWithIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;

//CG
- (CGFloat)x_CGFloatWithIndex:(NSUInteger)index;

- (CGPoint)x_pointWithIndex:(NSUInteger)index;

- (CGSize)x_sizeWithIndex:(NSUInteger)index;

- (CGRect)x_rectWithIndex:(NSUInteger)index;

@end
