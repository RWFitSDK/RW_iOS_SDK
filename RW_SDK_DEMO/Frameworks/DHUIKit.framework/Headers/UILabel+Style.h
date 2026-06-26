//
//  UILabel+Style.h
//  XUIkit
//
//  Created by xiongze on 2018/8/28.
//  Copyright © 2018年 hedongyang. All rights reserved.
//  项目label类型富文本扩展

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UILabel (Style)

/**
 指定文本、高度、字体，返回Label宽度

 @param text 指定文本
 @param height 指定高度
 @param font 指定字体
 @return 返回Label宽度
 */
+ (CGFloat)getLabelWidth:(NSString*)text
                  height:(CGFloat)height
                    font:(UIFont*)font;

/**
 指定文本、宽度、字体，返回Label高度

 @param text 指定文本
 @param width 指定宽度
 @param font 指定字体
 @return 返回Label高度
 */
+ (CGFloat)getLabelheight:(NSString*)text
                    width:(CGFloat)width
                     font:(UIFont*)font;

/**
 富文本转换方法
 
 @param strArray 字符数组
 @param fontArray 字体大小数组
 @param colorArray 字体颜色数组
 @return 返回富文本
 */
+ (NSMutableAttributedString*) getAttributedStrings:(NSArray *) strArray
                                              fonts:(NSArray *) fontArray
                                             colors:(NSArray *) colorArray;

/**
 富文本转换方法    ，如需剧中，需要再次设置label.textAlignment = NSTextAlignmentCenter;
 
 @param strArray 字符数组
 @param fontArray 字体大小数组
 @param colorArray 字体颜色数组
 @param space 行距
 @return 返回富文本
 */
+ (NSMutableAttributedString*) getAttributedStrings:(NSArray *) strArray
                                              fonts:(NSArray *) fontArray
                                             colors:(NSArray *) colorArray
                                              space:(CGFloat)space;

@end
