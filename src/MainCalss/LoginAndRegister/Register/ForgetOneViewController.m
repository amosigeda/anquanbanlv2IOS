//
//  ForgetOneViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "ForgetOneViewController.h"
#import "ResignTwoViewController.h"
#import "ForgetTwoViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "LoginViewController.h"
#import "CommonCrypto/CommonDigest.h"
#import "SYQRCodeViewController.h"
#import "UIColor+HEX.h"

NSString *qrcode_str;

@interface ForgetOneViewController ()<WebServiceProtocol,UITextFieldDelegate>
{
    NSUserDefaults *defaults;
    SYQRCodeViewController *vc;
    
}
@end

@implementation ForgetOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bgview.layer.borderWidth = 1;
    self.bgview.layer.borderColor = [[UIColor colorWithHexString:@"33CBCB"] CGColor];
    
    defaults = [NSUserDefaults standardUserDefaults];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barTintColor =  [UIColor groupTableViewBackgroundColor];
//    self.next_Btn.backgroundColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor darkGrayColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"forgotPwd_left"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.phoneNumberTextField.delegate = self;
    self.phoneNumberTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    if([defaults integerForKey:@"reforType"] == 1)
    {
        self.listLabel.hidden = YES;
    }
    else
    {
        self.listLabel.hidden = NO;
    }
    
    self.phone_Label.text = NSLocalizedString(@"input_reg_num", nil);
    self.phoneNumberTextField.placeholder = NSLocalizedString(@"input_reg_phone", nil);
    
    self.prompt.text =NSLocalizedString(@"input_reg_prompt", nil);

    [self.next_Btn setTitle:NSLocalizedString(@"next", nil) forState:UIControlStateNormal];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doNext:(id)sender {
    
    [self.phoneNumberTextField resignFirstResponder];
    
//    if(self.phoneNumberTextField.text.length != 11)
//    {
//        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
//
//        return;
//    }
    if (![self.phoneNumberTextField.text isValidateMobile:self.phoneNumberTextField.text])
    {
        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:4];
        return;
    }
    [self ForgetshowAddView];
    
    /*
    WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumberTextField.text];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
    NSArray *parameter = @[loginParameter1,loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"ForgotCheckResult"];
     */
    
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
            
            if(ws.tag == 0)
            {
                //注册成功
                if(code == 1)
                {
                    [defaults setObject:@"Message" forKey:@"Message"];
                    [defaults setObject:self.phoneNumberTextField.text forKey:@"phoneNum"];
                    if([defaults integerForKey:@"reforType"] == 0)
                    {
                        ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_code", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    else{
                        ForgetTwoViewController *resign = [[ForgetTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_password", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    
                }
                else if(code == 3)
                {
                }
                else if(code == 0)
                {
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                
                if(code != 1)
                {
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }
            }//
            else
            {
                if(code == 1)
                {
                    [defaults setObject:[object objectForKey:@"Check"] forKey:@"Check"];
                    [defaults setObject:@"Message" forKey:@"Message"];
                    [defaults setObject:self.phoneNumberTextField.text forKey:@"phoneNum"];
                    if([defaults integerForKey:@"reforType"] == 0)
                    {
                        ResignTwoViewController *resign = [[ResignTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_code", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                    else{
                        ForgetTwoViewController *resign = [[ForgetTwoViewController alloc] init];
                        resign.title = NSLocalizedString(@"get_password", nil);
                        [self.navigationController pushViewController:resign animated:YES];
                    }
                }
                else if(code == 3)
                {
                    ForgetOneViewController *resign = [[ForgetOneViewController alloc] init];
                    resign.title = NSLocalizedString(@"forget_password", nil);
                    [self.navigationController pushViewController:resign animated:YES];

                }
                else if(code == 0)
                {
                    LoginViewController *vc = [[LoginViewController alloc] init];
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                else if(code == -2)
                {
                    ForgetOneViewController *resign = [[ForgetOneViewController alloc] init];
                    resign.title = NSLocalizedString(@"forget_password", nil);
                    [self.navigationController pushViewController:resign animated:YES];
                }
                    
                if(code != 1)
                {
                    
                    [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
                }
            }//
            
        }///
        
    }////
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
}

- (void)ForgetshowAddView
{
    [defaults setInteger:1 forKey:@"editWatch"];
    
    SYQRCodeViewController *qrcodevc = [[SYQRCodeViewController alloc] init];
    qrcodevc.title =NSLocalizedString(@"scans", nil);
    qrcodevc.SYQRCodeSuncessBlock = ^(SYQRCodeViewController *aqrvc,NSString *qrString){
        vc = aqrvc;
        
        if([qrString rangeOfString:@"?"].location != NSNotFound)
        {
            [defaults setObject:[[qrString componentsSeparatedByString:@"?"] objectAtIndex:1] forKey:@"bindNumber"];
        }
        else if(([qrString rangeOfString:@"/"].location != NSNotFound))
        {
            NSArray *arr = [qrString componentsSeparatedByString:@"/"];
            
            
            [defaults setObject:[[qrString componentsSeparatedByString:@"/"] objectAtIndex:arr.count-1] forKey:@"bindNumber"];
        }
        else
        {
            [defaults setObject:qrString forKey:@"bindNumber"];
        }
        qrcode_str=qrString;
        
        WebService *webService = [WebService newWithWebServiceAction:@"ForgotCheck" andDelegate:self];
        webService.tag = 1;
        WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:self.phoneNumberTextField.text];
        WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"project" andValue:PROJECT];
        WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"SerialNumber" andValue:qrString];
        NSArray *parameter = @[loginParameter1,loginParameter2,loginParameter3];
        // webservice请求并获得结果
        webService.webServiceParameter = parameter;
        [webService getWebServiceResult:@"ForgotCheckResult"];
        
        // [aqrvc.navigationController popViewControllerAnimated:YES];
        
    };
    qrcodevc.SYQRCodeFailBlock = ^(SYQRCodeViewController *aqrvc){
        
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    qrcodevc.SYQRCodeCancleBlock = ^(SYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    //  [self presentViewController:qrcodevc animated:YES completion:nil];
    [self.navigationController pushViewController:qrcodevc animated:YES];
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
