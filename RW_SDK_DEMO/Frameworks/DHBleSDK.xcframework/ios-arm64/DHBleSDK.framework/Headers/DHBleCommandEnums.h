//
//  DHBleCommandEnums.h
//  DHBleSDK
//
//  Created by DHS on 2022/6/23.
//

#ifndef DHBleCommandEnums_h
#define DHBleCommandEnums_h

#import <Foundation/Foundation.h>


//健康数据广播
#define BluetoothNotificationHealthDataChange @"BluetoothNotificationHealthDataChange"

#define BluetoothNotificationHealthRingMeasureValueChange @"BluetoothNotificationHealthRingMeasureValueChange"
// 设备主动推送；userInfo: dataType、dataValue、timestamp(Unix毫秒)
#define BluetoothNotificationProtocolPush @"BluetoothNotificationProtocolPush"
//健康戒指手动测量改变
#define BluetoothNotificationHealthRingMeasureStateChange @"BluetoothNotificationHealthRingMeasureStateChange"

#define BluetoothNotificationHealthRingSenorStopChange @"BluetoothNotificationHealthRingSenorStopChange"

//开始寻找手机通知
#define BluetoothNotificationFindPhoneStart @"BluetoothNotificationFindPhoneStart"
//结束寻找手机通知
#define BluetoothNotificationFindPhoneEnd @"BluetoothNotificationFindPhoneEnd"

//戒指健康数据超出提示
#define BluetoothNotificationRingHealthOverAlert @"BluetoothNotificationRingHealthOverAlert"
//戒指多运动数据
#define BluetoothNotificationRingRuningData @"BluetoothNotificationRingRuningData"

//Muslim Ring控制主动收到赞念清理为0
#define BluetoothNotificationMuslimRingCleanOK @"BluetoothNotificationMuslimRingCleanOK"
//Muslim Ring控制主动收到赞念结束
#define BluetoothNotificationMuslimRingCountEnd @"BluetoothNotificationMuslimRingCountEnd"

//闹钟提醒广播化
#define BluetoothNotificationAlarmChange @"BluetoothNotificationAlarmChange"

//杰里APP发起运动设备端点击继续
#define BluetoothNotificationJLWorkoutContinue @"BluetoothNotificationJLWorkoutContinue"
//杰里APP发起运动设备端点击暂停
#define BluetoothNotificationJLWorkoutPause @"BluetoothNotificationJLWorkoutPause"
//杰里APP发起运动设备端点击结束
#define BluetoothNotificationJLWorkoutEnd @"BluetoothNotificationJLWorkoutEnd"

//打开拍照通知
#define BluetoothNotificationCameraTurnOn @"BluetoothNotificationCameraTurnOn"
//关闭拍照通知
#define BluetoothNotificationCameraTurnOff @"BluetoothNotificationCameraTurnOff"
//拍照通知
#define BluetoothNotificationCameraTakePicture @"BluetoothNotificationCameraTakePicture"

//传感器原始数据通知
#define BluetoothNotificationSensorRawData @"BluetoothNotificationSensorRawData"


typedef enum : NSUInteger {
    SendState_OK,
    SendState_BLENoOpen,
    SendState_BLEDisconnect,
    SendState_TimeOut,
    SendState_Failed,
    SendState_DuplicateSend, //重复发送
    SendState_NotSupport, //不支持
    SendState_Max
} SendStateCode;


