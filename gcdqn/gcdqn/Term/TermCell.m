//
//  TermCell.m
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import "TermCell.h"

@implementation TermCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_isChecked) {
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"task_state_checked"] forState:UIControlStateNormal];
    } else {
        [_checkButton setBackgroundImage:[UIImage imageNamed:@"task_state_unchecked"] forState:UIControlStateNormal];
    }
}



- (IBAction)checkAction:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(choseTerm:)]) {
        sender.tag = self.tag;
        [_delegate choseTerm:sender];
    }
}

@end
