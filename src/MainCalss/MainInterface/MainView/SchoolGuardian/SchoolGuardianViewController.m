//
//  SchoolGuardianViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "SchoolGuardianViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "DeviceSetModel.h"
#import "SchoolGuarduanTableViewCell.h"
#import "LXActionSheet.h"
#import "SchoolListViewController.h"
#import "XiaoquSetViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OMGToast.h"

@interface SchoolGuardianViewController ()<UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,LXActionSheetDelegate,UIAlertViewDelegate>
{
    DataManager *manager;
    DeviceModel *deviceModel;
     NSMutableArray *deviceArray;
    NSUserDefaults *defaults;
    DeviceSetModel *setModel;
    BOOL show1;
    BOOL show2;
    BOOL show3;
    BOOL show4;
    NSArray *nameArr;
    CLGeocoder *_geocoder;
    CLLocationCoordinate2D locationCar;

}
@end

@implementation SchoolGuardianViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    _geocoder=[[CLGeocoder alloc]init];

    self.closeBtn.backgroundColor = MCN_buttonColor;
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    nameArr = [[NSArray alloc] initWithObjects:NSLocalizedString(@"be_school_remind", nil),NSLocalizedString(@"out_school_remind", nil),NSLocalizedString(@"way_to_home_remind", nil),NSLocalizedString(@"be_home_remind", nil), nil];
    show1 = NO;
    show2 = NO;
    show3 = NO;
    show4 = NO;
    NSArray *array = [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    setModel = [array objectAtIndex:0];
    self.schoolLabel.text = deviceModel.SchoolAddress;
    
    self.classTime.text = [NSString stringWithFormat:@"%@:\ %@-%@ %@-%@",NSLocalizedString(@"schooltime", nil),setModel.ClassDisabled1,setModel.ClassDisabled2,setModel.ClassDisabled3,setModel.ClassDisabled4];
    
    self.laterTime.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"latest_home_time", nil),deviceModel.LatestTime];
    
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    UIButton * rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"setting", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 134;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cell1 = @"cell1";
    UINib *nib = [UINib nibWithNibName:@"SchoolGuarduanTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    SchoolGuarduanTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[SchoolGuarduanTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    cell.nameLabel.text = [nameArr objectAtIndex:indexPath.row];
    [cell.tapBren addTarget:self action:@selector(down:) forControlEvents:UIControlEventTouchUpInside];
    cell.tapBren.tag = indexPath.row;
    
    if(indexPath.row == 0)///到校迟到
    {
        if([[defaults objectForKey:@"SchoolArriveContent"] isEqualToString:@""])
        {
            //school_guardian
//            cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
            cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
            cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
            cell.downBtn.hidden = YES;
            cell.tapBren.userInteractionEnabled = NO;
            
        }
        else///不为空的情况下
        {
            NSArray *array = [[defaults objectForKey:@"SchoolArriveContent"] componentsSeparatedByString:@","];
            if([[array objectAtIndex:0] intValue] == 2)//正常
            {
//                cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
                cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
                cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
                cell.downBtn.hidden = YES;
                cell.tapBren.userInteractionEnabled = NO;
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"SchoolArriveTime"],[array objectAtIndex:1]];
                
            }
            else//报警
            {
                cell.schoolGuarImage.image = [UIImage imageNamed:@"jinggao_"];
                cell.buwanImage.image = [UIImage imageNamed:@"wan_yellow_bg"];
                cell.downBtn.hidden = NO;
                cell.tapBren.userInteractionEnabled = YES;
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"SchoolArriveTime"],[array objectAtIndex:1]];
                
            }
        }
        cell.timeLabel.text = setModel.ClassDisabled1;
    }
    else if(indexPath.row == 1)///////////////////////
    {
        if([[defaults objectForKey:@"SchoolLeaveContent"] isEqualToString:@""])
        {
//            cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
            cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
            cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
            cell.downBtn.hidden = YES;
            cell.tapBren.userInteractionEnabled = NO;
        }
        else
        {
            NSArray *array = [[defaults objectForKey:@"SchoolLeaveContent"] componentsSeparatedByString:@","];
            if([[array objectAtIndex:0] intValue] == 2)//正常
            {
                if([[array objectAtIndex:1] length ] != 0)
                {
                    cell.downBtn.hidden = NO;
                    cell.tapBren.userInteractionEnabled = YES;
                }
                else
                {
                    cell.downBtn.hidden = YES;
                    cell.tapBren.userInteractionEnabled = NO;
                }
                
//                cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
                cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
                cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
                
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"SchoolLeaveTime"],[array objectAtIndex:1]];
                
            }
            else//报警
            {
                cell.schoolGuarImage.image = [UIImage imageNamed:@"jinggao_"];
                cell.buwanImage.image = [UIImage imageNamed:@"wan_yellow_bg"];
                cell.downBtn.hidden = NO;
                cell.tapBren.userInteractionEnabled = YES;
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"SchoolLeaveTime"],[array objectAtIndex:1]];
            }
        }
        cell.timeLabel.text = setModel.ClassDisabled4;
    }
    else if(indexPath.row == 2)/////////////////////
    {
        if([[defaults objectForKey:@"RoadStayContent"] isEqualToString:@""])
        {
//            cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
            cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
            cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
            cell.downBtn.hidden = YES;
            cell.tapBren.userInteractionEnabled = NO;
            
        }
        else
        {
//            cell.schoolGuarImage.image = [UIImage imageNamed:@"jinggao_"];
            cell.buwanImage.image = [UIImage imageNamed:@"wan_yellow_bg"];
            cell.downBtn.hidden = NO;
            cell.tapBren.userInteractionEnabled = YES;
            
            NSRange range = [[defaults objectForKey:@"RoadStayContent"] rangeOfString:@"-"];
            if(range.length > 0)//多条数据的情况
            {
                NSArray *array = [[defaults objectForKey:@"RoadStayContent"] componentsSeparatedByString:@"-"];
                NSArray *timer = [[defaults objectForKey:@"RoadStayTime"] componentsSeparatedByString:@"-"];
                if(array.count == 1)
                {
                    NSArray * arr = [[array objectAtIndex:0] componentsSeparatedByString:@","];
                    if(arr.count < 4)//没有经纬度
                    {
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"RoadStayTime"],[arr objectAtIndex:1]];
                        
                    }
                    else//有经纬度
                    {
                        locationCar.latitude = [[arr objectAtIndex:2] doubleValue];
                        locationCar.longitude = [[arr objectAtIndex:3] doubleValue];
                        
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@  %@  %@\n",[defaults objectForKey:@"RoadStayTime"],[arr objectAtIndex:1],[defaults objectForKey:@"roadAddress"]];
                        //                        CLLocation *locations=[[CLLocation alloc]initWithLatitude:locationCar.latitude longitude:locationCar.longitude];
                        //
                        //                        [_geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray *placemarks, NSError *error) {
                        //                            CLPlacemark *placemark=[placemarks firstObject];
                        //
                        //                            cell.contentLabel.text = [NSString stringWithFormat:@"%@  %@  %@\n",[defaults objectForKey:@"RoadStayTime"],[arr objectAtIndex:1],placemark.name];
                        //                        }];
                    }
                }
                else//多条数据
                {
                    NSArray *arr = [[array objectAtIndex:array.count - 1 ] componentsSeparatedByString:@","];
                    if(arr.count < 4)//没有经纬度
                    {
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"RoadStayTime"],[arr objectAtIndex:1]];
                        
                    }
                    else//有经纬度
                    {
                        locationCar.latitude = [[arr objectAtIndex:2] doubleValue];
                        locationCar.longitude = [[arr objectAtIndex:3] doubleValue];
                        //CLLocation *locations=[[CLLocation alloc]initWithLatitude:locationCar.latitude longitude:locationCar.longitude];
                        cell.contentLabel.text = [NSString stringWithFormat:@"%@  %@  %@\n",[timer objectAtIndex:timer.count-1],[arr objectAtIndex:1],[defaults objectForKey:@"roadAddress"]];
                        
                        //                        [_geocoder reverseGeocodeLocation:locations completionHandler:^(NSArray *placemarks, NSError *error) {
                        //                            CLPlacemark *placemark=[placemarks firstObject];
                        //                            [defaults setValue:placemark.name forKey:@"addresslo"];
                        //
                        //                        }];
                        //
                        //  cell.contentLabel.text = [NSString stringWithFormat:@"%@  %@  %@\n",[defaults objectForKey:@"RoadStayTime"],[arr objectAtIndex:1],[defaults objectForKey:@"addresslo"]];
                    }
                    
                }
            }
        }
        
        cell.timeLabel.text = @"";
        
    }
    else if(indexPath.row == 3)
    {
        if([[defaults objectForKey:@"HomeBackContent"] isEqualToString:@""])
        {
//            cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
            cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
            cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
            cell.downBtn.hidden = YES;
            cell.tapBren.userInteractionEnabled = NO;
        }
        else
        {
            NSArray *array = [[defaults objectForKey:@"HomeBackContent"] componentsSeparatedByString:@","];
            if([[array objectAtIndex:0] intValue] == 2)//正常
            {
//                cell.schoolGuarImage.image = [UIImage imageNamed:@"Login_Button"];
                cell.schoolGuarImage.backgroundColor = MCN_buttonColor;
                cell.buwanImage.image = [UIImage imageNamed:@"wan_gray_bg"];
                if([[array objectAtIndex:1] length] != 0)
                {
                    cell.downBtn.hidden = NO;
                    cell.tapBren.userInteractionEnabled = YES;
                }
                else
                {
                    cell.downBtn.hidden = YES;
                    cell.tapBren.userInteractionEnabled = NO;
                }
                
            }
            else//报警
            {
                cell.schoolGuarImage.image = [UIImage imageNamed:@"jinggao_"];
                cell.buwanImage.image = [UIImage imageNamed:@"wan_yellow_bg"];
                cell.downBtn.hidden = NO;
                cell.tapBren.userInteractionEnabled = YES;
                cell.contentLabel.text = [NSString stringWithFormat:@"%@ %@",[defaults objectForKey:@"HomeBackTime"],[array objectAtIndex:1]];
            }
        }
        cell.timeLabel.text = deviceModel.LatestTime;
    }
    return cell;
}

