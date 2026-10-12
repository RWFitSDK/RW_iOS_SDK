//
//  DHAncsSetModel.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DHAncsSetModel : NSObject

/// 来电（0.关 1.开）
@property (nonatomic, assign) BOOL isCall;
/// 短信
@property (nonatomic, assign) BOOL isSMS;
/// QQ
@property (nonatomic, assign) BOOL isQQ;
/// 微信
@property (nonatomic, assign) BOOL isWechat;
/// Whatsapp
@property (nonatomic, assign) BOOL isWhatsapp;
/// Twitter
@property (nonatomic, assign) BOOL isTwitter;
/// Linkedin
@property (nonatomic, assign) BOOL isLinkedin;

/// Instagram
@property (nonatomic, assign) BOOL isInstagram;
/// Facebook
@property (nonatomic, assign) BOOL isFacebook;
/// Line
@property (nonatomic, assign) BOOL isLine;
/// Email
@property (nonatomic, assign) BOOL isEmail;

/// Skype
@property (nonatomic, assign) BOOL isSkype;
/// Kakaotalk
@property (nonatomic, assign) BOOL isKakaotalk;
/// Youtube
@property (nonatomic, assign) BOOL isYoutube;
/// Gmail
@property (nonatomic, assign) BOOL isGmail;


/// Sina weibo
@property (nonatomic, assign) BOOL isJLSinaWeiBo;

/// Band
@property (nonatomic, assign) BOOL isJLBand;

/// telegram
@property (nonatomic, assign) BOOL isJLTelegram;

/// between
@property (nonatomic, assign) BOOL isJLBetween;

/// Naver cafe
@property (nonatomic, assign) BOOL isJLNavercafe;


/// Net flix
@property (nonatomic, assign) BOOL isJLNetflix;

/// 俄罗斯 MAX软件
@property (nonatomic, assign) BOOL isMax;
/// VK Мессенджер
@property (nonatomic, assign) BOOL isVkim;

/// Mail.ru
@property (nonatomic, assign) BOOL isRuMail;
/// Yandex Mail
@property (nonatomic, assign) BOOL isYandexMail;
/// Yandex Go
@property (nonatomic, assign) BOOL isYandexTaxi;
/// ВКонтакте
@property (nonatomic, assign) BOOL isVkontakte;
/// Wildberries
@property (nonatomic, assign) BOOL isWildberries;
/// OZON
@property (nonatomic, assign) BOOL isOzon;
/// МАКС
@property (nonatomic, assign) BOOL isMakc;
/// Яндекс Маркет
@property (nonatomic, assign) BOOL isYandexMarket;
/// Госуслуги
@property (nonatomic, assign) BOOL isGosuslugi;
/// Яндекс Еда
@property (nonatomic, assign) BOOL isYandexFood;

/// 其他
@property (nonatomic, assign) BOOL isOther;

- (NSData *)valueWithJL;

@end

NS_ASSUME_NONNULL_END