/// 对外接口与数据通知使用的类型值 / Values used by public APIs and data notifications.
typedef enum : UInt16 {
    // 健康检测类型 / Health measurement types
    BLE_KEY_HEART_RATE = 0x0503,
    BLE_KEY_BLOOD_PRESSURE = 0x0504,
    BLE_KEY_TEMPERATURE = 0x0508,
    BLE_KEY_BLOOD_OXYGEN = 0x0509,
    BLE_KEY_HRV = 0x050A,
    BLE_KEY_STRESS = 0x050D,
    BLE_KEY_BLOOD_SUGAR = 0x0510,
    // 实时健康数据类型 / Real-time health data types
    BLE_KEY_APP_REAL_TIME_HR_DATA = 0x0224,
    BLE_KEY_APP_REAL_TIME_TEMPERATURE_DATA = 0x0230,
    BLE_KEY_APP_REAL_TIME_BP_DATA = 0x0231,
    BLE_KEY_APP_REAL_TIME_ACTIVITY_DATA = 0x024D,
    BLE_KEY_APP_REAL_TIME_BLOOD_OXYGEN_DATA = 0x024E,
    BLE_KEY_APP_REAL_TIME_STRESS_DATA = 0x024F,
    BLE_KEY_APP_REAL_TIME_MUSLIM_COUNT = 0x0253,
    BLE_KEY_APP_REAL_TIME_HRV_DATA = 0x0269,
    BLE_KEY_APP_REAL_BLOOD_SUGAR_DATA = 0x026C,
    // 运动数据通知类型 / Workout notification types
    BLE_KEY_APP_WORKOUT_DATA = 0x0223,
    BLE_KEY_ENTER_OR_EXIT_WORKOUT = 0x0274,
} BleKey;

/// 设备主动推送类型 / Device push notification types.
typedef enum : UInt16 {
    DHDevicePushTypePower = 0x0203,
    DHDevicePushTypeRecordStatus = 0x0802,
    /// 触摸事件: keyType为1触摸/2跌落/3 SOS/4连续点击；keyType=1且touchType=6为Release(长按后松手)。连续点击时touchType为次数(1-9)，SOS时不使用。
    DHDevicePushTypeTouchEvent = 0x0406,
    /// 实时录音音频: dataValue为NSDictionary, sequence(0-255循环序号)+audioData(NSData原始音频字节)。
    DHDevicePushTypeRecordRealtimeData = 0x0806,
    /// 计数识别状态: dataValue为NSNumber(BOOL), YES=Arm NO=Disarm。
    DHDevicePushTypeCountControl = 0x0615,
    /// 赞念实时计数: dataValue为NSDictionary, timestamp(Unix秒)+value(累计计数), 每项一条通知。
    DHDevicePushTypeMuslimCount = 0x0253
} DHDevicePushType;