- (void)showNext
{
    LXActionSheet * actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"defendinfo_set", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"schoolinfo", nil),NSLocalizedString(@"homeinfo", nil)]];
    actionSheet.tag = 0;
    [actionSheet showInView:self.view];
}

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
        if(buttonIndex == 0)
        {
            SchoolListViewController *school = [[SchoolListViewController alloc] init];
            school.title = NSLocalizedString(@"schoolinfo", nil);
            [self.navigationController pushViewController:school animated:YES];
            
        }
    else if(buttonIndex == 1)
    {
        XiaoquSetViewController *xioaoqu = [[XiaoquSetViewController alloc] init];
        xioaoqu.title = NSLocalizedString(@"homeinfo", nil);
        [self.navigationController pushViewController:xioaoqu animated:YES];
    }
}

- (void)down:(UIButton *)btn
{
    SchoolGuarduanTableViewCell *cell =  ((SchoolGuarduanTableViewCell*)[[btn   superview]superview]);
    
    cell.buwanImage.image = [UIImage imageNamed:@"bwan_yellow_bg"];

    if(btn.tag == 0)
    {
        if(show1 == NO)
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
            cell.view.hidden = NO;
            cell.view2.hidden = YES;
            show1 = YES;
            
        }
        else
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            show1 = NO;
            cell.view.hidden = YES;
            cell.view2.hidden = NO;

        }
    }
    else if(btn.tag == 1)
    {
        if(show2 == NO)
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
            cell.view.hidden = NO;
            show2 = YES;
            cell.view2.hidden = YES;

        }
        else
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            show2 = NO;
            cell.view.hidden = YES;
            cell.view2.hidden = NO;

        }
    }
    
    else if(btn.tag == 2)
    {
        if(show3 == NO)
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
            cell.view.hidden = NO;
            show3 = YES;
            cell.view2.hidden = YES;

            
        }
        else
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            show3 = NO;
            cell.view.hidden = YES;
            cell.view2.hidden = NO;

        }
    }
    else if(btn.tag == 3)
    {
        if(show4 == NO)
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"up_icon"] forState:UIControlStateNormal];
            cell.view.hidden = NO;
            show4 = YES;
            cell.view2.hidden = YES;

        }
        else
        {
            [cell.downBtn setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
            show4 = NO;
            cell.view.hidden = YES;
            cell.view2.hidden = NO;
        }
    }
    
    [self.tableView reloadData];
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = NO;
    manager = [DataManager shareInstance];
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    NSArray *array = [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    setModel = [array objectAtIndex:0];
    [self loadData];
    self.schoolLabel.text = deviceModel.SchoolAddress;
    
    self.classTime.text = [NSString stringWithFormat:@"%@ %@-%@ %@-%@",NSLocalizedString(@"schooltime", nil),setModel.ClassDisabled1,setModel.ClassDisabled2,setModel.ClassDisabled3,setModel.ClassDisabled4];
    self.laterTime.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"latest_home_time", nil),deviceModel.LatestTime];
    
    if(deviceModel.IsGuard.intValue == 0)
    {
        [self.closeBtn setTitle:NSLocalizedString(@"defind_on", nil) forState:UIControlStateNormal];
        [defaults setObject:@"0" forKey:@"inoff"];
    }
    else
    {
        [self.closeBtn setTitle:NSLocalizedString(@"defind_off", nil) forState:UIControlStateNormal];
        [defaults setObject:@"1" forKey:@"inoff"];
    }
}

