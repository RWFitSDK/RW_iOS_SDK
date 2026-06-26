//
//  WorkoutTypeController.m
//  DHBleSDKDemo
//
//  Created by DHS on 2026/1/17.
//

#import "WorkoutTypeController.h"
#import "WorkoutRunningController.h"

#define Lang(key)   NSLocalizedString(key, @"")

@interface WorkoutTypeController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *sportTypeList;

@property (nonatomic, assign) BleActivityMode bleActivityMode;
@property (nonatomic, assign) WorkoutControlType controllType; //0x01开始 0x03暂停 0x02继续 0x04结束

@end

@implementation WorkoutTypeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"All Run Type";
    
    self.sportTypeList = @[//7
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
    
    
    WEAKSELF
    [SVProgressHUD show];
    [DHBleCommand getControlSportWithRing:^(int code, id  _Nonnull data) {
        [SVProgressHUD dismiss];
       // @{@"keySportType":@(tSportType), @"keyControlType":@(tControlType)}
        if (code == 0 && [data isKindOfClass:[NSDictionary class]]){
            NSDictionary *tDic = data;
            NSInteger tSportType = [tDic[@"keySportType"] integerValue];
            WorkoutControlType tControlType = [tDic[@"keyControlType"] integerValue];
            
            NSLog(@"tSportType %zd tControlType %zd", tSportType, tControlType);
            
            //0x01开始 0x03暂停 0x02继续 0x04结束
            if (tControlType >= Workout_Begin && tControlType < Workout_Finish){ //在运动中,直接进入运动
                
                weakSelf.bleActivityMode = (BleActivityMode)tSportType;
                weakSelf.controllType = tControlType;
                
                WorkoutRunningController *runningC = [[WorkoutRunningController alloc] initWithNibName:@"WorkoutRunningController" bundle:nil];
                runningC.bleActivityMode = (BleActivityMode)tSportType;
                runningC.controllType = tControlType;
                runningC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [weakSelf presentViewController:runningC animated:YES completion:^{
                    
                }];
                
            }
            
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

#pragma mark- UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sportTypeList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *tCell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!tCell){
        tCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    tCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    BleActivityMode tbleActivityMode = (BleActivityMode)indexPath.row + BLE_ACTIVITY_START_INDEX;
    tCell.textLabel.text = [NSString stringWithFormat:@"%d %@", tbleActivityMode, Lang(self.sportTypeList[indexPath.row])];
    
    return tCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BleActivityMode tbleActivityMode = (BleActivityMode)indexPath.row + BLE_ACTIVITY_START_INDEX;

    WEAKSELF
    [SVProgressHUD show];
    [DHBleCommand getControlSportWithRing:^(int code, id  _Nonnull data) {
        [SVProgressHUD dismiss];
       // @{@"keySportType":@(tSportType), @"keyControlType":@(tControlType)}
        if (code == 0 && [data isKindOfClass:[NSDictionary class]]){
            NSDictionary *tDic = data;
            NSInteger tSportType = [tDic[@"keySportType"] integerValue];
            WorkoutControlType tControlType = [tDic[@"keyControlType"] integerValue];
            
            NSLog(@"tSportType %zd tControlType %zd", tSportType, tControlType);
            
            //0x01开始 0x03暂停 0x02继续 0x04结束
            if (tControlType >= Workout_Begin && tControlType < Workout_Finish){ //在运动中,直接进入运动
                
                weakSelf.bleActivityMode = (BleActivityMode)tSportType;
                weakSelf.controllType = tControlType;
                
                WorkoutRunningController *runningC = [[WorkoutRunningController alloc] initWithNibName:@"WorkoutRunningController" bundle:nil];
                runningC.bleActivityMode = (BleActivityMode)tSportType;
                runningC.controllType = tControlType;
                runningC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                [weakSelf presentViewController:runningC animated:YES completion:^{
                    
                }];
                
            }
            else{
                
                DHSportControlModel *model = [[DHSportControlModel alloc] init];
                model.controlType = Workout_Begin; //开始
                model.sportType = tbleActivityMode;
                [DHBleCommand controlSportWithRing:model block:^(int code, id  _Nonnull data) {
                    if (code == 0){
                        WorkoutRunningController *runningC = [[WorkoutRunningController alloc] initWithNibName:@"WorkoutRunningController" bundle:nil];
                        runningC.bleActivityMode = tbleActivityMode;
                        runningC.controllType = Workout_Begin; //开始
                        runningC.modalPresentationStyle = UIModalPresentationOverFullScreen;
                        [weakSelf presentViewController:runningC animated:YES completion:^{
                            
                        }];
                    }
                }];
                
            }
            
        }
    }];
}

@end
