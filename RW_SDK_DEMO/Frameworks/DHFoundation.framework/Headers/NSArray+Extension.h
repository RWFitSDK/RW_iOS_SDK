//
//  NSArray+Extension.h
//  XFoundation
//
//  Created by Z on 2020/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (Extension)


/// 数组转字符串
/// @param isClear 是否删除多余字符？ 如： 【   、】、“ 和kongge
- (NSString *)toStringAndIsClear:(BOOL)isClear;


@end

NS_ASSUME_NONNULL_END
