//
//  WeekView.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "WeekView.h"
#import "Public.h"
#import "timetableViewModel.h"
#import "TimetableModel.h"

#define kWidthGrid self.frame.size.width/7.5
@interface WeekView()
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) NSString *currentWeek;
@end


@implementation WeekView

#pragma - mark 改 30,50 magic number
//表头高度
static const CGFloat HEADER_VIEW_HEIGHT = 30.0f;

//网格高度
static const CGFloat GRID_HEIGHT = 50.0f;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化当前周数
        self.currentWeek = @"1";
        //初始化ui界面
        [self _initUI];
        //加载课表数据
        [self _loadData];
        //将课表数据加载到界面上
        [self _showTimetable];
    }
    return self;
}

- (void)_showTimetable
{
    
    for (int i=0; i<self.dataArray.count; i++) {
        //NSDictionary *dic = self.dataArray[i];
        TimetableModel *model = self.dataArray[i];
        
        //获取该课程哪几周有课
        //NSString *temp = dic[@"smartPeriod"];
        NSString *temp = model.smartPeriod;
        NSArray *haveLessonWeek = [temp componentsSeparatedByString:@" "];
        //NSLog(@"%@",haveLessonWeek);
        
        //判断该课程当前周有没有课
        BOOL key = NO;
        for (int j=0; j<haveLessonWeek.count; j++) {
            
            if ([haveLessonWeek[j] isEqualToString:self.currentWeek]) {
                key = YES;
            }
        }
        
        if (key==YES) {
            //星期数
            NSNumber *weekDayNum = model.day;
            CGFloat weekDayFloat = weekDayNum.intValue;
            //根据星期数计算x值
            CGFloat positionX = (0.5+weekDayFloat-1)*kWidthGrid;
            //上课开始第几节课
            NSNumber *sectionstart = model.sectionstart;
            CGFloat sectionstartFloat = sectionstart.intValue;
            //根据以上内容算y的起始位置
            CGFloat positionBeginY = (sectionstartFloat-1)*GRID_HEIGHT;
            //上课结束第几节课
            NSNumber *sectionend = model.sectionend;
            CGFloat sectionendFloat = sectionend.intValue;
            //根据以上内容算y的结束位置
            CGFloat positionEndY = (sectionendFloat)*GRID_HEIGHT;
            //课程名字
            NSString *name = model.name;
            //每一次课都是一个按钮
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake(positionX, positionBeginY, kWidthGrid, positionEndY-positionBeginY);
            [btn setTitle:name forState:UIControlStateNormal];
            btn.titleLabel.numberOfLines = 0;
            btn.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:10];
            
            btn.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:0.7];
            [self.mainScrollView addSubview:btn];
        }

        
        
        
        
        
    }
}

- (void)_loadData
{
    timetableViewModel *timetableVM = [[timetableViewModel alloc]init];
    //self.dataArray = timetableVM.data;
    timetableVM.returnValueBlock = ^(id returnValue){
        self.dataArray = returnValue;
    };
    
    [timetableVM getTimetableData];
    
}

//初始化ui界面
- (void)_initUI{
    
    //设置课程表的背景
    UIImage *bgImage = [UIImage imageNamed:@"timetable_bg"];
    UIImageView *bgView = [[UIImageView alloc]initWithImage:bgImage];
    bgView.frame = self.bounds;
    [self addSubview:bgView];
    
    //课表头
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEADER_VIEW_HEIGHT)];
    [self addSubview:headerView];
    //CGFloat kWidthGrid = self.frame.size.width/7.5;
    UIView *emptyView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidthGrid*0.5, HEADER_VIEW_HEIGHT)];
    [self addSubview:emptyView];
    
    NSArray *weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    for (int i=0; i<7; i++) {
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake((i+0.5)*kWidthGrid, 0, kWidthGrid, HEADER_VIEW_HEIGHT)];
        headerLabel.text = [NSString stringWithFormat:@"周%@",weekDays[i]];
        headerLabel.textColor = [UIColor whiteColor];
        [headerView addSubview:headerLabel];
    }
    
    //课程表主体部分
    self.mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, HEADER_VIEW_HEIGHT, self.frame.size.width, self.frame.size.height-HEADER_VIEW_HEIGHT)];
    self.mainScrollView.bounces = NO;
    self.mainScrollView.contentSize = CGSizeMake(self.frame.size.width, GRID_HEIGHT*12);
    for (int i = 0; i<12; i++) {
        for (int j = 0; j< 8; j++) {
            if (j == 0) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(j*kWidthGrid, i*GRID_HEIGHT,kWidthGrid*0.5, GRID_HEIGHT)];
                label.backgroundColor = [UIColor clearColor];
                label.layer.borderColor = RGBColor(32, 81, 148, 0.23).CGColor;
                label.layer.borderWidth = 0.3f;
                label.layer.masksToBounds = YES;
                label.textAlignment = NSTextAlignmentCenter;
                //label.textColor = RGBColor(32, 81, 148, 1);
                label.textColor = [UIColor whiteColor];
                label.text =[NSString stringWithFormat:@"%d",i+1];
                [self.mainScrollView addSubview:label];
            } else {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((j-0.5)*kWidthGrid-1, i*GRID_HEIGHT, kWidthGrid, GRID_HEIGHT+1)];
                imageView.image = [UIImage imageNamed:@"course_excel.png"];
                [self.mainScrollView addSubview:imageView];
            }
            
        }
    }
    [self addSubview:self.mainScrollView];
    
    
}

@end
