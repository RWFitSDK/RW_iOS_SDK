//
//  NSURL+Simple.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (Simple)

/// URL参数转字典
- (NSDictionary *)Parameters;

/// 根据参数名 取参数值
/// @param parameterKey 参数名的key
- (NSString *)valueForParameter:(NSString *)parameterKey;

@end

NS_ASSUME_NONNULL_END
