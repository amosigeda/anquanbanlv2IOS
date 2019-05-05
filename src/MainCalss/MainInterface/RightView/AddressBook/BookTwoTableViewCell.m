//
//  BookTwoTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "BookTwoTableViewCell.h"

@implementation BookTwoTableViewCell

- (void)awakeFromNib {
    [self.headImage.layer setCornerRadius:17.5];
    self.headImage.layer.masksToBounds = YES;
        self.headImage.layer.borderWidth = 1;
        self.headImage.layer.borderColor = [navigationBarColor CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
