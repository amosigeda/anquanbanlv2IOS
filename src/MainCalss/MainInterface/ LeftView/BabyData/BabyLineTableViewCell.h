//
//  BabyLineTableViewCell.h
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyLineTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UITextField *listLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (weak, nonatomic) IBOutlet UIView *sexBg;
@property (weak, nonatomic) IBOutlet UIButton *boylBtn;
@property (weak, nonatomic) IBOutlet UIButton *girlBtn;
@property (nonatomic,copy) void(^chosSexBlock)(NSString *sex);
@end
