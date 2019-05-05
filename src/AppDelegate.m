//
//  AppDelegate.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>

#import "AppDelegate.h"
#import "SideslipViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"
#import "CenterViewController.h"
#import "LoginViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "EditHeadAndNameViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import "MPNotificationView.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "MyUncaughtExceptionHandler.h"
#import "UserModel.h"
#import "Masonry.h"
#import "UIImage+GIF.h"
#import "KKSequenceImageView.h"
@interface AppDelegate ()<WebServiceProtocol,UIAlertViewDelegate,KKSequenceImageDelegate,UNUserNotificationCenterDelegate>
{
    NSUserDefaults *defaults;
    UINavigationController *nav;
    DataManager *manager;
    DeviceModel *deviceModel;
}
@property(nonatomic,strong)UIView *lunchView;
@property(nonatomic,strong)KKSequenceImageView* imageView;
@end

@implementation AppDelegate
{
@private NSDate * leaveTime;

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
   
    
    
    //---------------

    [self.window makeKeyAndVisible];
//     解析成json数据
    [self otherOperations:application and:launchOptions];
//    NSLock* lock = [[NSLock alloc]init];
////    [lock lock];
////    [self lauchScreenImageName:@"comm_bg"];
////    [self animationImageTwo];
//    
//        [lock lock];
//    KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    NSMutableArray* images = [NSMutableArray array];
//    for (int i = 1; i <= 45; i++) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
//        if (path.length) {
//            [images addObject:path];
//        }
//    }
//    imageView.imagePathss = images;
//    imageView.durationMS = images.count * 50;
//    imageView.repeatCount = 1;
//    imageView.delegate = self;
//    //        [_lunchView addSubview:_imageView];
//    [self.window addSubview:imageView];
//    [imageView begin];
//    [lock unlock];
//    
//    __weak typeof (self)weakSelf = self;
//    
//    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((((int)imageView.durationMS)/1000.0)-0.2)/*延迟执行时间*/ * NSEC_PER_SEC));
//    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
////
////                [UIView animateWithDuration:1 animations:^{
////
////                    imageView.alpha = 0;
////                } completion:^(BOOL finished)
////                {
////
////                }];
//        [imageView removeFromSuperview];
////        [weakSelf otherOperations:application and:launchOptions];
//        //        [lock unlock];
//        
//        
//      
//        
//        //        }];
//        
//    });

//    UIView* View =
//    _lunchView = [[UIView alloc]init];
//    _lunchView.frame = CGRectMake(0, 0, self.window.screen.bounds.size.width, self.window.screen.bounds.size.height);
//    [_window addSubview:_lunchView];
//    _imageView = [[KKSequenceImageView alloc] initWithFrame:CGRectMake(0, 0, self.window.screen.bounds.size.width,self.window.screen.bounds.size.height)];
//    NSMutableArray* images = [NSMutableArray array];
//    [self.window bringSubviewToFront:_lunchView];
//    //    _imageView.image = [UIImage sd_animatedGIFNamed:@"树林"];
//    for (int i = 1; i <= 50; i++) {
//        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
//        if (path.length) {
//            [images addObject:path];
//        }
//    }
//    _imageView.imagePathss = images;
//    _imageView.durationMS = images.count * 40;
//    _imageView.repeatCount = 1;
//    _imageView.delegate = self;
//    [_lunchView addSubview:_imageView];
//    [_imageView begin];
    [self ReceiveRemoteNotification:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}
- (void)sequenceImageDidPlayCompeletion:(KKSequenceImageView *)imageView
{
    [_lunchView removeFromSuperview];
    _imageView = nil;
}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    
    if ([[theWebService soapResults] length] > 0) {
        
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        
        if (!error && object) {
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            
            if(code == 1)
            {
                //同意绑定后 刷新宝贝数据
                if (ws.tag == 4)
                {
                    NSArray *ar = [object objectForKey:@"deviceList"];
                    for(int i = 0; i < ar.count;i++)
                    {
                        if([[[ar objectAtIndex:i] objectForKey:@"DeviceID"] intValue] == [[defaults objectForKey:@"selectDeviceID"] intValue])
                        {
                            NSDictionary *dic = [ar objectAtIndex:i];
#pragma mark - 写入设备信息表
                            [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                      andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"]];
                            
#pragma mark - 写入设备设置表
                            
                            NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                            NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                            
                            NSArray * classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                            
                            
                            NSArray * classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                            
                            [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"]  andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@""];
                            
#pragma mark - 写入联系人表
                            
                            NSArray *contact = [dic objectForKey:@"ContactArr"];
                            for(int i = 0; i < contact.count;i++)
                            {
                                NSDictionary *con = [contact objectAtIndex:i];
                                
                                [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                            }
                            
#pragma mark - 写入位置表
                            NSDictionary *locations = [dic objectForKey:@"DeviceState"];
                            if(((NSString *)[locations objectForKey:@"wifi"]).length){
                                [locations setValue:@"3" forKey:@"LocationType"];
                            }
                            [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[locations objectForKey:@"Altitude"] andCourse:[locations objectForKey:@"Course"] andLocationType:[locations objectForKey:@"LocationType"] andCreateTime:[locations objectForKey:@"CreateTime"] andElectricity:[locations objectForKey:@"Electricity"] andGSM:[locations objectForKey:@"GSM"] andStep:[locations objectForKey:@"Step"] andHealth:[locations objectForKey:@"Health"] andLatitude:[locations objectForKey:@"Latitude"] andLongitude:[locations objectForKey:@"Longitude"] andOnline:[locations objectForKey:@"Online"] andSatelliteNumber:[locations objectForKey:@"SatelliteNumber"] andServerTime:[locations objectForKey:@"ServerTime"] andSpeed:[locations objectForKey:@"Speed"] andUpdateTime:[locations objectForKey:@"UpdateTime"] andDeviceTime:[locations objectForKey:@"DeviceTime"]];
                        }
                        
                    }
                    deviceModel  =  [[manager isSelectFaWithDevice:[defaults objectForKey:@"selectDeviceID"]] objectAtIndex:0];
                    
                    [defaults setObject:deviceModel.BindNumber forKey:@"binnumber"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];

                }
            }
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 2)
        {
            EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
            [defaults setInteger:4 forKey:@"editWatch"];
            [nav pushViewController:vc animated:YES];
            
        }
        else if (alertView.tag == 3)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevice" object:self];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)otherOperations:(UIApplication *)application and:(NSDictionary *)launchOptions
{
    //    [NSThread sleepForTimeInterval:0.5];
    //    [_window makeKeyAndVisible];
    
    
    //    [_splashView mas_makeConstraints:^(MASConstraintMaker *make)
    //    {
    //        make.top.equalTo(_window);
    //        make.left.equalTo(_window);
    //        make.right.equalTo(_window);
    //        make.bottom.equalTo(_window);
    //    }];
    
    //    [_splashView mac]
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    defaults = [NSUserDefaults standardUserDefaults];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [defaults setObject:@"1" forKey:@"passType"];
    [defaults setObject:@"1" forKey:@"Type2"];
    [defaults setObject:@"1" forKey:@"Type3"];
    [defaults setObject:@"1" forKey:@"Type9"];
    [defaults setObject:@"1" forKey:@"goSowMain"];
    
    [defaults setInteger:1 forKey:@"loginType"];
    LoginViewController *login = [[LoginViewController alloc] init];
    
    
    //获取当前语言
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = languages[0];
    
    if([currentLanguage isEqualToString:@"zh-Hans-CN"] || [currentLanguage isEqualToString:@"zh-Hans"])
    {
        [defaults setObject:@"2" forKey:@"currentLanguage_phone"];
    }
    if([currentLanguage isEqualToString:@"zh-Hant"]|| [currentLanguage isEqualToString:@"zh-Hant-CN"] || [currentLanguage isEqualToString:@"zh-HK"])
    {
        [defaults setObject:@"3" forKey:@"currentLanguage_phone"];
        
    }
    if([currentLanguage isEqualToString:@"en"] || [currentLanguage isEqualToString:@"en-CN"])
    {
        [defaults setObject:@"1" forKey:@"currentLanguage_phone"];
    }
    
    //获取当前版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    NSString *app_Version = infoDictionary[@"CFBundleShortVersionString"];
    
    NSArray *arr =[app_Version componentsSeparatedByString:@"."];
    
    [defaults setObject:[NSString stringWithFormat:@"%d",[arr[0] intValue] * 10000 + [arr[1] intValue] * 100 +[arr[2] intValue]] forKey:@"currentVersion"] ;
    
    if([[defaults objectForKey:@"currentTimezone"] length] == 0)
    {
        [defaults setObject:@"1" forKey:@"currentTimezone"];
    }
    
    manager  = [DataManager shareInstance];
    [manager createDataBaseAndTable];
    [manager createPhoto];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0)
    {
        if([[defaults objectForKey:@"DMloginScaleKey"] intValue] == 1 && [[manager getAllFavourie] count] > 0)
        {
            LeftViewController * left = [[LeftViewController alloc]init];
            CenterViewController * main = [[CenterViewController alloc]init];
            RightViewController * right = [[RightViewController alloc]init];
            
            SideslipViewController * slide = [[SideslipViewController alloc]initWithLeftView:left andMainView:main andRightView:right andBackgroundImage:nil];
            
            [slide setSpeedf:0.5];
            
            //点击视图是是否恢复位置
            slide.sideslipTapGes.enabled = YES;
            
            nav = [[UINavigationController alloc] init];
            [nav addChildViewController:login];
            [nav initWithRootViewController:slide];
        }
        else
        {
            nav = [[UINavigationController alloc] initWithRootViewController:login];
        }
    }
    else
    {
        nav = [[UINavigationController alloc] initWithRootViewController:login];
    }
    
    [self.window setRootViewController:nav];
    
    [self.window makeKeyAndVisible];
    
    //错误日志
    [MyUncaughtExceptionHandler setDefaultHandler];
    
    // 发送崩溃日志
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *dataPath = [path stringByAppendingPathComponent:@"Exception.txt"];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    
    NSString *ErrorTontext  =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (data != nil)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"ExceptionError" andDelegate:self];
        webService.tag = 0;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"error" andValue:ErrorTontext];
        
        NSArray *parameter = @[loginParameter1];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ExceptionErrorResult"];
        
        BOOL blDele= [fileManager removeItemAtPath:dataPath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
    
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        //这里还是原来的代码
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    if(launchOptions)
    {
        NSString *message = [[launchOptions objectForKey:@"aps"]objectForKey:@"alert"];
        NSArray *array = [launchOptions objectForKey:@"Content"];
        
        [defaults setObject:[array objectAtIndex:0] forKey:@"NoType"];
        [defaults setObject:[array objectAtIndex:1] forKey:@"NODeviceID"];
        if([[defaults objectForKey:@"NoType"] intValue] == 2)
        {
            NSArray *arr =  [[array objectAtIndex:2] componentsSeparatedByString:@","];
            [defaults setObject:[arr objectAtIndex:0] forKey:@"NOUseID"];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 2;
            [alert show];
            
        }
        else if([[defaults objectForKey:@"NoType"] intValue] == 3)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 3;
            [alert show];
            
        }
        else if([[defaults objectForKey:@"NoType"] intValue] == 4)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
            
            alert.tag = 4;
            [alert show];
            
        }
        else if ([[defaults objectForKey:@"NoTyoe"] intValue] == 1)
        {
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAudio" object:[[object objectForKey:@"L"] objectForKey:@"V"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIIIIII" object:self];
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshBook" object:self];
            
        }
        
    }
    application.applicationIconBadgeNumber = 0;
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"this is iOS7 Remote Notification");

}
-(void)animationImageTwo
{
    //    [lock lock];
    KKSequenceImageView* imageView = [[KKSequenceImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    NSMutableArray* images = [NSMutableArray array];
    for (int i = 1; i <= 45; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"LunchImage_%d",i] ofType:@"png"];
        if (path.length) {
            [images addObject:path];
        }
    }
    imageView.imagePathss = images;
    imageView.durationMS = images.count * 50;
    imageView.repeatCount = 1;
    imageView.delegate = self;
    //        [_lunchView addSubview:_imageView];
    [self.window addSubview:imageView];
    [imageView begin];
    __weak typeof (self)weakSelf = self;
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)((((int)imageView.durationMS)/1000.0)/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{

        //        [UIView animateWithDuration:1 animations:^{
        //
        ////            imageView.alpha = 0;
        //        } completion:^(BOOL finished)
        //        {
        //        [lock unlock];
        [imageView removeFromSuperview];


        //        }];

    });
}







