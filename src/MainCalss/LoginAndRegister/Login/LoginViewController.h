//
//  LoginViewController.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userTextfield;//账号
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;//密码
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;//忘记密码按钮
@property (weak, nonatomic) IBOutlet UIButton *resignButton;//注册按钮
@property (weak, nonatomic) IBOutlet UIButton *showPasswordBtn;//看密码
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;//登录按钮
@property (weak, nonatomic) IBOutlet UILabel *prompt;//提示信息

@end
