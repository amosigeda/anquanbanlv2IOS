//
//  BookViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "NSString+Tools.h"
#import "BookViewController.h"
#import "BookOneTableViewCell.h"
#import "BookTwoTableViewCell.h"
#import "EditHeadAndNameViewController.h"
#import "LXActionSheet.h"
#import "DataManager.h"
#import "DeviceModel.h"
#import "ContactModel.h"
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "DXAlertView.h"
#import "UIImageView+WebCache.h"
#import "LoginViewController.h"
#import "UIImage+Utility.h"
#import "MJRefresh.h"

#define ORIGINAL_MAX_WIDTH 100.0f

@interface BookViewController ()<UITableViewDataSource,UITableViewDelegate,LXActionSheetDelegate,VPImageCropperDelegate,UIAlertViewDelegate>
{
    NSUserDefaults *defaults;
    
    ContactModel *conModel;
    DeviceModel *deviceModel;
    
    NSMutableArray *deviceArray;
    NSMutableArray *conArray;
    LXActionSheet *actionSheet;
    NSIndexPath *_indexPath;
    DataManager *manager;
    BOOL isShowPersonHead;
    BOOL isManage;
@private NSString *imgHex;
    
}
@end

@implementation BookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"1" forKey:@"showRight"];
    [defaults setObject:@"0" forKey:@"showLeft"];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    
    manager = [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    conArray = [manager isSelectContactTable:[defaults objectForKey:@"binnumber"]];
    
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    UIButton* rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:NSLocalizedString(@"add", nil) forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView addHeaderWithTarget:self action:@selector(Refresh)];
    self.tableView.headerPullToRefreshText = @"";
    self.tableView.headerRefreshingText = NSLocalizedString(@"header_hint_loading", nil);
    self.tableView.headerReleaseToRefreshText = NSLocalizedString(@"header_hint_normal", nil);

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresgBook) name:@"refreshBook" object:nil];
    
    if(deviceModel.DeviceModelID.length==0)
    {
        deviceModel.DeviceModelID=@"10000000";
    }
    
    if([[deviceModel.DeviceModelID substringWithRange:NSMakeRange(6,1)] intValue] ==1)
    {
        isShowPersonHead = YES;
    }
    else{
        isShowPersonHead = NO;
    }
    
}
-(void)Refresh
{
    [self refresgBook];
}

