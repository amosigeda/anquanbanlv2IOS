//
//  SoundAndVibrationViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//
#import "SoundAndVibrationViewController.h"
#import "WatchSetTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"

extern BOOL is_D8_show;
@interface SoundAndVibrationViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSUserDefaults *defaults;
    NSArray *seciton1Array;
    DeviceSetModel *model;
    NSMutableArray *array;
}
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end

@implementation SoundAndVibrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    self.saveBtn.backgroundColor = MCN_buttonColor;
    seciton1Array = [[NSArray alloc] initWithObjects:NSLocalizedString(@"sound", nil),NSLocalizedString(@"vibrate", nil),nil];
    
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView.hidden = YES;
    self.tableView.tableFooterView.hidden = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    DataManager *manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    [defaults setObject:model.WatchCallVoice forKey:@"watchCallSound"];
    [defaults setObject:model.WatchCallVibrate forKey:@"watchCallVib"];
    [defaults setObject:model.WatchInformationSound forKey:@"watchInmatSound"];
    [defaults setObject:model.WatchInformationShock forKey:@"watchInmatVib"];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(1)
    {
        return 1;

    }
    else{
        return 2;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(is_D8_show==YES)
    {
        if(section == 0)
        {
            return NSLocalizedString(@"watch_call_d8", nil);
        }
        
        else
            return NSLocalizedString(@"watch_msg_d8", nil);
    }
    else{
        if(section == 0)
        {
            return NSLocalizedString(@"watch_call", nil);
        }
        
        else
            return NSLocalizedString(@"watch_msg", nil);
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
//每个分组上边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 28;
    }
    else
        return 15;
}
//每个分组下边预留的空白高度
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"watchSet";
    
    UINib *nib = [UINib nibWithNibName:@"WatchSetTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    WatchSetTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[WatchSetTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    if (indexPath.section == 0) {
        if(indexPath.row == 0)
        {
            if([model.WatchCallVoice isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 8;
            
        }
        else if(indexPath.row == 1)
        {
            if([model.WatchCallVibrate isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 9;
        }
    }
    else
    {
        if(indexPath.row == 0)
        {
            if([model.WatchInformationSound isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 15;
        }
        else
        {
            if([model.WatchInformationShock isEqualToString:@"1"])
            {
                cell.OnOff.on = YES;
            }
            else
            {
                cell.OnOff.on = NO;
            }
            cell.OnOff.tag = 16;

        }
    }
    [cell.OnOff addTarget:self action:@selector(ONOFF:) forControlEvents:UIControlEventValueChanged];
    
    cell.titleLabel.text = [seciton1Array objectAtIndex:indexPath.row];
    return cell;
    
}

- (void)ONOFF:(UISwitch *)sw
{
    UISwitch *swi = sw;
    if(swi.tag == 8)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchCallSound"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchCallSound"];

        }
    }
    else if(swi.tag == 9)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchCallVib"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchCallVib"];
        }

    }
    else if(swi.tag == 15)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchInmatSound"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchInmatSound"];
        }
        
    }
    else if(swi.tag == 16)
    {
        if(swi.isOn == YES)
        {
            [defaults setObject:@"1" forKey:@"watchInmatVib"];
        }
        else
        {
            [defaults setObject:@"0" forKey:@"watchInmatVib"];
        }
    }
}

- (void)setviewinfo
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    
  }

- (IBAction)saveButn:(id)sender {
    
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
