//
//  DialingnNmberController.m
//  KuBaoBei
//
//  Created by 李晓博 on 2018/1/3.
//  Copyright © 2018年 HH. All rights reserved.
//

#import "DialingNumberController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "DeviceModel.h"
#import "DataManager.h"
#import "SBJsonParser.h"
#import "JSON.h"
#import "OMGToast.h"
@interface DialingNumberController ()<WebServiceProtocol>

@end

@implementation DialingNumberController
{
    NSUserDefaults* defaults;
    DeviceModel* deviceModel;
    NSString* messageID;
    NSString* callID;
    BOOL isCall;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    messageID = @"";
    callID = @"";
    defaults = [[NSUserDefaults alloc]init];
    DataManager* manager = [DataManager shareInstance];
    NSArray* deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    //    deviceModel = [[DeviceModel alloc]init];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
      dispatch_async(dispatch_get_main_queue(), ^{
          [self callCloudPlatform];
      });
    // Do any additional setup after loading the view.
    
}
-(void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)dismissAction:(id)sender
{
    isCall = NO;
    WebService *webService = [WebService newWithWebServiceAction:@"CallDeviceCancel" andDelegate:self];
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    WebServiceParameter *parameter3 = [WebServiceParameter newWithKey:@"messageID" andValue:messageID];
    WebServiceParameter *parameter4 = [WebServiceParameter newWithKey:@"callID" andValue:callID];
        NSArray *parameter = @[loginParameter1,parameter2,parameter3,parameter4];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
    
        [webService getWebServiceResult:@"CallDeviceCancelResult"];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)callCloudPlatform
{
//    __weak typeof(self) weakSelf = self;
        isCall = YES;
        WebService *webService = [WebService newWithWebServiceAction:@"CallDevice" andDelegate:self];
//        webService.delegate = weakSelf;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
        WebServiceParameter *parameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
        NSArray *parameter = @[loginParameter1,parameter2];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        
        [webService getWebServiceResult:@"CallDeviceResult"];


}
//- (void)WebServiceGetCompleted:(id)theWebService;
- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService *ws = theWebService;
    if ([[theWebService soapResults] length] > 0)
    {
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        NSString *res=[theWebService soapResults];
        id object = [parser objectWithString: res error:&error];
        NSString *result =[[ NSString alloc] initWithData:ws.webData encoding:NSUTF8StringEncoding];
        if (!error && object)
        {
            
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
            if (isCall) {
                if (code == 1)
                {
                    NSDictionary* body = [object valueForKey:@"Body"];
                    messageID = [body valueForKey:@"messageID"];
                    callID = [body valueForKey:@"callID"];
                    NSLog(@"拨打成功");
                }else
                {
                    NSString* message = [object valueForKey:@"Message"];
                    [OMGToast showWithText:NSLocalizedString(message, nil)  bottomOffset:50 duration:2];
                }
            }else
            {
//                NSString* message = [object valueForKey:@"Message"];
//                [OMGToast showWithText:NSLocalizedString(message, nil)  bottomOffset:50 duration:2];
            }
        
        }
    }
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
