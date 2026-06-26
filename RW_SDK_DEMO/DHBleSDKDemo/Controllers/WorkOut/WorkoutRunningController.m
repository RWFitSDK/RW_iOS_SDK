//
//  WorkoutRunningController.m
//  DHBleSDKDemo
//
//  Created by DHS on 2026/1/17.
//

#import "WorkoutRunningController.h"
#import <DHBleSDK/DHDailySportModel.h>

#define Lang(key)   NSLocalizedString(key, @"")

@interface WorkoutRunningController ()
@property (nonatomic, strong) IBOutlet UILabel *workoutTimeLb;
@property (nonatomic, strong) IBOutlet UILabel *workoutStepLb;
@property (nonatomic, strong) IBOutlet UILabel *workoutDistanceLb;
@property (nonatomic, strong) IBOutlet UILabel *workoutCaloriesLb;
@property (nonatomic, strong) IBOutlet UILabel *workoutHeartLb;
@property (nonatomic, strong) IBOutlet UILabel *workoutTypeLb;
@property (nonatomic, strong) IBOutlet UIButton *workoutEndBt;
@property (nonatomic, strong) IBOutlet UIButton *workoutPauseBt;
@property (nonatomic, strong) IBOutlet UIButton *workoutContinueBt;

@end

@implementation WorkoutRunningController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ringRuningDataUdpate:) name:BluetoothNotificationRingRuningData object:nil];
    
    NSArray *sportTypeList = @[//7
        @"str_jl_Running", @"str_jl_Treadmill", @"str_jl_Outdoorrunning", @"str_jl_Cycling",
        @"str_jl_Swim", @"str_jl_Walking", @"str_jl_Climbing", @"str_jl_Yoga",
        @"str_jl_Spinning", @"str_jl_Basketball", @"str_jl_Football", @"str_jl_Badminton",
        @"str_jl_Marathon",
                           @"str_jl_Indoorwalking",
                        @"str_jl_Freemovement", @"str_jl_run_22",
                           @"str_jl_Strengthtraining",
                           @"str_jl_Weightlifting", @"str_jl_Boxing", @"str_jl_Jumprope", @"str_jl_StairClimbing", //27
                           @"str_jl_Ski", @"str_jl_Skate", @"str_jl_Rollerskating",
                           @"str_jl_run_31",
                           @"str_jl_Hulahoop",  //32
                           @"str_jl_Golf", @"str_jl_Beyzbol", @"str_jl_Dance", @"str_jl_Pingpong",
                           @"str_jl_Hockey", @"str_jl_Pilates", @"str_jl_Taekwondo", @"str_jl_Handball",
                           @"str_jl_run_41", @"str_jl_Volleyball", @"str_jl_Tennis", @"str_jl_Darts",
                           @"str_jl_Gymnastics", @"str_jl_Steps", @"str_jl_Ellipticalmachine", @"str_jl_Zumba", //48
                           @"str_jl_Cricket", @"str_jl_Travelbywalking", @"str_jl_Aerobicexercise", @"str_jl_Rowingmachine",
                           @"str_jl_Rugby", @"str_jl_run_54", @"str_jl_Dumbbells", @"str_jl_Bodybuilding",
                           @"str_jl_Karate", @"str_jl_Fencing", @"str_jl_Martialarts", @"str_jl_TaiChi",
                           @"str_jl_Frisbee", @"str_jl_Archery", @"str_jl_Horseriding", @"str_jl_Bowling",
                           @"str_jl_Surf", @"str_jl_Softball", @"str_jl_Squash", @"str_jl_Sailboat", //68
                           @"str_jl_Pullup", @"str_jl_Skateboard", //70
                           @"str_jl_Trampoline", @"str_jl_Fishing", @"str_jl_Poledancing",
                           @"str_jl_Squaredance", @"str_jl_Jazz", @"str_jl_Ballet", @"str_jl_Disco",
                           @"str_jl_Tapdance", @"str_jl_Moderndance", @"str_jl_Pushups", @"str_jl_Scooter", //81
                           @"str_jl_Plank", @"str_jl_Billiards", @"str_jl_Rockclimbing", @"str_jl_DiscusThrow",
                           @"str_jl_HorseRacing", @"str_jl_Wrestling", @"str_jl_Highjump", @"str_jl_Parachute", //89
                           @"str_jl_Shotput", @"str_jl_Longjump", @"str_jl_Javelinthrow", @"str_jl_Hammer",
                           @"str_jl_Squat", @"str_jl_Legpress", @"str_jl_run_96", @"str_jl_Motocross",
                           @"str_jl_Rowing", @"str_jl_Crossfit", @"str_jl_Waterbike", @"str_jl_Kayak",
                           @"str_jl_Croquet", @"str_jl_Floorball", @"str_jl_MuayThai", @"str_jl_Jaiball",
                           @"str_jl_run_106", @"str_jl_Backtraining", @"str_jl_Watervolleyball", @"str_jl_Waterskiing", //25
                           @"str_jl_Mountainclimber", @"str_jl_HIIT", @"str_jl_BODYCOMBAT", @"str_jl_BODYBALANCE",
                           @"str_jl_TRX", @"str_jl_TaeBo"];
    
    self.workoutTypeLb.text = [NSString stringWithFormat:@"%d %@", self.bleActivityMode, Lang(sportTypeList[self.bleActivityMode - BLE_ACTIVITY_START_INDEX])];
    
    //0x01开始 0x03暂停 0x02继续 0x04结束
    if (self.controllType == Workout_Begin){
        self.workoutEndBt.hidden = NO;
        self.workoutPauseBt.hidden = NO;
        self.workoutContinueBt.hidden = YES;
    }
    else if (self.controllType == Workout_Continue){
        self.workoutEndBt.hidden = NO;
        self.workoutPauseBt.hidden = NO;
        self.workoutContinueBt.hidden = YES;
    }
    else if (self.controllType == Workout_Pause){ //暂停
        self.workoutEndBt.hidden = NO;
        self.workoutPauseBt.hidden = YES;
        self.workoutContinueBt.hidden = NO;
    }

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //进入运动界面
    [DHBleCommand setRingEnterWorkOut:1 block:^(int code, id  _Nonnull data) {
        
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //退出运动界面
    [DHBleCommand setRingEnterWorkOut:0 block:^(int code, id  _Nonnull data) {
        
    }];
}

- (void)ringRuningDataUdpate:(NSNotification *)ntf
{
    NSDictionary *tUserInfo = ntf.userInfo;
    if (tUserInfo.count > 0){
        NSInteger duration = [tUserInfo[@"ActivityTime"] integerValue];
        NSInteger totalStep = [tUserInfo[@"ActivitySteps"] integerValue];
        NSInteger activityDistance = [tUserInfo[@"ActivityDistance"] integerValue];
        NSInteger activityCalorie = [tUserInfo[@"ActivityCalorie"] integerValue];
        NSInteger activityHr = [tUserInfo[@"ActivityHr"] integerValue];
        NSInteger tActivityDataType = [tUserInfo[@"ActivityDataType"] integerValue];
        
        NSLog(@"ringRuningDataUdpate tActivityDataType %04X", (UInt32)tActivityDataType);
        NSInteger hours = duration / 3600;
        NSInteger minutes = (duration % 3600) / 60;
        NSInteger seconds = duration % 60;
        self.workoutTimeLb.text = [NSString stringWithFormat:@"Time: %02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
        self.workoutStepLb.text = [NSString stringWithFormat:@"Steps: %ld", totalStep];
        self.workoutDistanceLb.text = [NSString stringWithFormat:@"Distance: %.2f Km", floor(activityDistance/1000.0*100)/100];
        self.workoutCaloriesLb.text = [NSString stringWithFormat:@"Calories: %.1f KCal", floor(activityCalorie/1000.0*10)/10];
        self.workoutHeartLb.text = [NSString stringWithFormat:@"HeartRate: %ld bpm", activityHr];
    }
}

- (void)finishSyncWorkOutData
{
    [DHBleCommand startRingWorkout3Syncing:^(int code, id  _Nonnull data) {
        NSLog(@"startRingWorkout3Syncing 同步完成 code %d", code);
    } dataBlock:^(int code, int progress, id  _Nonnull data) {
        if (code == 0) {
            if ([data isKindOfClass:[NSArray class]]){
                NSArray *array = data;
                for (id model in array) {
                    if ([model isKindOfClass:[DHDailySportModel class]]) {
                        //保存数据库或其它操作
                        
                    }
                }
                
                NSLog(@"startRingWorkout3Syncing data %zd", array.count);
                
            }
        }
    }];
}


- (IBAction)cancelButtonClick:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)finishButtonClick:(id)sender
{
    WEAKSELF
    //0x01开始 0x03暂停 0x02继续 0x04结束
    DHSportControlModel *model = [[DHSportControlModel alloc] init];
    model.controlType = Workout_Finish;
    model.sportType = self.bleActivityMode;
    [DHBleCommand controlSportWithRing:model block:^(int code, id  _Nonnull data) {
        if (code == 0){
            weakSelf.workoutEndBt.hidden = YES;
            weakSelf.workoutPauseBt.hidden = YES;
            weakSelf.workoutContinueBt.hidden = YES;
            
            [weakSelf finishSyncWorkOutData];
        }
    }];
}

- (IBAction)PauseButtonClick:(id)sender
{
    WEAKSELF
    DHSportControlModel *model = [[DHSportControlModel alloc] init];
    model.controlType = Workout_Pause;
    model.sportType = self.bleActivityMode;
    [DHBleCommand controlSportWithRing:model block:^(int code, id  _Nonnull data) {
        if (code == 0){
            weakSelf.workoutPauseBt.hidden = YES;
            weakSelf.workoutContinueBt.hidden = NO;
        }
    }];
}

- (IBAction)ContinueButtonClick:(id)sender
{
    WEAKSELF
    DHSportControlModel *model = [[DHSportControlModel alloc] init];
    model.controlType = Workout_Continue;
    model.sportType = self.bleActivityMode;
    [DHBleCommand controlSportWithRing:model block:^(int code, id  _Nonnull data) {
        if (code == 0){
            weakSelf.workoutPauseBt.hidden = NO;
            weakSelf.workoutContinueBt.hidden = YES;
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
