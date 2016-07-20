//
//  dayView.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "DayView.h"

@implementation DayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置课程表的背景
        UIImage *bgImage = [UIImage imageNamed:@"timetable_bg"];
        UIImageView *bgView = [[UIImageView alloc]initWithImage:bgImage];
        bgView.frame = frame;
        [self addSubview:bgView];
        
        //课表头
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        [self addSubview:headerView];
        CGFloat kWidthGrid = self.frame.size.width/7.5;
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidthGrid*0.5, 30)];
        [self addSubview:emptyView];
        
        
        
        
    }
    return self;
}

@end
