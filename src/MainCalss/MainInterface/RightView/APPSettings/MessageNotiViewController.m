//
//  MessageNotiViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MessageNotiViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"

@interface MessageNotiViewController ()
{
    NSUserDefaults *defaults;
}
@end

@implementation MessageNotiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    self.save_Btn.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    if([[defaults objectForKey:@"Notification"] intValue] == 1)
    {
        self.on3.on = YES;
    }
    else
    {
        self.on3.on = NO;

    }
    
    if([[defaults objectForKey:@"NotificationSound"] intValue] == 1)
    {
        self.on1.on = YES;
    }
    else
    {
        self.on1.on = NO;

    }
    
    if([[defaults objectForKey:@"NotificationVibration"] intValue] == 1)
    {
        self.on2.on = YES;
    }
    else
    {
        self.on2.on = NO;
    }
    
    self.receive_new_message.text = NSLocalizedString(@"receive_new_message", nil);
    self.sound_Label.text = NSLocalizedString(@"phone_sound", nil);
    self.ord_Label.text = NSLocalizedString(@"phone_vibrate", nil);
    [self.save_Btn setTitle:NSLocalizedString(@"save", nil) forState:UIControlStateNormal];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    
    WebService *webService = [WebService newWithWebServiceAction:@"UpdateNotification" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"notification" andValue:self.on3.isOn == YES ? @"1" :@"0"];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"notificationSound" andValue:self.on1.isOn == YES?@"1":@"0"];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"notificationVibration" andValue:self.on2.isOn == YES ? @"1" :@"0"];
    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4];
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"UpdateNotificationResult"];

}

- (void)WebServiceGetCompleted:(id)theWebService
{
    WebService * ws = theWebService;
    if ([[theWebService soapResults] length] > 0) {////
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSError *error = nil;
        // 解析成json数据
        id object = [parser objectWithString:[theWebService soapResults] error:&error];
        if (!error && object) {///
            // 获得状态
            int code = [[object objectForKey:@"Code"] intValue];
                //注册成功
                if(code == 1)
                {
                    [defaults setObject:self.on1.isOn == YES ? @"1" : @"0" forKey:@"NotificationSound"];
                    [defaults setObject:self.on2.isOn == YES ? @"1" : @"0" forKey:@"NotificationVibration"];
                    [defaults setObject:self.on3.isOn == YES ? @"1" : @"0" forKey:@"Notification"];
                    
                    [OMGToast showWithText:NSLocalizedString(@"edit_suc", nil) bottomOffset:50 duration:1];
                    [self.navigationController popViewControllerAnimated:YES];
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
            [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:1];
        }
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
