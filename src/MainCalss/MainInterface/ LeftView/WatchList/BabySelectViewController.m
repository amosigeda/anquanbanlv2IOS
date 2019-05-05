//
//  BabySelectViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "BabySelectViewController.h"
#import "BabySelectTableViewCell.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LocationModel.h"
#import "LoginViewController.h"
#import "DeviceSetModel.h"


@interface BabySelectViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_dataArray;
    DataManager *manager;
    DeviceModel *model;
    NSUserDefaults *defaults;
    NSTimer *timer;
    NSArray *classStar;
    NSArray *classStop;
    NSMutableArray *addd;
    DeviceSetModel *SetModel;
}
@end

@implementation BabySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    _dataArray =[[NSMutableArray alloc] init];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.taleView.delegate = self;
    self.taleView.dataSource = self;
    self.taleView.rowHeight = 76;
    self.automaticallyAdjustsScrollViewInsets = NO;

    manager = [DataManager shareInstance];
    _dataArray =  [manager getAllFavourie];
    addd = [[NSMutableArray alloc] init];
    for(int i = 0; i < _dataArray.count;i++)
    {
        if(i > 0)
        {
            DeviceModel *model1 = [_dataArray objectAtIndex:i-1];
            DeviceModel *model2 = [_dataArray objectAtIndex:i];
            
            if(model2.DeviceID.intValue != model1.DeviceID.intValue)
            {
                [addd addObject:[_dataArray objectAtIndex:i]];
            }
     
        }
        else
        {
            [addd addObject:[_dataArray objectAtIndex:0]];
        }
    }
    
   // timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshDevice) userInfo:nil repeats:YES];
}