- (void)showNext
{
    if(conArray.count >= 50)
    {
        [OMGToast showWithText:NSLocalizedString(@"addressbook_limit", nil) bottomOffset:50 duration:2];
        return;
    }
    else
    {
        [defaults setInteger:1 forKey:@"edit"];
        EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
        vc.title = NSLocalizedString(@"edit_relat", nil);
        [defaults setInteger:0 forKey:@"editWatch"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)refresgBook
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetDeviceContact" andDelegate:self];
    webService.tag = 5;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
    NSArray *parameter = @[loginParameter1, loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetDeviceContactResult"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
    manager = [DataManager shareInstance];
    
    deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
    deviceModel = [deviceArray objectAtIndex:0];
    
    conArray = [manager isSelectContactTable:[defaults objectForKey:@"binnumber"]];
    //  [self refresgBook];
    
    [self.tableView reloadData];
}

- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return conArray.count+1;
}

- (CGFloat )tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 100;
    }
    return 80;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        static NSString *cell1 = @"bookOnecell";
        UINib *nib = [UINib nibWithNibName:@"BookOneTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell1];
        
        BookOneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
        if (cell == nil) {
            cell = [[BookOneTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell1];
        }
        if(deviceModel.BabyName.length == 0)
        {
            cell.nameLabel.text = NSLocalizedString(@"baby", nil);
        }
        else
        {
            if(deviceModel.BabyName.length > 5)
            {
                cell.nameLabel.text = [deviceModel.BabyName substringToIndex:5];
            }
            else
            {
                if([deviceModel.DeviceType isEqualToString:@"2"])
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"watch_the_host_d8", nil),deviceModel.BabyName];
                }
                else{
                    cell.nameLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"watch_the_host", nil),deviceModel.BabyName];
                }
            }
        }
        
        if([deviceModel.DeviceType isEqualToString:@"2"])
        {
            cell.phoneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"watch_no_d8", nil),deviceModel.PhoneNumber];
        }
        else
        {
            cell.phoneLabel.text = [NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"watch_no", nil),deviceModel.PhoneNumber];
        }
        cell.phoneShortLabel.text =[ NSString stringWithFormat:@"%@:%@",NSLocalizedString(@"cornet_family", nil),deviceModel.PhoneCornet];
        cell.imageVIew.layer.cornerRadius = 10;
        cell.imageVIew.layer.masksToBounds = YES;
        cell.imageVIew.layer.borderColor = [[UIColor whiteColor] CGColor];
        if([deviceModel.Photo isEqualToString:@""])
        {
            cell.headImageView.image = [UIImage imageNamed:@"user_head_normal"];
        }
        else
        {
            [cell.headImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPS,PHOTO, deviceModel.Photo]]];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
    else
    {
        static NSString *cell2 = @"yaosdasdad";
        UINib *nib = [UINib nibWithNibName:@"BookTwoTableViewCell" bundle:nil];
        [tableView registerNib:nib forCellReuseIdentifier:cell2];
        
        BookTwoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell2];
        if (cell == nil)
        {
            cell = [[BookTwoTableViewCell alloc]
                    initWithStyle:UITableViewCellStyleDefault
                    reuseIdentifier:cell2];
        }
        
        conModel = [conArray objectAtIndex:indexPath.row - 1];
        if(conModel.Relationship.length >5)
        {
            cell.nameLabel.text = [conModel.Relationship substringToIndex:5];
            
        }
        else
        {
            cell.nameLabel.text = conModel.Relationship;
            
        }
        cell.phoneLabel.text = conModel.PhoneNumber;
        
        if(conModel.Type.intValue == 3)
        {
            cell.typeImage.image = [UIImage imageNamed:@"watch_type"];
        }
        else if(conModel.Type.intValue == 2)
        {
            cell.typeImage.image = [UIImage imageNamed:@"APP_type"];
        }
        else
        {
            cell.typeImage.image = [UIImage imageNamed:@""];
        }
        
        if(conModel.PhoneShort.length == 0)
        {
            cell.phoneShortLabel.text = NSLocalizedString(@"add_the_cornet_the_family_number", nil);
        }
        else
        {
            cell.phoneShortLabel.text = conModel.PhoneShort;
        }
        
        if(deviceModel.UserId.intValue == conModel.ObjectId.intValue || conModel.ObjectId.intValue == [[defaults objectForKey:@"UserId"] intValue])
        {
            if(deviceModel.UserId.intValue == conModel.ObjectId.intValue)
            {
                cell.govenImage.image = [UIImage imageNamed:@"govenment_icon"];
            }
            else
            {
                cell.govenImage.image = [UIImage imageNamed:@"me_icon"];
            }
            cell.govenImage.hidden = NO;
        }
        else
        {
            cell.govenImage.hidden = YES;
        }
        
        if(conModel.HeadImg.length == 0)
        {
            cell.headImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"head_%d",conModel.Photo.intValue]];
        }
        else
        {
            [cell.headImage setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:HTTPS,PHOTO, conModel.HeadImg]]];
        }
        
        //等待请求
        if(conModel.Photo.intValue == 8)
        {
            cell.phoneShortLabel.hidden = YES;
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row != 0)
    {
        _indexPath = indexPath;
        conModel = [conArray objectAtIndex:indexPath.row - 1];
        
        [defaults setInteger:indexPath.row - 1 forKey:@"selectIndex"];//用于编辑通讯录选择model
        [defaults setValue:conModel.DeviceContactId forKey:@"DeviceContactId"];
        
        if(conModel.Type.intValue == 1)//对于普通联系人的操作
        {
            
            if(conModel.Photo.intValue != 8)//不为添加请求的时候
            {
                if((2 == [[defaults objectForKey:@"UserType"] intValue])||([[defaults objectForKey:@"UserId"] intValue] == deviceModel.UserId.intValue))//我是管理员
                {
                    
                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_phone_number", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil),NSLocalizedString(@"del", nil)]];
                    actionSheet.tag = 5;
                    [actionSheet showInView:self.view];
                }
                else
                {
                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_phone_number", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil)]];
                    actionSheet.tag = 0;
                    [actionSheet showInView:self.view];
                }
            }
        }
        
        if(deviceModel.UserId.intValue == conModel.ObjectId.intValue || conModel.ObjectId.intValue == [[defaults objectForKey:@"UserId"] intValue])//我对于自己的操作
        {
            if(deviceModel.UserId.intValue != conModel.ObjectId.intValue)
            {
                if(deviceModel.UserId.intValue != conModel.ObjectId.intValue)
                {
                    if(isShowPersonHead)
                    {
                        actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_photo", nil), NSLocalizedString(@"edit_the_cornet_the_family_number", nil)]];
                    }
                    else
                    {
//                        actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil)]];
                    }
                    actionSheet.tag = 1;
                    [actionSheet showInView:self.view];
                }
                
            }
        }
        isManage = NO;
        if([[defaults objectForKey:@"UserId"] intValue] == deviceModel.UserId.intValue && deviceModel.UserId.intValue == conModel.ObjectId.intValue)//我是管理员对于自己的操作
        {
            isManage = YES;
            if(conModel.Type.intValue == 2)
            {
                if(isShowPersonHead&&isManage)
                {
                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_photo", nil), NSLocalizedString(@"edit_the_cornet_the_family_number", nil),NSLocalizedString(@"del", nil)]];
                    actionSheet.tag = 3;
                }
                else
                {
//                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil),NSLocalizedString(@"del", nil)]];
                    
                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_phone_number", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil),NSLocalizedString(@"del", nil)]];
                    actionSheet.tag = 5;
//                    [actionSheet showInView:self.view];
                }
                
            }
            
            [actionSheet showInView:self.view];
        }
        
        if((2 == [[defaults objectForKey:@"UserType"] intValue]) || ([[defaults objectForKey:@"UserId"] intValue] == deviceModel.UserId.intValue && deviceModel.UserId.intValue != conModel.ObjectId.intValue))//我是管理员对于其他人的操作
        {
            if(conModel.Photo.intValue != 8)//不为添加请求的时候
            {
                if(conModel.Type.intValue == 2&& !isManage)//注册用户
                {
                    actionSheet = [[LXActionSheet alloc] initWithTitle:conModel.Relationship delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"edit_relat", nil),NSLocalizedString(@"edit_the_phone_number", nil),NSLocalizedString(@"edit_the_cornet_the_family_number", nil),NSLocalizedString(@"del", nil)]];
                    actionSheet.tag = 5;
                    [actionSheet showInView:self.view];
                }
                else if(conModel.Type.intValue == 1)//对于普通联系人的操作
                {
                    if(conModel.Photo.intValue != 8)//不为添加请求的时候
                    {
                        
                    }
                }
            }
        }
        
        if(conModel.Photo.intValue == 8)
        {
            // [defaults setObject:[defaults objectForKey:@"addDeviceID"] forKey:@"NoDeviceID"];
            // [defaults setObject:[defaults objectForKey:@"addUseID"] forKey:@"NOUseID"];
            
            UIAlertView *alerw = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", nil) message:NSLocalizedString(@"agree_add_user", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alerw.tag = 100;
            [alerw show];
        }
    }
}