- (void)loadData
{
    WebService *webService = [WebService newWithWebServiceAction:@"SchoolGuardian" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"SchoolGuardianResult"];

}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    self.closeBtn.enabled = YES;

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
                if(ws.tag == 0)
                {
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
                    
                    [defaults setObject:[object objectForKey:@"SchoolArriveContent"] forKey:@"SchoolArriveContent"];
                    [defaults setObject:[object objectForKey:@"SchoolArriveTime"]  forKey:@"SchoolArriveTime"];
                    [defaults setObject:[object objectForKey:@"SchoolLeaveContent"] forKey:@"SchoolLeaveContent"];
                    [defaults setObject:[object objectForKey:@"SchoolLeaveTime"] forKey:@"SchoolLeaveTime"];
                    [defaults setObject:[object objectForKey:@"RoadStayContent"] forKey:@"RoadStayContent"];
                    [defaults setObject:[object objectForKey:@"RoadStayTime"] forKey:@"RoadStayTime"];
                    [defaults setObject:[object objectForKey:@"HomeBackContent"] forKey:@"HomeBackContent"];
                    [defaults setObject:[object objectForKey:@"HomeBackTime"] forKey:@"HomeBackTime"];
                    
                    NSRange range = [[defaults objectForKey:@"RoadStayContent"] rangeOfString:@"-"];
                    if(range.length > 0)//多条数据的情况
                    {
                        NSArray *array = [[defaults objectForKey:@"RoadStayContent"] componentsSeparatedByString:@"-"];
                        NSArray *timer = [[defaults objectForKey:@"RoadStayTime"] componentsSeparatedByString:@"-"];
                        if(array.count == 1)
                        {
                            NSArray * arr = [[array objectAtIndex:0] componentsSeparatedByString:@","];
                            if(arr.count >= 4)//没有经纬度
                            {
                                locationCar.latitude = [[arr objectAtIndex:2] doubleValue];
                                locationCar.longitude = [[arr objectAtIndex:2] doubleValue];
                                
                                WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
                                webService.tag =1112;
                                WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                                WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
                                WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[arr objectAtIndex:2]];
                                WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[arr objectAtIndex:3]];
                                
                                NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
                                // webservice请求并获得结果
                                webService.webServiceParameter = parameter;
                                [webService getWebServiceResult:@"GetAddressResult"];

                            }
                            
                        }
                        else
                        {
                            NSArray *arr = [[array objectAtIndex:array.count - 1 ] componentsSeparatedByString:@","];
                            WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
                            webService.tag =1112;
                            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
                            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[arr objectAtIndex:2]];
                            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[arr objectAtIndex:3]];
                            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
                            // webservice请求并获得结果
                            webService.webServiceParameter = parameter;
                            [webService getWebServiceResult:@"GetAddressResult"];
                        }
                    }
                }
                else if(ws.tag == 1112)
                {
                    NSArray * address = [object objectForKey:@"Nearby"];
                    if(address.count != 0 && address.count>1)
                    {
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]] forKey:@"roadAddress"];
                    }
                    else
                    {
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]] forKey:@"roadAddress"];
                    }
                }
                else
                {
                    if([[defaults objectForKey:@"inoff"] intValue] == 0)
                    {
                        [defaults setObject:@"1" forKey:@"inoff"];
                        
                    }
                    else
                    {
                        [defaults setObject:@"0" forKey:@"inoff"];
                    }
                    
                    if([[defaults objectForKey:@"inoff"] intValue] == 0)
                    {
                        [self.closeBtn setTitle:NSLocalizedString(@"defind_on", nil) forState:UIControlStateNormal];
                        [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];

                    }
                    else
                    {
                        [self.closeBtn setTitle:NSLocalizedString(@"defind_off", nil) forState:UIControlStateNormal];
                        [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];

                    }
                    [manager updataSQL:@"favourite_info" andType:@"IsGuard" andValue:[defaults objectForKey:@"inoff"] andBindle:[defaults objectForKey:@"binnumber"]];
                }
                [self.tableView reloadData];
                
            }
            else
            {
                [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];

            }
        }
    }
}

- (void)viewDidAppear
{
  }

- (IBAction)close:(id)sender {
    
    UIAlertView *alertView;
    
    if([[defaults objectForKey:@"inoff"] intValue] == 0)
    {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_you_want_to_open_to_go_to_school", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
    }
    else
    {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"sure_you_want_to_close_to_go_to_school", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];

    }
    [alertView show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        WebService *webService = [WebService newWithWebServiceAction:@"UpdateGuard" andDelegate:self];
        webService.tag = 1;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
        WebServiceParameter *loginParameter3;
        if([[defaults objectForKey:@"inoff"] intValue] == 0)
        {
            loginParameter3 = [WebServiceParameter newWithKey:@"offOn" andValue:@"1"];
        }
        else
        {
            loginParameter3 = [WebServiceParameter newWithKey:@"offOn" andValue:@"0"];
            
        }
        
        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        self.closeBtn.enabled = NO;
        [webService getWebServiceResult:@"UpdateGuardResult"];
    }
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
