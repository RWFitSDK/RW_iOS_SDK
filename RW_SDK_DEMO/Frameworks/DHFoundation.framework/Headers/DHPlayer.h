//
//  DHPlayer.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHPlayer : NSObject

+ (instancetype)shareInstance;

/// 播放音频
/// @param audioArray 本地音频路径URL数组
- (void)playAudios:(NSArray <NSURL *>*)audioArray;

@end

NS_ASSUME_NONNULL_END
