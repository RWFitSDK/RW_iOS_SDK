//
//  DHAudioConverter.h
//  DHBleSDK
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const DHAudioConverterErrorDomain;

typedef NS_ERROR_ENUM(DHAudioConverterErrorDomain, DHAudioConverterErrorCode) {
    DHAudioConverterErrorInvalidInput = 1,
    DHAudioConverterErrorUnsupportedFormat,
    DHAudioConverterErrorDecodeFailed,
    DHAudioConverterErrorOutputTooLarge,
    DHAudioConverterErrorFileOperationFailed,
};

/// Recording audio conversion utilities.
@interface DHAudioConverter : NSObject

/// Decodes an Ogg Opus recording into 16-bit PCM WAV data.
///
/// The output sample rate and channel count are read from the Opus stream.
+ (nullable NSData *)convertOggOpusToWAV:(NSData *)oggOpusData
                                   error:(NSError * _Nullable * _Nullable)error;

/// Decodes an Ogg Opus file and writes a 16-bit PCM WAV file.
+ (BOOL)convertOggOpusFile:(NSString *)inputPath
                 toWAVFile:(NSString *)outputPath
                     error:(NSError * _Nullable * _Nullable)error;

@end

NS_ASSUME_NONNULL_END
