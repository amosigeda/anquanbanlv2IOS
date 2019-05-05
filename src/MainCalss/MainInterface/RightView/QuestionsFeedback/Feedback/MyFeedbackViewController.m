//
//  MyFeedbackViewController.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "MyFeedbackViewController.h"
#import "WebService.h"
#import "WebServiceParameter.h"
#import "JSON.h"
#import "OMGToast.h"
#import "MyFeedbackTableViewCell.h"

@interface MyFeedbackViewController ()<UITableViewDataSource,UITableViewDelegate,WebServiceProtocol>
{
    NSUserDefaults *defaults;
    NSArray *conArray;
    UIButton* rightBtn;
    BOOL isShow;
}

@end

@implementation MyFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    defaults = [NSUserDefaults standardUserDefaults];
    conArray = [[NSArray alloc] init];
    isShow = NO;
    self.navigationController.navigationBar.barTintColor = navigationBarColor;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],UITextAttributeTextColor,nil]];
    UIButton* leftBtn= [UIButton buttonWithType:UIButtonTypeCustom];

    [leftBtn setImage:[UIImage imageNamed:@"back_normal"] forState:UIControlStateNormal];
    
    leftBtn.frame = CGRectMake(0, 0, 30, 30);
    
    UIBarButtonItem* leftBtnItem = [[UIBarButtonItem alloc]initWithCustomView:leftBtn];
    
    [leftBtn addTarget:self action:@selector(setviewinfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setLeftBarButtonItem:leftBtnItem];
    
    rightBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    
    [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor yellowColor] forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    rightBtn.frame = CGRectMake(0, 0, 50, 30);
    UIBarButtonItem* rightBtnItem = [[UIBarButtonItem alloc]initWithCustomView:rightBtn];
    
    [rightBtn addTarget:self action:@selector(showNext) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationItem setRightBarButtonItem:rightBtnItem];
    
    [self loadData];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 218;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)showNext
{
    if(isShow == NO)
    {
        self.tableView.editing = YES;
        [rightBtn setTitle:@"完成" forState:UIControlStateNormal];
        isShow = YES;
    }
    else
    {
        self.tableView.editing= NO;
        [rightBtn setTitle:@"编辑" forState:UIControlStateNormal];
        
        isShow = NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str = [[conArray objectAtIndex:conArray.count - indexPath.row - 1] objectForKey:@"FeedbackID"];
    WebService *webService = [WebService newWithWebServiceAction:@"DeleteFeedback" andDelegate:self];
    webService.tag = 1;
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    WebServiceParameter *loginParameter2 = [WebServiceParameter newWithKey:@"feebackId" andValue:str];

    NSArray *parameter = @[loginParameter1,loginParameter2];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"DeleteFeedbackResult"];
}

- (void)loadData
{
    WebService *webService = [WebService newWithWebServiceAction:@"GetFeedback" andDelegate:self];
    webService.tag = 0;
    
    WebServiceParameter *loginParameter1 = [WebServiceParameter newWithKey:@"loginId" andValue:[defaults objectForKey:@"LoginId"]];
    
    NSArray *parameter = @[loginParameter1];
    // webservice请求并获得结果
    webService.webServiceParameter = parameter;
    [webService getWebServiceResult:@"GetFeedbackResult"];
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return conArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"APPSetTab";
    
    UINib *nib = [UINib nibWithNibName:@"MyFeedbackTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellID];
    
    MyFeedbackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[MyFeedbackTableViewCell alloc]
                initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:cellID];
    }
    
    cell.problemLabel.text = [[conArray objectAtIndex:conArray.count - indexPath.row - 1] objectForKey:@"QuestionContent"];
    cell.problemTimeLabel.text  = [[conArray objectAtIndex:conArray.count - indexPath.row - 1] objectForKey:@"CreateTime"];
    cell.answerLabel.text = [[conArray objectAtIndex:conArray.count - indexPath.row - 1] objectForKey:@"AnswerContent"];
    cell.answerTimeLabel.text = [[conArray objectAtIndex:conArray.count - indexPath.row - 1] objectForKey:@"HandleTime"];

    return cell;
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
                    conArray = [object objectForKey:@"Arr"];
                    
                    if(conArray.count == 0)
                    {
                        [OMGToast showWithText:@"暂无数据" bottomOffset:50 duration:1];
                    }
                }
                else
                {
                    [OMGToast showWithText:@"删除成功" bottomOffset:50 duration:2];
                }
                
                    [self.tableView reloadData];
            }
            
            if(code != 1)
            {
                [OMGToast showWithText:NSLocalizedString([object objectForKey:@"Message"], nil)  bottomOffset:50 duration:2];
            }
        }
    }
}

- (void)WebServiceGetError:(id)theWebService error:(NSString *)theError
{
    
    [OMGToast showWithText:NSLocalizedString(@"网络连接失败", nil) bottomOffset:50 duration:3];
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
