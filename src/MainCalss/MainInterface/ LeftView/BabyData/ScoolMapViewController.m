//
//  ScoolMapViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "ScoolMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "YCAnnotationVIew.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "OMGToast.h"
#import "SearchViewController.h"
#import "LoginViewController.h"

@interface ScoolMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,WebServiceProtocol>

{
    CLGeocoder *_geocoder;
    int mapType;
    NSUserDefaults *defaults;
    DeviceModel *model;
    NSMutableArray *array;
    MKCoordinateSpan theSpan;
    DataManager *manager;
    CLLocationCoordinate2D myLocation;
    UIButton* rightBtn;
    NSMutableArray *nameArr;
    CLLocationCoordinate2D coor;
}
@end

@implementation ScoolMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _geocoder=[[CLGeocoder alloc]init];
    nameArr = [[NSMutableArray alloc] init];
    mapType = 0;
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.saveBuuton.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
     [rightBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn addTarget:self action:@selector(showlocation) forControlEvents:UIControlEventTouchDown];

    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    [self.mapView reloadInputViews];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Tap:)];
    [self.mapView addGestureRecognizer:tap];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    [self.saveBuuton setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
   }

- (void)showlocation
{
  //  self.mapView.showsUserLocation = YES;
  
}

- (void)showSearch
{
    rightBtn.enabled = NO;
    nameArr = [[NSMutableArray alloc] init];
    CLLocationCoordinate2D myLocatio = CLLocationCoordinate2DMake([defaults doubleForKey:@"myLa"], [defaults doubleForKey:@"myLo"]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(myLocatio, 5000, 5000);
    
    [defaults setDouble:[defaults doubleForKey:@"myLa"] forKey:@"mylocationLa"];
    [defaults setDouble:[defaults doubleForKey:@"myLo"] forKey:@"mylocationLo"];
    [defaults setValue:@"0" forKey:@"search"];
    //初始化一个检索请求对象
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    //设置检索参数
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery=@"学校";
    //初始化检索
    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
    //开始检索，结果返回在block中
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        //兴趣点节点数组
        NSArray * arr = [NSArray arrayWithArray:response.mapItems];
        for (int i=0; i<arr.count; i++) {
            MKMapItem * item=arr[i];
            MKPointAnnotation * point = [[MKPointAnnotation alloc]init];
            point.title=item.name;
            point.subtitle=item.phoneNumber;
            point.coordinate=item.placemark.coordinate;
            [nameArr addObject:item];
            NSLog(@"%@",item.name);
            
        }
        
        SearchViewController *search = [[SearchViewController alloc] init];
        
        search.title = NSLocalizedString(@"nearby_school", nil);
        
        search.myLocation = myLocation;
        search.nameArr = nameArr;
        
        [self.navigationController pushViewController:search animated:YES];
        
    }];
}