- (void)didClickOnButtonIndex:(NSInteger *)buttonIndex
{
    if(actionSheet.tag == 0)//对于普通联系人的操作
    {
        if(buttonIndex == 0)
        {
            [defaults setInteger:3 forKey:@"editWatch"];
            [defaults setInteger:0 forKey:@"edit"];
            EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
            
        }
        else if (buttonIndex == 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num", nil) message:NSLocalizedString(@"set_phone_num", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = deviceModel.PhoneNumber;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            
            alertView.tag = 7;
            [alertView show];
            
        }
        else if (buttonIndex == 2)
        {
            UIAlertView *alertView;
            if([deviceModel.DeviceType isEqualToString:@"2"])
            {
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil) message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            else{
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil) message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = deviceModel.PhoneCornet;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            
            alertView.tag = 3;
            [alertView show];
            
        }
    }
    else if(actionSheet.tag == 1)//我对于自己的操作
    {
        if(isShowPersonHead)//有真人头像
        {
            if(buttonIndex == 0)
            {
                [defaults setInteger:3 forKey:@"editWatch"];
                [defaults setInteger:0 forKey:@"edit"];
                EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                [self.navigationController pushViewController:edit animated:YES];
            }
            else if (buttonIndex == 1)
            {
                actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"camera", nil),NSLocalizedString(@"album", nil)]];
                actionSheet.tag = 2;
                [actionSheet showInView:self.view];
            }
            
            else if (buttonIndex == 2)
            {
                UIAlertView *alertView;
                if([deviceModel.DeviceType isEqualToString:@"2"])
                {
                  alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil) message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                else{
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil) message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 3;
                [alertView show];
            }
        }
        else
        {
            if(buttonIndex == 0)
            {
                [defaults setInteger:3 forKey:@"editWatch"];
                [defaults setInteger:0 forKey:@"edit"];
                EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                [self.navigationController pushViewController:edit animated:YES];
            }
            else if (buttonIndex == 1)
            {
                UIAlertView *alertView ;
                if([deviceModel.DeviceType isEqualToString:@"2"])
                {
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil) message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                else{
                  alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil) message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 3;
                [alertView show];
            }
        }
    }
    else if (actionSheet.tag == 2)//我是管理员对于其他人的操作
    {
        if(buttonIndex == 0)
        {
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        }
        else if(buttonIndex == 1)
        {
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
        
    }
    else if (actionSheet.tag == 3)//我是管理员对于自己的操作
    {
        if(isShowPersonHead)//有真人头像时
        {
            if(buttonIndex == 0)
            {
                [defaults setInteger:3 forKey:@"editWatch"];
                [defaults setInteger:0 forKey:@"edit"];
                EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                [self.navigationController pushViewController:edit animated:YES];
            }
            else if (buttonIndex == 1)
            {
                actionSheet = [[LXActionSheet alloc] initWithTitle:NSLocalizedString(@"select_photo", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"camera", nil),NSLocalizedString(@"album", nil)]];
                actionSheet.tag = 2;
                [actionSheet showInView:self.view];
            }
            
            else if (buttonIndex == 2)
            {
                UIAlertView *alertView;
                if([deviceModel.DeviceType isEqualToString:@"2"])
                {
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil) message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                else{
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil) message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 3;
                [alertView show];
            }
            else if (buttonIndex ==3 )
            {
                ///删除联系人
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"delete_members", nil) contentText:[NSString stringWithFormat:@"%@:%@(%@:%@)",NSLocalizedString(@"whether_delete_members", nil),conModel.Relationship,NSLocalizedString(@"phone", nil),conModel.PhoneNumber] leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
                [alert show];
                alert.leftBlock = ^() {
                };
                
                alert.rightBlock = ^() {
                    
                    WebService *webService = [WebService newWithWebServiceAction:@"DeleteContact" andDelegate:self];
                    webService.tag = 3;
                    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
                    NSArray *parameter = @[loginParameter1,loginParameter2];
                    // webservice请求并获得结果
                    webService.webServiceParameter = parameter;
                    [webService getWebServiceResult:@"DeleteContactResult"];
                    
                };
                alert.dismissBlock = ^() {
                    NSLog(@"Do something interesting after dismiss block");
                };
            }
        }
        else
        {
            if(buttonIndex == 0)
            {
                [defaults setInteger:3 forKey:@"editWatch"];
                [defaults setInteger:0 forKey:@"edit"];
                EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
                [self.navigationController pushViewController:edit animated:YES];
            }
            else if (buttonIndex == 1)
            {
                UIAlertView *alertView;
                if([deviceModel.DeviceType isEqualToString:@"2"])
                {
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil)  message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                else{
                    alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil)  message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
                }
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
                [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
                
                alertView.tag = 3;
                [alertView show];
            }
            else if (buttonIndex ==2 )
            {
                ///删除联系人
                DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"delete_members", nil) contentText:[NSString stringWithFormat:@"%@:%@(%@:%@)",NSLocalizedString(@"whether_delete_members", nil),conModel.Relationship,NSLocalizedString(@"phone", nil),conModel.PhoneNumber] leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
                [alert show];
                alert.leftBlock = ^() {
                };
                
                alert.rightBlock = ^() {
                    
                    WebService *webService = [WebService newWithWebServiceAction:@"DeleteContact" andDelegate:self];
                    webService.tag = 3;
                    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
                    NSArray *parameter = @[loginParameter1,loginParameter2];
                    // webservice请求并获得结果
                    webService.webServiceParameter = parameter;
                    [webService getWebServiceResult:@"DeleteContactResult"];
                    
                };
                alert.dismissBlock = ^() {
                    NSLog(@"Do something interesting after dismiss block");
                };
            }
        }
    }
    else if (actionSheet.tag == 4)
    {
        
        if(buttonIndex == 0)
        {
            [defaults setInteger:3 forKey:@"editWatch"];
            [defaults setInteger:0 forKey:@"edit"];
            EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
            
        }
        else if (buttonIndex == 1)
        {
            UIAlertView *alertView;
            if([deviceModel.DeviceType isEqualToString:@"2"])
            {
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil)  message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            else{
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil)  message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            
            alertView.tag = 3;
            [alertView show];
        }
        else if (buttonIndex == 2)
        {
            ///删除联系人
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"delete_members", nil) contentText:[NSString stringWithFormat:@"%@:%@(%@:%@)",NSLocalizedString(@"whether_delete_members", nil),conModel.Relationship,NSLocalizedString(@"phone", nil),conModel.PhoneNumber] leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
            [alert show];
            alert.leftBlock = ^() {
            };
            
            alert.rightBlock = ^() {
                
                WebService *webService = [WebService newWithWebServiceAction:@"DeleteContact" andDelegate:self];
                webService.tag = 3;
                WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
                NSArray *parameter = @[loginParameter1,loginParameter2];
                // webservice请求并获得结果
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"DeleteContactResult"];
                
            };
            alert.dismissBlock = ^() {
                NSLog(@"Do something interesting after dismiss block");
            };
            
        }
    }
    else if (actionSheet.tag == 5)
    {
        if(buttonIndex == 0)
        {
            [defaults setInteger:3 forKey:@"editWatch"];
            [defaults setInteger:0 forKey:@"edit"];
            EditHeadAndNameViewController *edit = [[EditHeadAndNameViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
            
        }
        else if (buttonIndex == 1)
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num", nil) message:NSLocalizedString(@"set_phone_num", nil)  delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = conModel.PhoneNumber;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            alertView.tag = 7;
            [alertView show];
            
        }
        else if (buttonIndex == 2)
        {
            UIAlertView *alertView;
            if([deviceModel.DeviceType isEqualToString:@"2"])
            {
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet_d8", nil)  message:NSLocalizedString(@"set_phone_num_cornet_d8", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            else{
                alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"phone_num_cornet", nil)  message:NSLocalizedString(@"set_phone_num_cornet", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"cancel", nil),NSLocalizedString(@"OK", nil), nil];
            }
            alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
            [alertView textFieldAtIndex:0].text = conModel.PhoneShort;
            [alertView textFieldAtIndex:0].keyboardType = UIKeyboardTypeNumberPad;
            
            alertView.tag = 3;
            [alertView show];
            
        }
        else if(buttonIndex == 3)
        {
            ///删除联系人
            DXAlertView *alert = [[DXAlertView alloc] initWithTitle:NSLocalizedString(@"delete_members", nil) contentText:[NSString stringWithFormat:@"%@:%@(%@:%@)",NSLocalizedString(@"whether_delete_members", nil),conModel.Relationship,NSLocalizedString(@"phone", nil),conModel.PhoneNumber] leftButtonTitle:NSLocalizedString(@"cancel", nil) rightButtonTitle:NSLocalizedString(@"OK", nil)];
            [alert show];
            alert.leftBlock = ^() {
            };
            
            alert.rightBlock = ^() {
                
                WebService *webService = [WebService newWithWebServiceAction:@"DeleteContact" andDelegate:self];
                webService.tag = 3;
                WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
                WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
                NSArray *parameter = @[loginParameter1,loginParameter2];
                // webservice请求并获得结果
                webService.webServiceParameter = parameter;
                [webService getWebServiceResult:@"DeleteContactResult"];
                
            };
            alert.dismissBlock = ^() {
                NSLog(@"Do something interesting after dismiss block");
            };
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1)
    {
        if(alertView.tag == 0)
        {
            WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
            WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"babyName" andValue:[alertView textFieldAtIndex:0].text];
            webService.tag = 0;
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"babyNa"];
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"UpdateDeviceResult"];
        }
        else if (alertView.tag == 1)
        {
            
            if([alertView textFieldAtIndex:0].text.length != 0)
            {
//                if (![self isPureInt:[alertView textFieldAtIndex:0].text])
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:5];
//                    return;
//                }
//
//                if ([[alertView textFieldAtIndex:0].text length] != 11)
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:5];
//                    return;
//                }
                if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
                {
                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
                    return;
                }
            }
            
            WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
            
            webService.tag = 1;
            
            WebServiceParameter *loginParameter3  = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[alertView textFieldAtIndex:0].text];
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"phoneNu"];
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"UpdateDeviceResult"];
        }
        else if (alertView.tag == 2)
        {
            if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
            {
                [OMGToast showWithText:NSLocalizedString(@"input_right_cornet", nil) bottomOffset:50 duration:2];
                return;
            }
//            if([alertView textFieldAtIndex:0].text.length == 0)
//            {
//
//            }
//            else {
//
//                if (![self isPureInt:[alertView textFieldAtIndex:0].text])
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_cornet", nil) bottomOffset:50   duration:5];
//                    return;
//                }
//            }
            
            WebService *webService = [WebService newWithWebServiceAction:@"UpdateDevice" andDelegate:self];
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceId" andValue:deviceModel.DeviceID];
            webService.tag = 2;
            WebServiceParameter *loginParameter3;
            if([alertView textFieldAtIndex:0].text.length == 0)
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneCornet" andValue:@"-1"];
                
            }
            else
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneCornet" andValue:[alertView textFieldAtIndex:0].text];
                
            }
            
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"phoneCo"];
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"UpdateDeviceResult"];
            
        }
        else if (alertView.tag == 3)
        {
            if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
            {
                [OMGToast showWithText:NSLocalizedString(@"input_right_cornet", nil) bottomOffset:50 duration:2];
                return;
            }
//            if([alertView textFieldAtIndex:0].text.length == 0)
//            {
//                
//            }
//            else
//            {
//                if (![self isPureInt:[alertView textFieldAtIndex:0].text])
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_cornet", nil) bottomOffset:50   duration:5];
//                    return;
//                }
//            }
            WebService *webService = [WebService newWithWebServiceAction:@"EditRelation" andDelegate:self];
            webService.tag = 4;
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
            WebServiceParameter *loginParameter3;
            if([alertView textFieldAtIndex:0].text.length == 0)
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneShort" andValue:@"-1"];
                
            }
            else
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneShort" andValue:[alertView textFieldAtIndex:0].text];
                
            }
            
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"phoneShortContact"];
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"EditRelationResult"];
        }
        else if (alertView.tag == 100)
        {
            EditHeadAndNameViewController *vc = [[EditHeadAndNameViewController alloc] init];
            [defaults setInteger:100 forKey:@"editWatch"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if (alertView.tag == 7)
        {
            if([alertView textFieldAtIndex:0].text.length != 0)
            {
//                if (![self isPureInt:[alertView textFieldAtIndex:0].text])
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:5];
//                    return;
//                }
//
//                if ([[alertView textFieldAtIndex:0].text length] != 11)
//                {
//                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50   duration:5];
//                    return;
//                }
                if (![[alertView textFieldAtIndex:0].text isValidateMobile:[alertView textFieldAtIndex:0].text])
                {
                    [OMGToast showWithText:NSLocalizedString(@"input_right_no", nil) bottomOffset:50 duration:2];
                    return;
                }
            }
            
            WebService *webService = [WebService newWithWebServiceAction:@"EditRelation" andDelegate:self];
            webService.tag = 10000;
            WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
            WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:conModel.DeviceContactId];
            WebServiceParameter *loginParameter3;
            if([alertView textFieldAtIndex:0].text.length == 0)
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:@"-1"];
                
            }
            else
            {
                loginParameter3 = [WebServiceParameter newWithKey:@"phoneNumber" andValue:[alertView textFieldAtIndex:0].text];
                [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"chagePhoneNum"];
            }
            
            [defaults setObject:[alertView textFieldAtIndex:0].text forKey:@"phoneShortContact"];
            NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
            // webservice请求并获得结果
            webService.webServiceParameter = parameter;
            [webService getWebServiceResult:@"EditRelationResult"];
        }
    }
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
                    [manager updataSQL:@"favourite_info" andType:@"BabyName" andValue:[defaults objectForKey:@"babyNa"] andBindle:[defaults objectForKey:@"binnumber"]];
                }
                else if (ws.tag == 1)
                {
                    [manager updataSQL:@"favourite_info" andType:@"PhoneNumber" andValue:[defaults objectForKey:@"phoneNu"]andBindle:[defaults objectForKey:@"binnumber"]];
                }
                else if (ws.tag == 2)
                {
                    [manager updataSQL:@"favourite_info" andType:@"PhoneCornet" andValue:[defaults objectForKey:@"phoneCo"]andBindle:[defaults objectForKey:@"binnumber"]];
                }
                else if (ws.tag == 3)
                {
                    [manager deleContactItem:conModel.DeviceContactId];
                }
                else if (ws.tag == 4)
                {
                    [manager updataCONTACTSQL:@"contact_tal" andType:@"PhoneShort" andValue:[defaults objectForKey:@"phoneShortContact"] andDeviceConID:conModel.DeviceContactId];
                }
                
                else if (ws.tag == 5)
                {
                    NSMutableArray *arra = [manager isSelectFaWithDevice:deviceModel.DeviceID];
                    if(arra.count != 0)
                    {
                        DeviceModel *des = [arra objectAtIndex:0];
                        [manager removeContactTable:des.BindNumber];
                        NSArray *conArr = [object objectForKey:@"ContactArr"];
                        for(int i = 0; i<conArr.count;i++)
                        {
                            [manager addContactTable:des.BindNumber andDeviceContactId:[[conArr objectAtIndex:i] objectForKey:@"DeviceContactId"] andRelationship:[[conArr objectAtIndex:i] objectForKey:@"Relationship"]  andPhoto:[[conArr objectAtIndex:i] objectForKey:@"Photo"] andPhoneNumber:[[conArr objectAtIndex:i] objectForKey:@"PhoneNumber"]  andPhoneShort:[[conArr objectAtIndex:i] objectForKey:@"PhoneShort"] andType:[[conArr objectAtIndex:i] objectForKey:@"Type"] andObjectId:[[conArr objectAtIndex:i] objectForKey:@"ObjectId"] andHeadImg:[[conArr objectAtIndex:i] objectForKey:@"HeadImg"]];
                        }
                    }
                }
                else if (ws.tag == 6)//修改个人头像
                {
                    [manager updataCONTACTSQL:@"contact_tal" andType:@"HeadImg" andValue:[object objectForKey:@"HeadImg"] andDeviceConID:[defaults objectForKey:@"DeviceContactId"]];
                }
                else if (ws.tag == 10000)//修改电话号码
                {
                    [manager updataCONTACTSQL:@"contact_tal" andType:@"PhoneNumber" andValue:[defaults objectForKey:@"chagePhoneNum"] andDeviceConID:[defaults objectForKey:@"DeviceContactId"]];
                }
                
                deviceArray =  [manager isSelect:[defaults objectForKey:@"binnumber"]];
                
                conArray = [manager isSelectContactTable:[defaults objectForKey:@"binnumber"]];
                [self.tableView reloadData];
                
            }
            else if(code == 0)
            {
                //   [OMGToast showWithText:NSLocalizedString(@"登陆异常", nil) bottomOffset:50 duration:3];
                LoginViewController *vc = [[LoginViewController alloc] init];
                for (UIViewController *controller in self.navigationController.viewControllers) {
                    if ([controller isKindOfClass:[vc class]]) {
                        [self.navigationController popToViewController:controller animated:YES];
                    }
                }
            }
            else
            {
                //    [OMGToast showWithText:NSLocalizedString(@"修改失败", nil) bottomOffset:50 duration:3];
            }
            if(ws.tag != 5)
            {
                [OMGToast showWithText:[object objectForKey:@"Message"] bottomOffset:50 duration:3];

            }
            
            
            [self.tableView headerEndRefreshing];
        }
    }
}


