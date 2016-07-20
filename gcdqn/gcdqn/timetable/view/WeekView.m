//
//  WeekView.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "WeekView.h"
#import "Public.h"
@implementation WeekView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置课程表的背景
        UIImage *bgImage = [UIImage imageNamed:@"timetable_bg"];
        UIImageView *bgView = [[UIImageView alloc]initWithImage:bgImage];
        bgView.frame = self.bounds;
        [self addSubview:bgView];
        //课表头
        UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, 30)];
        [self addSubview:headerView];
        CGFloat kWidthGrid = self.frame.size.width/7.5;
        UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidthGrid*0.5, 30)];
        [self addSubview:emptyView];
        
        NSArray *weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
        for (int i=0; i<7; i++) {
            UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake((i+0.5)*kWidthGrid, 0, kWidthGrid, 30)];
            headerLabel.text = [NSString stringWithFormat:@"周%@",weekDays[i]];
            headerLabel.textColor = [UIColor whiteColor];
            [headerView addSubview:headerLabel];
        }
        //课程表主体部分
        UIScrollView *mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 30, self.frame.size.width, self.frame.size.height-30)];
        mainScrollView.bounces = NO;
        mainScrollView.contentSize = CGSizeMake(self.frame.size.width, 50*12);
        for (int i = 0; i<12; i++) {
            for (int j = 0; j< 8; j++) {
                if (j == 0) {
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(j*kWidthGrid, i*50,kWidthGrid*0.5, 50)];
                    label.backgroundColor = [UIColor clearColor];
                    label.layer.borderColor = RGBColor(32, 81, 148, 0.23).CGColor;
                    label.layer.borderWidth = 0.3f;
                    label.layer.masksToBounds = YES;
                    label.textAlignment = NSTextAlignmentCenter;
                    //label.textColor = RGBColor(32, 81, 148, 1);
                    label.textColor = [UIColor whiteColor];
                    label.text =[NSString stringWithFormat:@"%d",i+1];
                    [mainScrollView addSubview:label];
                } else {
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((j-0.5)*kWidthGrid-1, i*50, kWidthGrid, 50+1)];
                    imageView.image = [UIImage imageNamed:@"course_excel.png"];
                    [mainScrollView addSubview:imageView];
                }
                
            }
        }
        [self addSubview:mainScrollView];
        
        
        

    }
    return self;
}

@end
