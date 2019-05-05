//
//  FlowersRewardViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "FlowersRewardViewController.h"
#import "LightTimeTableViewCell.h"
#import "DataManager.h"
#import "DeviceSetModel.h"

@interface FlowersRewardViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *titleArray;
    NSMutableArray *array;
    DeviceSetModel *model;
    NSUserDefaults *defaults;
    NSIndexPath *_indexPath;
}
@end

@implementation FlowersRewardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    titleArray = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"0%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"1%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"2%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"3%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"4%@",NSLocalizedString(@"red_flowers_num", nil)],[NSString stringWithFormat:@"5%@",NSLocalizedString(@"red_flowers_num", nil)], nil];
    
    self.tableVIew.delegate = self;
    self.tableVIew.dataSource = self;
    self.tableVIew.rowHeight = 40;
    
    if(model.flowerNumber.length == 0)
    {
        [defaults setObject:@"0" forKey:@"Flower_Num"];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static  NSString *cell1 = @"cell1";
    
    UINib *nib = [UINib nibWithNibName:@"LightTimeTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cell1];
    
    LightTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell1];
    if (cell == nil) {
        cell = [[LightTimeTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cell1];
    }
    cell.titleLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.gouImage.hidden = YES;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableVIew reloadData];
    LightTimeTableViewCell *cell = [self.tableVIew cellForRowAtIndexPath:indexPath];
    cell.gouImage.hidden = NO;
    
    if(indexPath.row == 0)
    {
        [defaults setObject:@"0" forKey:@"Flower_Num"];
    }
    else if(indexPath.row == 1)
    {
        [defaults setObject:@"1" forKey:@"Flower_Num"];
        
    }
    else if(indexPath.row == 2)
    {
        [defaults setObject:@"2" forKey:@"Flower_Num"];
        
    }
    else if(indexPath.row == 3)
    {
        [defaults setObject:@"3" forKey:@"Flower_Num"];
        
    }
    else if(indexPath.row == 4)
    {
        [defaults setObject:@"4" forKey:@"Flower_Num"];
        
    }
    else if(indexPath.row == 5)
    {
        [defaults setObject:@"5" forKey:@"Flower_Num"];
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    DataManager *manager = [DataManager shareInstance];
    
    array =   [manager isSelectDeviceSetTable:[defaults objectForKey:@"binnumber"]];
    
    model = [array objectAtIndex:0];
    
    [defaults setObject:model.flowerNumber forKey:@"Flower_Num"];
    
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