#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    BookTwoTableViewCell *cell = [self.tableView cellForRowAtIndexPath:_indexPath];
    
    [cropperViewController dismissViewControllerAnimated:YES completion:^{}];
    editedImage = [self imageByScalingToMaxSize:editedImage];
    editedImage = [self imageByScalingAndCroppingForSourceImage:editedImage targetSize:CGSizeMake(50, 50)];
    cell.headImage.image = editedImage;
    
    UIImage *imageIcon = [editedImage roundedRectWith:18
                                          cornerMask:UIImageRoundedCornerBottomLeft|UIImageRoundedCornerBottomRight|UIImageRoundedCornerTopLeft|UIImageRoundedCornerTopRight];
    editedImage = imageIcon;

    NSData *imageData = UIImagePNGRepresentation(imageIcon);
    Byte *imageByte = (Byte *)[imageData bytes];
    NSMutableString *hexStr = [[NSMutableString alloc] initWithString:@""];
    
    for(int i=0;i<[imageData length];i++)
        
    {
        if(imageByte[i]<16)
            [hexStr appendFormat:@"0%x",imageByte[i]&0xff];
        else
            [hexStr appendFormat:@"%x",imageByte[i]&0xff];
        
    }
    imgHex=hexStr;
    [defaults setInteger:3 forKey:@"av"];
    
    WebService *webService = [WebService newWithWebServiceAction:@"EditHeadImg" andDelegate:self];
    webService.tag = 6;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"deviceContactId" andValue:[defaults objectForKey:@"DeviceContactId"]];
    WebServiceParameter *loginParameter3 = [WebServiceParameter newWithKey:@"headImg" andValue:imgHex==nil?@"":imgHex];
    NSArray *parameter = @[loginParameter1, loginParameter2,loginParameter3];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"EditHeadImgResult"];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{}];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 60.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) showAlert:(NSString *)message
{
    UIAlertView* alertDialog = [[UIAlertView alloc]initWithTitle:message
                                                         message:nil
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:NSLocalizedString(@"OK", nil),nil];
    [alertDialog show];
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
