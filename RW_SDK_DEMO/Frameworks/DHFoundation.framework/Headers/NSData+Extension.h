//
//  NSData+Extension.h
//  DHFoundation
//
//  Created by DHS on 2022/5/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (Extension)

/*
 //CRC16检验码 CRC在线检验网址:https://www.lammertbies.nl/comm/info/crc-calculation.html
 NSString *ss = @"070003";
 NSData *dd =[NSData convertHexStrToData:ss];
 unsigned short checksum = [dd crc16Checksum];
 NSString *crc = [NSString ToHex:checksum];
*/
/// CRC16检验码
- (unsigned short)crc16Checksum;

/// data 转 Byte *
- (Byte *)dataToByte;

/// 16进制字符串转 Byte*
+ (Byte *)hexStrToByte:(NSString *)hexStr;


/// uint8_t转NSData
/// @param val uint8_t
+ (NSData *)byteFromUInt8:(uint8_t)val;

/// uint16_t转NSData
/// @param val uint16_t
+ (NSData *)bytesFromUInt16:(uint16_t)val;

/// uint32_t转NSData
/// @param val uint32_t
+ (NSData *)bytesFromUInt32:(uint32_t)val;

+ (NSData *)bytesFromUInt64:(uint64_t)val;

/// NSData转uint8_t
- (uint8_t)uint8;
/// NSData转uint16_t
- (uint16_t)uint16;
/// NSData转uint32_t
- (uint32_t)uint32;

///把十进制转成字节，用于发送命令
+ (Byte)byteWithInteger:(NSInteger)num;

@end

NS_ASSUME_NONNULL_END
