//
//  AddNameViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "CommUtil.h"
#import "DXAlertView.h"
#import "AddNameViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "BookViewController.h"
#import "LoginViewController.h"
#import "UserModel.h"
#import "CenterViewController.h"
#import "SideslipViewController.h"
#import "ContactsTool.h"
#import "AddressBookModel.h"

@interface AddNameViewController ()<UITextFieldDelegate>
{
    UserModel* model;
    NSUserDefaults *defaluts;
    ContactModel *conModel;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *conArray;
    DataManager *manager;
    
}
@property(nonatomic, strong) ContactsTool *contactsTool;
@end

@implementation AddNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    model = [UserModel sharedUserInstance];
    defaluts = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.barTintColor = MCN_buttonColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    self.saveButton.backgroundColor = MCN_buttonColor;
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    
    self.contactLabel.text = [NSString stringWithFormat:@"%@: %@",NSLocalizedString(@"contact", nil),[defaluts objectForKey:@"Chenghu"]];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    manager = [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaluts objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    conArray = [manager isSelectContactTable:[defaluts objectForKey:@"binnumber"]];
    int t = [defaluts integerForKey:@"edit"];
    if([defaluts integerForKey:@"edit"] == 0)
    {
        conModel = [conArray objectAtIndex:[defaluts integerForKey:@"selectIndex"]];
    }
    self.phoneLabel.delegate = self;
    self.phoneshortLabel.delegate = self;
    
    self.phoneLabel.placeholder = NSLocalizedString(@"contact_num", nil);
    self.phoneshortLabel.placeholder = NSLocalizedString(@"contact_family", nil);
    self.phoneLabel.keyboardType = UIKeyboardTypeNumberPad;
    self.phoneshortLabel.keyboardType = UIKeyboardTypeNumberPad;
    
    [self.saveButton setTitle:NSLocalizedString(@"save", nil ) forState:UIControlStateNormal];
    
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

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (IBAction)saveButton:(id)sender {
    
    [self.phoneLabel resignFirstResponder];
    [self.phoneshortLabel resignFirstResponder];
    
    
//    if(self.phoneLabel.text.length == 0)
//    {
//        [OMGToast showWithText:NSLocalizedString(@"watch_number_null", nil) bottomOffset:50 duration:2];
//        return;
//    }
//    if (![self.phoneLabel.text isValidateMobile:self.phoneLabel.text]) {
    if (self.phoneLabel.text.length != 11) {
         [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
        return;
    }
//    if (![self.phoneshortLabel.text isValidateMobile:self.phoneshortLabel.text]) {
//        [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
//        return;
//    }
    WebService *webService = [WebService newWithWebServiceAction:@"AddContact" andDelegate:self];
    webService.tag = 0;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"type" andValue:@"1"];
    WebServiceParameter *loginParameter4 = [WebServiceParameter newWithKey:@"name" andValue:[defaluts objectForKey:@"Chenghu"]];
    WebServiceParameter *loginParameter5 = [WebServiceParameter newWithKey:@"photo" andValue:[NSString stringWithFormat:@"%ld",[defaluts integerForKey:@"headType"]]];
    WebServiceParameter *loginParameter6 = [WebServiceParameter newWithKey:@"phoneNum" andValue:self.phoneLabel.text];
    WebServiceParameter *loginParameter7 = [WebServiceParameter newWithKey:@"phoneShort" andValue:self.phoneshortLabel.text];
    NSArray *parameter;
    if ([CommUtil isNotBlank:self.bindNumber])
    {
        WebServiceParameter *loginParameter8 = [WebServiceParameter newWithKey:@"bindNumber" andValue:self.bindNumber];
        parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6,loginParameter7,loginParameter8];
    }else{
        parameter = @[loginParameter1, loginParameter2,loginParameter3,loginParameter4,loginParameter5,loginParameter6,loginParameter7];
    }
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"AddContactResult"];
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
                
                
                if ([CommUtil isNotBlank:self.bindNumber]) {
                    
                    
                    SideslipViewController *vc = [[SideslipViewController alloc] init];
                    vc.title = NSLocalizedString(@"mail_list", nil);
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                }
                if(ws.tag == 0)
                {
                    [self getBabyList];
                    
                }
                else if(ws.tag == 1)
                {
                    NSArray *array = [object objectForKey:@"ContactArr"];
                    [manager removeContactTable:deviceModel.BindNumber];
                    
                    for(int i = 0; i<array.count;i++)
                    {
                        [manager addContactTable:deviceModel.BindNumber andDeviceContactId:[[array objectAtIndex:i] objectForKey:@"DeviceContactId"] andRelationship:[[array objectAtIndex:i] objectForKey:@"Relationship"]  andPhoto:[[array objectAtIndex:i] objectForKey:@"Photo"] andPhoneNumber:[[array objectAtIndex:i] objectForKey:@"PhoneNumber"]  andPhoneShort:[[array objectAtIndex:i] objectForKey:@"PhoneShort"] andType:[[array objectAtIndex:i] objectForKey:@"Type"]andObjectId:[[array objectAtIndex:i] objectForKey:@"ObjectId"] andHeadImg:[[array objectAtIndex:i] objectForKey:@"HeadImg"]];
                        
                    }
                    
                    BookViewController *vc = [[BookViewController alloc] init];
                    vc.title = NSLocalizedString(@"mail_list", nil);
                    
                    for (UIViewController *controller in self.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[vc class]]) {
                            [self.navigationController popToViewController:controller animated:YES];
                        }
                    }
                    
                    
                }
                
                
            }
            else if(code == 0)
            {
                
                // [OMGToast showWithText:NSLocalizedString(@"登陆异常", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }            }
            else if(code == -3)
            {
                
                //[OMGToast showWithText:NSLocalizedString(@"无操作权限", nil) bottomOffset:50 duration:1];
            }
            else if (code == 9)
            {
                
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"prompt_Tip", nil) contentText:NSLocalizedString(@"point_or", nil) leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
                [alert show];
            }
            [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:1];
        }
    }
}

- (void)getBabyList
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceContact" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaluts objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceContactResult"];
    
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)addressBook:(id)sender
{
    // 弹出页面选择条联系人信息
    self.contactsTool = [[ContactsTool alloc] init];
    __weak typeof(self) weakSelf = self;
    [self.contactsTool getOnePhoneInfoWithUI:self callBack:^(AddressBookModel *contactModel) {
        NSLog(@"-----------");
        NSLog(@"%@", contactModel.name);
        NSLog(@"%@", contactModel.phoneNum);
        if([contactModel.phoneNum rangeOfString:@"-"].location !=NSNotFound)//_roaldSearchText
        {
            NSLog(@"yes");
            contactModel.phoneNum = [contactModel.phoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
        weakSelf.phoneLabel.text = contactModel.phoneNum;
    }];
}

- (IBAction)pushAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