- (void)refreshDevice
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceList" andDelegate:self];
    webService.tag = 5;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceListResult"];
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
                NSArray *array = [object objectForKey:@"deviceList"];
                
                for(int i =0 ; i < array.count;i++)
                {
                    
                    NSDictionary *dic  = [array objectAtIndex:i];
                    
                    if([manager isFavourite:[dic objectForKey:@"BindNumber"]])
                    {
                    }
                    else
                    {
#pragma mark - 写入设备信息表
                        [manager addFavourite:[dic objectForKey:@"ActiveDate"]
                                  andBabyName:[dic objectForKey:@"BabyName"] andBindNumber:[dic objectForKey:@"BindNumber"] andDeviceType:[dic objectForKey:@"DeviceType"] andBirthday:[dic objectForKey:@"Birthday"] andCreateTime:[dic objectForKey:@"CreateTime"] andCurrentFirmware:[dic objectForKey:@"CurrentFirmware"] andDeviceID:[dic objectForKey:@"DeviceID"] andDeviceModelID:[dic objectForKey:@"DeviceModelID"] andFirmware:[dic objectForKey:@"Firmware"] andGender:[dic objectForKey:@"Gender"] andGrade:[dic objectForKey:@"Grade"] andHireExpireDate:[dic objectForKey:@"HireExpireDate"] andDate:[dic objectForKey:@"Date"] andHomeAddress:[dic objectForKey:@"HomeAddress"] andHomeLat:[dic objectForKey:@"HomeLat"] andHomeLng:[dic objectForKey:@"HomeLng"] andIsGuard:[dic objectForKey:@"IsGuard"] andPassword:[dic objectForKey:@"Password"] andPhoneCornet:[dic objectForKey:@"PhoneCornet"] andPhoneNumber:[dic objectForKey:@"PhoneNumber"] andPhoto:[dic objectForKey:@"Photo"] andSchoolAddress:[dic objectForKey:@"SchoolAddress"] andSchoolLat:[dic objectForKey:@"SchoolLat"] andSchoolLng:[dic objectForKey:@"SchoolLng"] andSerialNumber:[dic objectForKey:@"SerialNumber"] andUpdateTime:[dic objectForKey:@"UpdateTime"] andUserId:[dic objectForKey:@"UserId"] andSetVersionNO:[dic objectForKey:@"SetVersionNO"]  andContactVersionNO:[dic objectForKey:@"ContactVersionNO"]  andOperatorType:[dic objectForKey:@"OperatorType"]  andSmsNumber:[dic objectForKey:@"SmsNumber"]  andSmsBalanceKey:[dic objectForKey:@"SmsBalanceKey"]  andSmsFlowKey:[dic objectForKey:@"SmsFlowKey"] andLatestTime:[dic objectForKey:@"LatestTime"] ];
                        
#pragma mark - 写入设备设置表
                        
                        NSDictionary *set = [dic objectForKey:@"DeviceSet"];
                        NSArray *setInfo = [[set objectForKey:@"SetInfo"] componentsSeparatedByString:@"-"];
                        
                        classStar = [[set objectForKey:@"ClassDisabled1"] componentsSeparatedByString:@"-"];
                        
                        
                        classStop = [[set objectForKey:@"ClassDisabled2"] componentsSeparatedByString:@"-"];
                        
                        [manager addDeviceSetTable:[dic objectForKey:@"BindNumber"]  andVersionNumber:nil andAutoAnswer:[setInfo objectAtIndex:11]  andReportCallsPosition:[setInfo objectAtIndex:10] andBodyFeelingAnswer:[setInfo objectAtIndex:9] andExtendEmergencyPower:[setInfo objectAtIndex:8] andClassDisable:[setInfo objectAtIndex:7] andTimeSwitchMachine:[setInfo objectAtIndex:6] andRefusedStrangerCalls:[setInfo objectAtIndex:5] andWatchOffAlarm:[setInfo objectAtIndex:4] andWatchCallVoice:[setInfo objectAtIndex:3] andWatchCallVibrate:[setInfo objectAtIndex:2] andWatchInformationSound:[setInfo objectAtIndex:1] andWatchInformationShock:[setInfo objectAtIndex:0] andClassDisabled1:[classStar objectAtIndex:0] andClassDisabled2:[classStar objectAtIndex:1] andClassDisabled3:[classStop objectAtIndex:0] andClassDisabled4:[classStop objectAtIndex:1] andWeekDisabled:[set objectForKey:@"WeekDisabled"] andTimerOpen:[set objectForKey:@"TimerOpen"] andTimerClose:[set objectForKey:@"TimerClose"] andBrightScreen:[set objectForKey:@"BrightScreen"] andweekAlarm1:[set objectForKey:@"WeekAlarm1"] andweekAlarm2:[set objectForKey:@"WeekAlarm2"] andweekAlarm3:[set objectForKey:@"WeekAlarm3"] andalarm1:[set objectForKey:@"Alarm1"] andalarm2:[set objectForKey:@"Alarm2"] andalarm3:[set objectForKey:@"Alarm3"] andlocationMode:[set objectForKey:@"LocationMode"] andlocationTime:[set objectForKey:@"LocationTime"] andflowerNumber:[set objectForKey:@"FlowerNumber"] andStepCalculate:[set objectForKey:@"StepCalculate"] andSleepCalculate:[set objectForKey:@"SleepCalculate"] andHrCalculate:[set objectForKey:@"HrCalculate"] andSosMsgswitch:[set objectForKey:@"SosMsgswitch"] andTimeZone:@"" andLanguage:@""];
                        
#pragma mark - 写入联系人表
                        
                        NSArray *contact = [dic objectForKey:@"ContactArr"];
                        for(int i = 0; i < contact.count;i++)
                        {
                            NSDictionary *con = [contact objectAtIndex:i];
                            
                            [manager addContactTable:[dic objectForKey:@"BindNumber"] andDeviceContactId:[con objectForKey:@"DeviceContactId"] andRelationship:[con objectForKey:@"Relationship"] andPhoto:[con objectForKey:@"Photo"] andPhoneNumber:[con objectForKey:@"PhoneNumber"] andPhoneShort:[con objectForKey:@"PhoneShort"] andType:[con objectForKey:@"Type"] andObjectId:[con objectForKey:@"ObjectId"] andHeadImg:[con objectForKey:@"HeadImg"]];
                        }
                        
#pragma mark - 写入位置表
                        NSDictionary *location = [dic objectForKey:@"DeviceState"];
                        if(((NSString *)[location objectForKey:@"wifi"]).length){
                            [location setValue:@"3" forKey:@"LocationType"];
                        }
                        [manager addLocationDeviceID:[dic objectForKey:@"DeviceID"] andAltitude:[location objectForKey:@"Altitude"] andCourse:[location objectForKey:@"Course"] andLocationType:[location objectForKey:@"LocationType"] andCreateTime:[location objectForKey:@"CreateTime"] andElectricity:[location objectForKey:@"Electricity"] andGSM:[location objectForKey:@"GSM"] andStep:[location objectForKey:@"Step"] andHealth:[location objectForKey:@"Health"] andLatitude:[location objectForKey:@"Latitude"] andLongitude:[location objectForKey:@"Longitude"] andOnline:[location objectForKey:@"Online"] andSatelliteNumber:[location objectForKey:@"SatelliteNumber"] andServerTime:[location objectForKey:@"ServerTime"] andSpeed:[location objectForKey:@"Speed"] andUpdateTime:[location objectForKey:@"UpdateTime"]  andDeviceTime:[location objectForKey:@"DeviceTime"]];
                        
                        _dataArray = [manager getAllFavourie];
                        
                        for(int i = 0; i < _dataArray.count;i++)
                        {
                            if(i > 0)
                            {
                                DeviceModel *model1 = [_dataArray objectAtIndex:i-1];
                                DeviceModel *model2 = [_dataArray objectAtIndex:i];
                                
                                if(model2.DeviceID.intValue != model1.DeviceID.intValue)
                                {
                                    [addd addObject:[_dataArray objectAtIndex:i]];
                                }
                                
                            }
                            else
                            {
                                [addd addObject:[_dataArray objectAtIndex:0]];
                            }
                        }

                    }
                  
                    [self.taleView reloadData];
                }
            }
            else if(code == 0)
            {
                [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    if(timer)
    {
        [timer invalidate];
        timer=nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return addd.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"babySelect";
    
    UINib *nib = [UINib nibWithNibName:@"BabySelectTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    BabySelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[BabySelectTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    
    model = [addd objectAtIndex:indexPath.row];
   
    if([model.Photo isEqualToString:@""])
    {
        cell.headView.image = [UIImage imageNamed:@"user_head_normal"];
    }
    else
    {

        [cell.headView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPS, PHOTO,model.Photo]]];

    }
    
    if([model.BabyName isEqualToString:@""])
    {
        cell.nameLabel.text = NSLocalizedString(@"baby", nil);
    }
    else
    {
        cell.nameLabel.text = model.BabyName;
    }
    
    if([model.BindNumber isEqualToString:[defaults objectForKey:@"binnumber"]])
    {
        cell.gouView.hidden = NO;

    }
    else
    {
        cell.gouView.hidden = YES;

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    model = [addd objectAtIndex:indexPath.row];
    
    SetModel = [[manager isSelectDeviceSetTable:model.BindNumber] objectAtIndex:0];
    [defaults setObject:SetModel.TimeZone forKey:@"currentTimezone"];
    [defaults setObject:SetModel.Language forKey:@"currentLanguage"];

    [defaults setObject:model.SmsBalanceKey forKey:@"huafei"];
    [defaults setObject:model.SmsFlowKey forKey:@"liuliang"];
    
    [defaults setObject:model.BindNumber forKey:@"binnumber"];
    [defaults setObject:model.DeviceID forKey:@"loginDeviceID"];

    NSMutableArray *time = [manager isSelectLocationTable:model.DeviceID];
    LocationModel *Locmodel = [time objectAtIndex:0];
    [defaults setObject:Locmodel.ServerTime forKey:@"ServerTime"];
    [defaults setObject:Locmodel.Latitude  forKey:@"Latitude"];
    [defaults setObject:Locmodel.Longitude forKey:@"Longitude"];
    [defaults setObject:Locmodel.LocationType forKey:@"LocationType"];
    BabySelectTableViewCell *cell = [self.taleView cellForRowAtIndexPath:indexPath];
    cell.gouView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeHeadImage" object:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
