//
//  DHFile.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHFile : NSObject

/// 沙河路径
+ (NSString *)documentPath;

/// 库路径
+ (NSString *)libraryPath;

/// 缓存路径
+ (NSString *)cachesPath;

/// 临时路径
+ (NSString *)tempPath;
/**
 通过路径分级创建文件夹
 
 @param path 所有目录路径
 @param error 错误信息
 @return yes or no
 */
+ (BOOL)createDirectoryWithPath:(NSString *)path
                          error:(NSError **)error;

/**
 保存本地图片
 
 @param image 图片image
 @param folderName 文件夹名
 @param fileName 文件名
 */
+ (BOOL)saveLocalImageWithImage:(UIImage *)image
                folderName:(NSString *)folderName
                  fileName:(NSString *)fileName;

/**
 获取本地图片
 @param folderName 文件夹名
 @param fileName 文件名
 */
+ (NSData *)queryLocalImageWithFolderName:(NSString *)folderName
                               fileName:(NSString *)fileName;

/**
 删除本地图片
 @param folderName 文件夹名
 @param fileName 文件名
 */
+ (void)removeLocalImageWithFolderName:(NSString *)folderName
                              fileName:(NSString *)fileName;


@end

NS_ASSUME_NONNULL_END