- (void)Tap:(UITapGestureRecognizer *)tap
{
    
    self.saveBuuton.enabled = NO;
    self.addressLabel.text = NSLocalizedString(@"get_location", nil);
    
    CGPoint point = [tap locationInView:_mapView];
    
    //要把视图上的位置 转化为经纬度的位置
    CLLocationCoordinate2D coordinate = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    //创建大头针
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = coordinate;
    MKOverlayView *overlayView = [[MKOverlayView alloc] init];
    MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
    
    [_mapView removeOverlays:_mapView.overlays];
    [_mapView removeAnnotations:_mapView.annotations];
    [_mapView addAnnotation:annotation];
    [_mapView addOverlay:circleTargePlace];
    coor = coordinate;
    WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
    webService.tag =1112;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
    
    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetAddressResult"];

}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if (annotation == mapView.userLocation)

        return nil;
    //大头针视图
    //注意：为了提高显示效率。显示大头针加入复用机制
    static NSString *annotationId = @"ann";
    YCAnnotationVIew *pin = (YCAnnotationVIew *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if(pin == nil){
        
        pin = [[YCAnnotationVIew alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
    }
    pin.image = [UIImage imageNamed:@"school_pin"];
    //设置中心点偏移，使得标注底部中间点成为经纬度对应点
    //pin.centerOffset = CGPointMake(0, -18);
    
    return pin;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *_circleView=[[MKCircleView alloc] initWithCircle:overlay];
        _circleView.fillColor =  [UIColor colorWithRed:137/255.0 green:170/255.0 blue:213/255.0 alpha:0.2];
        _circleView.strokeColor = [UIColor colorWithRed:117/255.0 green:161/255.0 blue:220/255.0 alpha:0.8];
        _circleView.lineWidth=2.0;
        return _circleView;
    }
    return nil;
}

- (IBAction)Zomm:(id)sender {
    
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta/2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta/2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)Zemm:(id)sender {
    if (self.mapView.region.span.latitudeDelta>60||self.mapView.region.span.longitudeDelta>60) {
        return;
    }
    theSpan.latitudeDelta=self.mapView.region.span.latitudeDelta*2;
    
    theSpan.longitudeDelta=self.mapView.region.span.longitudeDelta*2;
    
    MKCoordinateRegion theRegion;
    
    theRegion.center=[self.mapView centerCoordinate];
    
    theRegion.span=theSpan;
    
    [self.mapView setRegion:theRegion];
}

- (IBAction)maoType:(id)sender {
    
    if(mapType==0)
    {
        mapType=1;
        [self.mapButton setBackgroundImage:[UIImage imageNamed:@"planar_map"] forState:UIControlStateNormal];
        [self.mapView setMapType:MKMapTypeSatellite];
    }else{
        [self.mapButton setBackgroundImage:[UIImage imageNamed:@"satellite_maps"] forState:UIControlStateNormal];
        mapType=0;
        [self.mapView setMapType:MKMapTypeStandard];
    }
}

- (IBAction)saveBtn:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:model.DeviceID];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"schoolAddress" andValue:[defaults objectForKey:@"schoolAddress"]];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"schoolLat" andValue:[defaults objectForKey:@"school_coordinate_latitude"]];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"schoolLng" andValue:[defaults objectForKey:@"school_coordinate_longitude"]];
    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3, loginParameter4,loginParameter5];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateDeviceResult"];
    
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
                if(ws.tag == 0)
                {
                    [manager updataSQL:@"favourite_info" andType:@"SchoolAddress" andValue:[defaults objectForKey:@"schoolAddress"] andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"favourite_info" andType:@"SchoolLat" andValue:[defaults objectForKey:@"school_coordinate_latitude"]andBindle:[defaults objectForKey:@"binnumber"]];
                    [manager updataSQL:@"favourite_info" andType:@"SchoolLng" andValue:[defaults objectForKey:@"school_coordinate_longitude"]andBindle:[defaults objectForKey:@"binnumber"]];
                    
                    [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:2];
                    
                    [self.navigationController popViewControllerAnimated:YES];

                }
                else
                {
                    NSArray * address = [object objectForKey:@"Nearby"];
                    if(address.count != 0 && address.count>1)
                    {
                        self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]];
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@,%@,%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"],[[address objectAtIndex:0] objectForKey:@"POI"],[[address objectAtIndex:1] objectForKey:@"POI"]] forKey:@"schoolAddress"];
                    }
                    else
                    {
                        self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]];
                        [defaults setObject:[NSString stringWithFormat:@"%@%@%@%@",[object objectForKey:@"Province"],[object objectForKey:@"City"],[object objectForKey:@"District"],[object objectForKey:@"Road"]] forKey:@"schoolAddress"];
                    }
                    
                    [defaults setDouble:coor.latitude forKey:@"school_coordinate_latitude"];
                    [defaults setDouble:coor.longitude forKey:@"school_coordinate_longitude"];
                    
                    self.saveBuuton.enabled = YES;
                }
            }
            else if(code == 0)
            {
                if(ws.tag != 1112)
                {
                    [OMGToast showWithText:NSLocalizedString(@"abnormal_login", nil) bottomOffset:50 duration:3];
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                else
                {
                    [OMGToast showWithText:NSLocalizedString(@"select_right_location", nil) bottomOffset:50 duration:3];
                }
            }
            else
            {
                if(ws.tag == 0)
                {
                    [OMGToast showWithText:NSLocalizedString(@"edit_fail", nil) bottomOffset:50 duration:3];
                }
            }
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    rightBtn.enabled = YES;
    
    self.mapView.showsUserLocation = NO;
    
    manager = [DataManager shareInstance];
    nameArr = [[NSMutableArray alloc] init];
    
    array =   [manager isSelect:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    if([[defaults objectForKey:@"schoolMapType"] intValue] == 0)
    {
        //获取用户的位置
        CLLocationCoordinate2D co =  _mapView.userLocation.coordinate;
        
        NSLog(@"long = %f,lan = %f",co.longitude,co.latitude);
        
        if(model.SchoolAddress.length != 0)
        {
            CLLocationCoordinate2D coordinate;       //创建大头针
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            coordinate.latitude = model.SchoolLat.doubleValue;
            coordinate.longitude = model.SchoolLng.doubleValue;
            MKOverlayView *overlayView = [[MKOverlayView alloc] init];
            MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
            [_mapView addOverlay:circleTargePlace];
            
            annotation.coordinate = coordinate;
            
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:annotation];
            [_mapView addOverlay:circleTargePlace];
            
            theSpan.latitudeDelta=0.01;
            
            theSpan.longitudeDelta=0.01;
            
            MKCoordinateRegion theRegion;
            
            theRegion.center= coordinate;
            
            theRegion.span=theSpan;
            
            [self.mapView setRegion:theRegion];
            self.addressLabel.text = model.SchoolAddress;
            
        }
        else
        {
            [self.mapView showsUserLocation];
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([defaults doubleForKey:@"myLa"], [defaults doubleForKey:@"myLo"]);
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            MKOverlayView *overlayView = [[MKOverlayView alloc] init];
            annotation.coordinate = coordinate;

            MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
            [_mapView removeOverlays:_mapView.overlays];
            [_mapView removeAnnotations:_mapView.annotations];
            [_mapView addAnnotation:annotation];
            [_mapView addOverlay:circleTargePlace];
            
            theSpan.latitudeDelta=0.01;
            
            theSpan.longitudeDelta=0.01;
            
            MKCoordinateRegion theRegion;
            
            theRegion.center= coordinate;
            
            theRegion.span=theSpan;
            
            [self.mapView setRegion:theRegion];
            
            WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
            webService.tag =1112;
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
            WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
            
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"GetAddressResult"];
        }
    }
    else if([[defaults objectForKey:@"schoolMapType"] intValue] == 1)
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"schoolMapLa"];
        coordinate.longitude = [defaults doubleForKey:@"schoolMapLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"school_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"school_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
      
        
        annotation.coordinate = coordinate;
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView addOverlay:circleTargePlace];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        self.addressLabel.text = [defaults objectForKey:@"schoolMapNa"];
        [defaults setObject:self.addressLabel.text forKey:@"schoolAddress"];
        
    }
    else if([[defaults objectForKey:@"schoolMapType"] intValue] == 2)
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"schoolMapLa"];
        coordinate.longitude = [defaults doubleForKey:@"schoolMapLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"school_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"school_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
        annotation.coordinate = coordinate;
        
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView addOverlay:circleTargePlace];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        
        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
        webService.tag =1112;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
        
        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"GetAddressResult"];

        