-(void)ReceiveRemoteNotification:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        
        //iOS10特有
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            
            if (granted) {
                // 点击允许
                NSLog(@"注册成功");
                [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
                    //                    NSLog(@"%@", settings);
                }];
            } else {
                // 点击不允许
                NSLog(@"注册失败");
            }
            
        }];
    }else if ([[UIDevice currentDevice].systemVersion floatValue] >8.0){
        
        //iOS8 - iOS10
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound | UIUserNotificationTypeBadge categories:nil]];
        
    }else if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        //iOS8系统以下
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
    // 注册获得device Token
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
}







// iOS 10收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    
    NSDictionary * userInfo = notification.request.content.userInfo;
    
    UNNotificationRequest *request = notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    
    
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
        
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    
    
    
}

// 通知的点击事件
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    UNNotificationRequest *request = response.notification.request; // 收到推送的请求
    UNNotificationContent *content = request.content; // 收到推送的消息内容
    
    NSNumber *badge = content.badge;  // 推送消息的角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 推送消息的声音
    NSString *subtitle = content.subtitle;  // 推送消息的副标题
    NSString *title = content.title;  // 推送消息的标题
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@", [self logDic:userInfo]);
        
    }
    else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler();  // 系统要求执行这个方法
    
    
}



- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}



- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"iOS6及以下系统，收到通知:%@", [self logDic:userInfo]);
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    
    
    NSLog(@"iOS7及以上系统，收到通知:%@", [self logDic:userInfo]);
    
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end
