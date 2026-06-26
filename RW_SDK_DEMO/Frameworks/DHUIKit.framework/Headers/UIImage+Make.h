//
//  UIImage+Make.h
//  XUIkit
//
//  Created by hedongyang on 2018/7/17.
//  Copyright © 2018年 hedongyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Make)

/**
 截取当前image对象rect区域内的图像

 @param rect 截取区域
 @return 图片
 */
- (UIImage *)subImageWithRect:(CGRect)rect;

/// 压缩图片
/// @param maxSize 图片允许的最大kB，这个只是作为参考，已实际为准
- (NSData *)reSizeImageMaxSizeWithKB:(int)maxSize;

/// 根据大小改变图片size
- (UIImage *)imageByScalingToSize:(CGSize)targetSize;

/// 处理拍照之后图片旋转90度问题
- (UIImage *)imageWithRightOrientation;

@end
