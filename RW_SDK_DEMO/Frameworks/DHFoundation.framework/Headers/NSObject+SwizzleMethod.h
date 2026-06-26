//
//  NSObject+SwizzleMethod.h
//  VeryFitPlus
//
//  Created by xiongze on 2018/4/29.
//  Copyright © 2018年 aiju_huangjing1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (SwizzleMethod)

/// 对系统方法进行替换(交换实例方法)
/// @param systemSelector 被替换的方法
/// @param swizzledSelector 实际使用的方法
/// @param error 替换过程中出现的错误消息
+ (BOOL)systemSelector:(SEL)systemSelector swizzledSelector:(SEL)swizzledSelector error:(NSError *)error;

/// 对系统方法进行替换(交换实例方法)
/// @param origSelector 旧方法
/// @param newSelector 新方法
/// @param targetClass 所在类
+ (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector withClass:(Class)targetClass;

@end