typedef enum {
    BLE_ACTIVITY_START_INDEX = 7,        // 枚举值开始标记
    BLE_ACTIVITY_RUNNING = 7,            // 跑步           10 MET/70Kg/60分钟/700千卡
    BLE_ACTIVITY_INDOOR = 8,             // 跑步机          7.3 MET/70Kg/60分钟/511千卡
    BLE_ACTIVITY_OUTDOOR = 9,            // 户外跑步运动    未查到
    BLE_ACTIVITY_CYCLING = 10,           // 骑行            8 MET/70Kg/60分钟/560千卡
    BLE_ACTIVITY_SWIMMING = 11,          // 游泳            6 MET/70Kg/60分钟/420千卡
    BLE_ACTIVITY_WALKING = 12,           // 步行，健走      2.5 MET/70Kg/60分钟/175千卡
    BLE_ACTIVITY_CLIMBING = 13,          // 爬山            6.7 MET/70Kg/60分钟/469千卡
    BLE_ACTIVITY_YOGA = 14,              // 瑜伽            2.5 MET/70Kg/60分钟/175千卡
    BLE_ACTIVITY_SPINNING = 15,          // 动感单车        12 MET/70Kg/60分钟/840千卡
    BLE_ACTIVITY_BASKETBALL = 16,        // 篮球            6 MET/70Kg/60分钟/420千卡
    BLE_ACTIVITY_FOOTBALL = 17,          // 足球            7 MET/70Kg/60分钟/490千卡
    BLE_ACTIVITY_BADMINTON = 18,         // 羽毛球          4.5 MET/70Kg/60分钟/315千卡
    BLE_ACTIVITY_MARATHON = 19,          // 马拉松          未查到
    BLE_ACTIVITY_INDOOR_WALK = 20,       // 室内步行        2.5 MET/70Kg/60分钟/175千卡
    BLE_ACTIVITY_FREE_TRAINING = 21,     // 自由锻炼        未查到
    BLE_ACTIVITY_TRACK_AND_FIELD = 22,   // 田径            //竞赛
    BLE_ACTIVITY_WEIGHTTRANNING = 23,    // 力量训练        未查到
    BLE_ACTIVITY_WEIGHTLIFTING = 24,     // 举重            3 MET/70Kg/60分钟/210千卡
    BLE_ACTIVITY_BOXING = 25,            // 拳击            12 MET/70Kg/60分钟/840千卡 boxing
    BLE_ACTIVITY_JUMP_ROPE = 26,         // 跳绳            10 MET/70Kg/60分钟/700千卡
    BLE_ACTIVITY_CLIMB_STAIRS = 27,      // 爬楼梯          8 MET/70Kg/60分钟/560千卡
    BLE_ACTIVITY_SKI = 28,               // 滑雪            6.3 MET/70Kg/60分钟/441千卡
    BLE_ACTIVITY_SKATE = 29,             // 滑冰            7 MET/70Kg/60分钟/490千卡
    BLE_ACTIVITY_ROLLER_SKATING = 30,    // 轮滑            11.9 MET/70Kg/60分钟/490千卡
    BLE_ACTIVITY_CYCLING_INDOOR = 31,    // 室内骑行        //竞赛
    BLE_ACTIVITY_HULA_HOOP = 32,         // 呼啦圈          5 MET/70Kg/60分钟/350千卡
    BLE_ACTIVITY_GOLF = 33,              // 高尔夫          4.5 MET/70Kg/60分钟/315千卡
    BLE_ACTIVITY_BASEBALL = 34,          // 棒球            5 MET/70Kg/60分钟/350千卡
    BLE_ACTIVITY_DANCE = 35,             // 舞蹈            4.5 MET/70Kg/60分钟/315千卡
    BLE_ACTIVITY_PING_PONG = 36,         // 乒乓球          4 MET/70Kg/60分钟/280千卡
    BLE_ACTIVITY_HOCKEY = 37,            // 曲棍球          7 MET/70Kg/60分钟/490千卡
    BLE_ACTIVITY_PILATES = 38,           // 普拉提          3.5 MET/70Kg/60分钟/245千卡
    BLE_ACTIVITY_TAEKWONDO = 39,         // 跆拳道          10 MET/70Kg/60分钟/700千卡
    BLE_ACTIVITY_HANDBALL = 40,          // 手球            12 MET/70Kg/60分钟/840千卡
    BLE_ACTIVITY_DANCE_STREET = 41,      // 街舞            7.8 MET/70Kg/60分钟/548千卡
    BLE_ACTIVITY_VOLLEYBALL = 42,        // 排球            8 MET/70Kg/60分钟/560千卡
    BLE_ACTIVITY_TENNIS = 43,            // 网球            7 MET/70Kg/60分钟/490千卡
    BLE_ACTIVITY_DARTS = 44,             // 飞镖            2.5 MET/70Kg/60分钟/175千卡
    BLE_ACTIVITY_GYMNASTICS = 45,        // 体操            4.7 MET/70Kg/60分钟/327千卡
    BLE_ACTIVITY_STEPPING = 46,          // 踏步            4 MET/70Kg/60分钟/280千卡
    BLE_ACTIVITY_ELLIPTICAL = 47,        // 椭圆机          4 MET/70Kg/60分钟/280千卡
    BLE_ACTIVITY_ZUMBA = 48,             // 尊巴            7 MET/70Kg/60分钟/514千卡 舞蹈的一种
    BLE_ACTIVITY_CRICKET = 49,           // 板球            5 MET/70Kg/60分钟/368千卡
    BLE_ACTIVITY_TREKKING = 50,          // 徒步旅行        6 MET/70Kg/60分钟/441千卡
    BLE_ACTIVITY_AEROBICS = 51,          // 有氧运动        5.8 MET/70Kg/60分钟/408千卡
    BLE_ACTIVITY_ROWING_MACHINE = 52,    // 划船机          12 MET/70Kg/60分钟/840千卡
    BLE_ACTIVITY_RUGBY = 53,             // 橄榄球          8 MET/70Kg/60分钟/560千卡
    BLE_ACTIVITY_SIT_UP = 54,            // 仰卧起坐        8 MET/70KG/60分钟/560千卡
    BLE_ACTIVITY_DUM_BLE = 55,           // 哑铃            3 MET/70KG/60分钟/210千卡
    BLE_ACTIVITY_BODY_EXERCISE = 56,     // 健身操          4.7 MET/70KG/60分钟/327千卡
    BLE_ACTIVITY_KARATE = 57,            // 空手道          10 MET/70KG/60分钟/700千卡
    BLE_ACTIVITY_FENCING = 58,           // 击剑            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_MARTIAL_ARTS = 59,      // 武术            13.2 MET/70KG/60分钟/922千卡
    BLE_ACTIVITY_TAI_CHI = 60,           // 太极拳          4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_FRISBEE = 61,           // 飞盘            3 MET/70KG/60分钟/220千卡
    BLE_ACTIVITY_ARCHERY = 62,           // 射箭            4 MET/70KG/60分钟/294千卡
    BLE_ACTIVITY_HORSE_RIDING = 63,      // 骑马            4 MET/70KG/60分钟/294千卡
    BLE_ACTIVITY_BOWLING = 64,           // 保龄球          4 MET/70KG/60分钟/294千卡
    BLE_ACTIVITY_SURF = 65,              // 冲浪            3 MET/70KG/60分钟/220千卡
    BLE_ACTIVITY_SOFTBALL = 66,          // 垒球            5 MET/70KG/60分钟/368千卡
    BLE_ACTIVITY_SQUASH = 67,            // 壁球            8 MET/70KG/60分钟/588千卡
    BLE_ACTIVITY_SAILBOAT = 68,          // 帆船            3 MET/70KG/60分钟/220千卡
    BLE_ACTIVITY_PULL_UP = 69,           // 引体向上        8 MET/70KG/60分钟/560千卡
    BLE_ACTIVITY_SKATEBOARD = 70,        // 滑板            5 MET/70KG/60分钟/350千卡
    BLE_ACTIVITY_TRAMPOLINE = 71,        // 蹦床            6 MET/70KG/60分钟/441千卡
    BLE_ACTIVITY_FISHING = 72,           // 钓鱼            3 MET/70KG/60分钟/220千卡
    BLE_ACTIVITY_POLE_DANCING = 73,      // 钢管舞          6 MET/70KG/60分钟/441千卡
    BLE_ACTIVITY_SQUARE_DANCE = 74,      // 广场舞          3 MET/70KG/60分钟/210千卡
    BLE_ACTIVITY_JAZZ_DANCE = 75,        // 爵士舞          4.8 MET/70KG/60分钟/336千卡
    BLE_ACTIVITY_BALLET = 76,            // 芭蕾舞          4.8 MET/70KG/60分钟/336千卡
    BLE_ACTIVITY_DISCO = 77,             // 迪斯科          4.5 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_TAP_DANCE = 78,         // 踢踏舞          4.8 MET/70KG/60分钟/336千卡
    BLE_ACTIVITY_MODERN_DANCE = 79,      // 现代舞          4.8 MET/70KG/60分钟/336千卡
    BLE_ACTIVITY_PUSH_UPS = 80,          // 俯卧撑          8 MET/70KG/60分钟/560千卡
    BLE_ACTIVITY_SCOOTER = 81,           // 滑板车          7 MET/70KG/60分钟/490千卡
    BLE_ACTIVITY_PLANK = 82,              // 平板支撑        3.3 MET/70KG/60分钟/228千卡
    BLE_ACTIVITY_BILLIARDS = 83,          // 桌球            2.5 MET/70KG/60分钟/175千卡
    BLE_ACTIVITY_ROCK_CLIMBING = 84,      // 攀岩            11 MET/70KG/60分钟/770千卡
    BLE_ACTIVITY_DISCUS = 85,             // 铁饼            4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_RACE_RIDING = 86,        // 赛马            10 MET/70KG/60分钟/700千卡
    BLE_ACTIVITY_WRESTLING = 87,          // 摔跤            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_HIGH_JUMP = 88,          // 跳高            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_PARACHUTE = 89,          // 跳伞            3.5 MET/70KG/60分钟/245千卡
    BLE_ACTIVITY_SHOT_PUT = 90,           // 铅球            4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_LONG_JUMP = 91,          // 跳远            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_JAVELIN = 92,            // 标枪            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_HAMMER = 93,             // 链球            4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_SQUAT = 94,              // 深蹲            4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_LEG_PRESS = 95,          // 压腿            2.5 MET/70KG/60分钟/175千卡
    BLE_ACTIVITY_OFF_ROAD_BIKE = 96,      // 越野自行车      8.3 MET/70KG/60分钟/581千卡
    BLE_ACTIVITY_MOTOCROSS = 97,          // 越野摩托车      4 MET/70KG/60分钟/280千卡
    BLE_ACTIVITY_ROWING = 98,             // 赛艇            8 MET/70KG/60分钟/588千卡
    BLE_ACTIVITY_CROSSFIT = 99,           // CROSSFIT        7 MET/70KG/60分钟/514千卡 通过多种以自身重量、负重 为主的高次数、快速、爆发力的动作增强自己的体能和运动能力
    BLE_ACTIVITY_WATER_BIKE = 100,        // 水上自行车      4 MET/70KG/60分钟/294千卡
    BLE_ACTIVITY_KAYAK = 101,             // 皮划艇          5 MET/70KG/60分钟/368千卡
    BLE_ACTIVITY_CROQUET = 102,           // 槌球            2.5 MET/70KG/60分钟/175千卡
    BLE_ACTIVITY_FLOOR_BALL = 103,        // 地板球          6 MET/70KG/60分钟/441千卡 （福乐球 FLOORBALL） 软式曲棍球
    BLE_ACTIVITY_THAI = 104,              // 泰拳            7 MET/70KG/514 280千卡
    BLE_ACTIVITY_JAI_BALL = 105,          // 回力球          12 MET/70KG/60分钟/840千卡
    BLE_ACTIVITY_TENNIS_DOUBLES = 106,    // 网球(双打)      6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_BACK_TRAINING = 107,     // 背部训练        3.5 MET/70KG/60分钟/245千卡
    BLE_ACTIVITY_WATER_VOLLEYBALL = 108,  // 水上排球        3 MET/70KG/60分钟/210千卡
    BLE_ACTIVITY_WATER_SKIING = 109,      // 滑水            6 MET/70KG/60分钟/420千卡
    BLE_ACTIVITY_MOUNTAIN_CLIMBER = 110,  // 登山机          8 MET/70KG/60分钟/588千卡
    BLE_ACTIVITY_HIIT = 111,              // HIIT            7 MET/70KG/60分钟/514千卡  高强度间歇性训练
    BLE_ACTIVITY_BODY_COMBAT = 112,       // BODY COMBAT     7 MET/70KG/60分钟/514千卡  搏击（拳击）的一种
    BLE_ACTIVITY_BODY_BALANCE = 113,      // BODY BALANCE    7 MET/70KG/60分钟/514千卡  瑜伽、太极和普拉提融合在一起的身心训练项目
    BLE_ACTIVITY_TRX = 114,               // TRX             7 MET/70KG/60分钟/514千卡 全身抗阻力锻炼 全身抗阻力锻炼
    BLE_ACTIVITY_TAE_BO = 115,            // 跆搏（TAE BO）   7 MET/70KG/60分钟/514千卡 集跆拳道、空手道、拳击、自由搏击、舞蹈韵律操为一体


    BLE_ACTIVITY_BMX = 116,              // 小轮车         //竞赛
    BLE_ACTIVITY_STRETCHING = 117,       // 拉伸           //训练
    BLE_ACTIVITY_INDOOR_FINESS = 118,     // 室内健身       //训练
    BLE_ACTIVITY_FLEXIBILITY = 119, // 柔韧训练        未查到 //训练
    BLE_ACTIVITY_UPPER_LIMB_TRAIN = 120,// 上肢训练      //训练
    BLE_ACTIVITY_LOWER_LIMB_TRAIN = 121,// 下肢训练        //训练
    BLE_ACTIVITY_FREE_EXERCISE = 122,//自由体操        //训练
    BLE_ACTIVITY_BARBELL_TRAINING = 123,// 杠铃             3 MET/70KG/60分钟/210千卡 //训练
    BLE_ACTIVITY_PHYSICAL_TRAINING = 124,// 体能训练         //训练
    BLE_ACTIVITY_DEADLIFT = 125,// 硬拉             //训练
    BLE_ACTIVITY_BOBBY_JUMP = 126,// 波比跳              //训练
    BLE_ACTIVITY_FUNCTION_TRAIN = 127,// 功能性测试       //训练
    BLE_ACTIVITY_WAIST_ABDOMEN_TRAIN = 128,// 腰腹训练         //训练
    BLE_ACTIVITY_TABLE_FOOTBALL = 129,// 桌式足球         //球
    BLE_ACTIVITY_HUNTING = 130,// 打猎             //竞赛
    BLE_ACTIVITY_PADDLEBOARD_SURFING = 131,// 立桨冲浪//竞赛
    BLE_ACTIVITY_KAYAKING_RAFTING = 132,// 皮艇漂流//竞赛
    BLE_ACTIVITY_MOTORBOAT = 133,//摩托艇//竞赛
    BLE_ACTIVITY_PARKOUR = 134,//跑酷//竞赛
    BLE_ACTIVITY_ATV = 135,// 沙滩车//竞赛
    BLE_ACTIVITY_PARAGLIDER = 136,// 滑翔伞//竞赛
    BLE_ACTIVITY_CURLING = 137,// 冰壶//竞赛
    BLE_ACTIVITY_SNOWBOARDING = 138,// 滑雪板//竞赛
    BLE_ACTIVITY_DOUBLE_BOARD = 139,// 滑雪双板//竞赛
    BLE_ACTIVITY_ALPINE_SKIING = 140,// 高山滑雪//竞赛
    BLE_ACTIVITY_CROSS_COUNT = 141,// 越野滑雪//竞赛
    BLE_ACTIVITY_SNOW_MOBILE = 142,//雪地摩托//竞赛
    BLE_ACTIVITY_SNOW_CAR = 143,// 雪车//竞赛
    BLE_ACTIVITY_SLED = 144,// 雪橇//竞赛
    BLE_ACTIVITY_WALLBALL = 145,// 墙球//球
    BLE_ACTIVITY_PUCK = 146,// 冰球//球
    BLE_ACTIVITY_SEPAK_TAKRAW = 147,// 藤球//球
    BLE_ACTIVITY_WATER_POLO = 148,//水球//球
    BLE_ACTIVITY_BELLY = 149,// 肚皮舞//舞
    BLE_ACTIVITY_BALLROOM_DANCE = 150,// 交际舞//舞
    BLE_ACTIVITY_NATIONAL_DANCE = 151,// 民族舞//舞
    BLE_ACTIVITY_LATIN = 152,// 拉丁舞//舞
    BLE_ACTIVITY_JODO = 153, // 柔道//竞赛
    BLE_ACTIVITY_KICKBOXING = 154,//踢拳//竞赛
    BLE_ACTIVITY_FLY_A_KITE = 155,// 放风筝//竞赛
    BLE_ACTIVITY_TUGOFWAR = 156,// 拔河//竞赛
    BLE_ACTIVITY_SHUTTLE = 157,// 毽球//球
    BLE_ACTIVITY_KABADDI = 158,// 卡巴迪//竞赛
    BLE_ACTIVITY_RACING_CAR = 159,// 赛车//竞赛
    BLE_ACTIVITY_SEVEN_STONES = 160,//石子游戏//竞赛
    BLE_ACTIVITY_KHO_KHO = 161,//捉人游戏//竞赛
    // 增加类型时需同步修改cd_workout.c中的 midWorkoutPrepare(), endByStep(), getSportMet(), WORKOUT_TYPE_相关数组
} BleActivityMode;


#endif /* DHBleCommandEnums_h */
