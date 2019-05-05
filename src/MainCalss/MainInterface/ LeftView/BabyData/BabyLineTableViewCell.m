//
//  BabyLineTableViewCell.m
//  酷宝贝
//
//  Created by yangkang on 16/6/22.
//  Copyright © 2016年 YiWen. All rights reserved.
//

#import "BabyLineTableViewCell.h"

@implementation BabyLineTableViewCell

- (void)awakeFromNib {
    // Initialization code
    [self.boylBtn setTitle:NSLocalizedString(@"baby_boy", nil) forState:UIControlStateNormal];
    [self.girlBtn setTitle:NSLocalizedString(@"baby_girl", nil) forState:UIControlStateNormal];
    [self.boylBtn setTitle:NSLocalizedString(@"baby_boy", nil) forState:UIControlStateSelected];
    [self.girlBtn setTitle:NSLocalizedString(@"baby_girl", nil) forState:UIControlStateSelected];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (IBAction)boyAction:(UIButton *)sender {
    self.boylBtn.selected = !self.boylBtn.selected;
    self.girlBtn.selected = !self.boylBtn.selected;
    
    if (self.chosSexBlock) {
        NSString *sex = self.boylBtn.selected?NSLocalizedString(@"boy", nil):@"女";
        self.chosSexBlock(sex);
    }
}



@end