//        CLLocation *location=[[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
//        [_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//            CLPlacemark *placemark=[placemarks firstObject];
//            self.addressLabel.text = [NSString stringWithFormat:@"%@",placemark.name];
//            [defaults setObject:self.addressLabel.text forKey:@"schoolAddress"];
//            
//        }];
    }
    else
    {
        CLLocationCoordinate2D coordinate;       //创建大头针
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        
        coordinate.latitude = [defaults doubleForKey:@"mylocationLa"];
        coordinate.longitude = [defaults doubleForKey:@"mylocationLo"];
        
        [defaults setDouble:coordinate.latitude forKey:@"school_coordinate_latitude"];
        [defaults setDouble:coordinate.longitude forKey:@"school_coordinate_longitude"];
        MKOverlayView *overlayView = [[MKOverlayView alloc] init];
        MKCircle *circleTargePlace=[MKCircle circleWithCenterCoordinate:coordinate radius:500];
                
        annotation.coordinate = coordinate;
        [_mapView removeOverlays:_mapView.overlays];
        [_mapView removeAnnotations:_mapView.annotations];
        [_mapView addAnnotation:annotation];
        [_mapView addOverlay:circleTargePlace];
        
        theSpan.latitudeDelta=0.01;
        
        theSpan.longitudeDelta=0.01;
        
        MKCoordinateRegion theRegion;
        
        theRegion.center= coordinate;
        
        theRegion.span=theSpan;
        
        [self.mapView setRegion:theRegion];
        
        WebService *webService = [WebService newWithWebServiceAction:@"GetAddress" andDelegate:self];
        webService.tag =1112;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"mapType" andValue:@"1"];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"lat" andValue:[NSString stringWithFormat:@"%lf",coordinate.latitude]];
        WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"lng" andValue:[NSString stringWithFormat:@"%lf",coordinate.longitude]];
        
        NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"GetAddressResult"];

    }
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
    {
        self.mapView.showsScale = YES;
    }
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    myLocation = [userLocation coordinate];
    //放大地图到自身的经纬度位置。
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
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
