//
//  CourseViewController.m
//  Course
//
//  Created by MacOS on 14-12-16.
//  Copyright (c) 2014年 Joker. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "CourseViewController.h"
#import "TermViewController.h"
#import "TwoTitleButton.h"
#import "DayTableViewCell.h"
#import "DateUtils.h"
//#import "DetailViewController.h"
#import "WeekCourse.h"
#import "CourseButton.h"
#import "WeekChoseView.h"
#import "Public.h"
#import "JKCourse-Prefix.pch"
@interface CourseViewController ()<WeekChoseViewDelegate>

@end

@implementation CourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //加载一些基本数据
    [self loadBaseData];
    //初始化导航栏
    [self _initNavigationBar];
    //初始化日的视图
    [self _initDayView];
    //初始化周的视图
    [self _initWeekView];
    //初始化隐藏的周选择视图
    [self _initWeekChoseView];
    //加载网络数据
    [self loadNetDataWithWeek:[NSString stringWithFormat:@"%d",clickTag-250+1]];
    
}

//加载一些不需要从服务器请求的数据
- (void)loadBaseData
{
    _colors = [[NSArray alloc] initWithObjects:@"9,155,43",@"251,136,71",@"163,77,140",@"32,81,148",@"255,170,0",@"4,155,151",@"38,101,252",@"234,51,36",@"107,177,39",@"245,51,119", nil];
    
    //如果数据当前周为空，则默认为第一周
    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString  *currentWeek = [userDefaults objectForKey:@"currentWeek"];
    if (currentWeek == nil) {
        [userDefaults setObject:@"1" forKey:@"currentWeek"];
        [userDefaults synchronize];
    }
    
    //先加载本周的月份以及日期
    horTitles = [DateUtils getDatesOfCurrence];
    
    //赋值计算今天的日期
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    todayComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today];
}

/**
 *  获取星期几的课程
 *
 *  @param weekDay 星期几，如：星期一是monday
 *  @param courses 服务器返回的课程数组
 *
 *  @return 返回课程 （按照上课顺序 从第一节......到第第十二节）
 */
- (NSMutableArray *)getDayCoursesByWeekDay:(NSString *)weekDay srcArray:(NSArray *)courses
{
    //返回时使用的数组
    NSMutableArray *newCourses = [NSMutableArray array];
    int rowNum = 1;//默认从第一节开始计算
    if (courses == nil) { //如果没有数据时
        for (int j = rowNum; j< 13; j++) {
            WeekCourse *weekCourse = [[WeekCourse alloc] init];
            weekCourse.capter = [NSString stringWithFormat:@"%d",j];
            [newCourses addObject:weekCourse];
        }
        return newCourses;
    }
    //星期几的课程  --- 用到了谓词
    NSString *string = [NSString stringWithFormat:@"day == '%@'",weekDay];
    NSPredicate *pre = [NSPredicate predicateWithFormat:string];
    //应该只有一条记录
    NSArray *coursesOfDay = [courses filteredArrayUsingPredicate:pre]; //筛选出某天的课程信息
    //终于拿到课程了
    for (int i = 0; i < coursesOfDay.count; i++) {
        //每一条记录为一个cell的数据，这里给Model添加capter属性,设置哪几节上课
        WeekCourse *course = [coursesOfDay objectAtIndex:i];
        NSString *lesson = course.lesson;
        NSString *lessonsNum = course.lessonsNum;
        int endCapter = lesson.intValue+lessonsNum.intValue -1;
        //判断是否之前有空着的，如果有插入空节数
        if (rowNum != lesson.intValue) {
            for (int j = rowNum; j<lesson.intValue; j++) {
                WeekCourse *weekCourse = [[WeekCourse alloc] init];
                weekCourse.capter = [NSString stringWithFormat:@"%d",j];
                [newCourses addObject:weekCourse];//把一些只包含节数信息的对象 插入数组
            }
        }
        //组装新的课程信息，其实只修改了从第几节到第几节，还有是否有课的属性
        course.haveLesson = YES;
        //判断是否为只上一节的情况
        if (endCapter == lesson.intValue) {
            course.capter = lesson;
        }else {
            NSString *capter = [NSString stringWithFormat:@"%@-%d",lesson,endCapter];
            course.capter = capter;
        }
        //把重新组装的dict 加入数组
        [newCourses addObject:course];
        rowNum = endCapter +1;
    }
    
    //如果还没计算到第12节，后面的也要插入只包含节数的dict
    if (rowNum < 12) {
        for (int j = rowNum; j< 13; j++) {
            WeekCourse *weekCourse = [[WeekCourse alloc] init];
            weekCourse.capter = [NSString stringWithFormat:@"%d",j];
            [newCourses addObject:weekCourse];
        }
    }
    return newCourses;
}

//计算出周一至周日的课程，封装成数组
- (NSMutableArray *)getCoursesWithServerData:(NSArray *)array
{
    NSMutableArray *dayAllCourses = [[NSMutableArray alloc] initWithCapacity:7];
    NSArray *weekDays = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",];
    //计算出周一至周日的课程，封装成数组
    for (int i = 0; i < weekDays.count; i++) {
        NSString *weekday = [weekDays objectAtIndex:i];
        NSMutableArray *newCourses = [self getDayCoursesByWeekDay:weekday srcArray:array];
        [dayAllCourses addObject:newCourses];
    }
    return dayAllCourses;
}



//请求网络数据
- (void)loadNetDataWithWeek:(NSString *)week
{
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *year = [userDefaults objectForKey:CURRENTYEAR];
//    NSString *term = [userDefaults objectForKey:CURRENTTERM];
//    NSString *stuId = [userDefaults objectForKey:USERNAME];
//    
//    NSString *yearRange = [NSString stringWithFormat:@"%@%@",year,term];
//    
//    if (year == nil || term == nil) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请先设置学期" message:nil delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alertView show];
//        return;
//    }
//    if (stuId == nil) {
//        return;
//    }
//    if (week == nil) {
//        week = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentWeek"];
//    }
    
    [self showHUD:@"加载课程..." isDim:NO];
    //加载网络数据，这里用本地数据代替
//    [self performSelectorInBackground:@selector(ABCAction) withObject:nil];
    [self performSelector:@selector(loadLoacalData:) withObject:week afterDelay:1.5];
}

//加载本地的模拟数据
- (void)loadLoacalData:(NSString *)week
{
    static BOOL flag = YES;
    NSString *coursePath;
    if (flag) {
        coursePath = [[NSBundle mainBundle] pathForResource:@"courses" ofType:@"json"];
        flag = NO;
    }else {
        coursePath = [[NSBundle mainBundle] pathForResource:@"courses-1" ofType:@"json"];
        flag = YES;
    }
    NSData *data = [NSData dataWithContentsOfFile:coursePath];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    NSString *status = [dict objectForKey:@"status"];
    if (![@"200" isEqualToString:status]) {
        NSLog(@"没有数据");
        return;
    }
    
    NSArray *array = [dict objectForKey:@"data"];
//    [self handleData:array];
    [self handleWeek:array week:week];
    [self hideHUD];

}

- (void)handleWeek:(NSArray *)array week:(NSString *)week
{
    NSMutableArray *allCourses =[NSMutableArray array];
    if (array != nil && array.count > 0) {
        for (int i = 0; i < array.count; i++) {
            NSDictionary *dayDict = array[i];
            NSArray *dayCourses = [dayDict objectForKey:@"data"];
            NSString *weekDay = [dayDict objectForKey:@"weekDay"];
            NSString *weekNum;
            if ([@"monday" isEqualToString:weekDay]) {
                weekNum = @"1";
            }else if ([@"tuesday" isEqualToString:weekDay]){
                weekNum = @"2";
            }else if ([@"wednesday" isEqualToString:weekDay]){
                weekNum = @"3";
            }else if ([@"thursday" isEqualToString:weekDay]){
                weekNum = @"4";
            }else if ([@"friday" isEqualToString:weekDay]){
                weekNum = @"5";
            }else if ([@"saturday" isEqualToString:weekDay]){
                weekNum = @"6";
            }else if([@"sunday" isEqualToString:weekDay]){
                weekNum = @"7";
            }else {
                weekNum = weekDay;
            }
            for (int j = 0; j<dayCourses.count; j++) {
                NSMutableDictionary *course = [NSMutableDictionary dictionaryWithDictionary:dayCourses[j]];
                [course setObject:weekNum forKey:@"weekDay"];
                WeekCourse *weekCourse = [[WeekCourse alloc] initWithPropertiesDictionary:course];
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSString *year = [userDefaults objectForKey:CURRENTYEAR];
                NSString *term = [userDefaults objectForKey:CURRENTTERM];
                NSString *stuId = [userDefaults objectForKey:USERNAME];
                NSString *yearRange = [NSString stringWithFormat:@"%@%@",year,term];
                weekCourse.studentId = stuId;
                weekCourse.term = yearRange;
                weekCourse.weeks = week;
                
                [allCourses addObject:weekCourse];
            }
        }
    }
    
    //对数据解析
    [self handleData:allCourses];
}

//数据解析后，展示在UI上
- (void)handleData:(NSArray *)courses
{
    if (dataArray || dataArray.count > 0) {
        dataArray = nil;
    }
    
    for (UIView *view in weekScrollView.subviews) {
        if ([view isKindOfClass:[CourseButton class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (courses.count > 0) {
        //处理周课表
        for (int i = 0; i<courses.count; i++) {
            WeekCourse *course = courses[i];
            
            int rowNum = course.lesson.intValue - 1;
            int colNum = course.day.intValue;
            int lessonsNum = course.lessonsNum.intValue;
            
            CourseButton *courseButton = [[CourseButton alloc] initWithFrame:CGRectMake((colNum-0.5)*kWidthGrid, 50*rowNum+1, kWidthGrid-2, 50*lessonsNum-2)];
            courseButton.weekCourse = course;
            int index = i%10;
            courseButton.backgroundColor = [self handleRandomColorStr:_colors[index]];
            [courseButton addTarget:self action:@selector(courseClick:) forControlEvents:UIControlEventTouchUpInside];
            [weekScrollView addSubview:courseButton];
        }
        
        //日课表数据处理
        dataArray = [self getCoursesWithServerData:courses];
    } else {
        dataArray = [self getCoursesWithServerData:nil];
    }
    
    for (int i = 0; i< 7; i++) {
        UITableView *tableView = (UITableView *)[scrollView viewWithTag:10000+i];
        [tableView reloadData];
    }
}

#pragma mark - 初始化控件
//初始化导航栏
- (void)_initNavigationBar
{
    //左侧按钮
    UIButton *dayOrWeekButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
    [dayOrWeekButton setTitle:@"日" forState:UIControlStateNormal];
    [dayOrWeekButton setBackgroundImage:[UIImage imageNamed:@"week_but"] forState:UIControlStateNormal];
    [dayOrWeekButton addTarget:self action:@selector(dayOrWeekAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:dayOrWeekButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //右侧按钮
    UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [rightButton setTitle:@"学期" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(termAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
 
    
    //中间按钮
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    titleView.backgroundColor = [UIColor clearColor];
    
    UIButton *weeksButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
    weeksButton.tag = 110;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentWeek = [userDefaults objectForKey:@"currentWeek"];
    clickTag = currentWeek.intValue + 250-1;
    currentWeekTag = clickTag;
    [weeksButton setTitle:[NSString stringWithFormat:@"第%@周",currentWeek] forState:UIControlStateNormal];
    [weeksButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -12, 0, 12)];
    [weeksButton setImage:[UIImage imageNamed:@"course_arrow.png"] forState:UIControlStateNormal];
    [weeksButton setImageEdgeInsets:currentWeek.length>1?UIEdgeInsetsMake(0, 60, 0, -60):UIEdgeInsetsMake(0, 40, 0, -60)];
    
    [weeksButton addTarget:self action:@selector(weekChooseAction:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:weeksButton];
    
    backLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 25, 80, 10)];
    backLabel.backgroundColor = [UIColor clearColor];
    backLabel.textColor = [UIColor yellowColor];
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.font = [UIFont systemFontOfSize:10];
    backLabel.text = @"返回本周";
    backLabel.hidden = YES;
    [weeksButton addSubview:backLabel];

    
    self.navigationItem.titleView = titleView;
   
    
    //背景视图
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44)];
    bgImageView.image = [UIImage imageNamed:@"course_bg_2.jpeg"];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:bgImageView];
}

//初始化隐藏的周选择视图
- (void)_initWeekChoseView
{
    weekChoseScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,-60, ScreenWidth, 60)];
    weekChoseScrollView.backgroundColor = WEEKDAY_BGCOLOR;
    weekChoseScrollView.contentSize = CGSizeMake(50*25, 60);
    weekChoseScrollView.showsHorizontalScrollIndicator = NO;
    for (int i = 0; i< 25; i++) {
        WeekChoseView *weekChoseView = [[WeekChoseView alloc] initWithFrame:CGRectMake(50*i, 0, 50, 60)];
        weekChoseView.number = [NSString stringWithFormat:@"%d",i+1];
        weekChoseView.delegate = self;
        weekChoseView.tag = 250+i;
        if (clickTag == (250 +i)) {
            weekChoseView.isCurrentWeek = YES;
            weekChoseView.isChosen = YES;
            [weekChoseView reset];
            weekChoseScrollView.contentOffset = CGPointMake(50*i, 0);
        }
        [weekChoseScrollView addSubview:weekChoseView];
     
    }
    
    [self.view addSubview:weekChoseScrollView];
}

//初始化日视图
- (void)_initDayView
{
    dayView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44)];
    
    UIView *dayHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    UIButton *monthButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWidthGrid*0.5, 30)];
    [monthButton setTitle:horTitles[0] forState:UIControlStateNormal];
    [monthButton setTitleColor:WEEKDAY_FONT_COLOR forState:UIControlStateNormal];
    monthButton.titleLabel.font = [UIFont fontWithName:@"Microsoft YaHei" size:9.0f];
    monthButton.layer.borderColor = WEEKDAY_SELECT_COLOR.CGColor;
    monthButton.layer.borderWidth = 0.3f;
    monthButton.layer.masksToBounds = YES;
    [dayHeaderView addSubview:monthButton];

    
    NSArray *weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    for (int i = 0; i< 7; i++) {
        TwoTitleButton *button = [[TwoTitleButton alloc] initWithFrame:CGRectMake((i+0.5)*kWidthGrid, 0, kWidthGrid, 30)];
        NSString *title = [NSString stringWithFormat:@"%@",weekDays[i]];
        button.tag = 9000+i;
        button.title = horTitles[i+1];
        button.subtitle = title;
        button.textColor = WEEKDAY_FONT_COLOR;
        [dayHeaderView addSubview:button];
        
    }
    [dayView addSubview:dayHeaderView];
 
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, ScreenWidth, dayView.frame.size.height-30)];
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(ScreenWidth*7, scrollView.frame.size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    
    for (int i = 0; i< 7; i++) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(i*ScreenWidth, 0, ScreenWidth, scrollView.frame.size.height) style:UITableViewStylePlain];
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorColor = WEEKDAY_SELECT_COLOR;
        tableView.tag = i + 10000;
        tableView.delegate = self;
        tableView.dataSource = self;
        [scrollView addSubview:tableView];
        
    }
    
    NSString *month = [NSString stringWithFormat:@"%d月",[todayComp month]];
    NSString *day = [NSString stringWithFormat:@"%d",[todayComp day]];
    int num = -1;
    for (int i = 0; i < 7; i++) {
        TwoTitleButton *button = (TwoTitleButton *)[dayView viewWithTag:9000+i];
        if ([month isEqualToString:horTitles[0]] && [day isEqualToString:horTitles[i+1]]) {
            button.backgroundColor = WEEKDAY_SELECT_COLOR;
            scrollView.contentOffset = CGPointMake(ScreenWidth*i, 0);
            num = i;
        }
    }
    
    [dayView addSubview:scrollView];
    if (num >= 0) {
        //添加滑块
        sliderLabel = [[UILabel alloc] initWithFrame:CGRectMake((num+0.5)*kWidthGrid, scrollView.frame.origin.y, kWidthGrid, 5)];
        sliderLabel.backgroundColor = RGBColor(21, 43, 110, 1);
        [dayView addSubview:sliderLabel];
    }
    
    [self.view addSubview:dayView];
    dayView.hidden = YES;
}

//初始化周视图
- (void)_initWeekView
{
    weekView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44)];
    //初始化周视图的头
    UIView *weekHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 30)];
    UIButton *monthButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kWidthGrid*0.5, 30)];
    [monthButton setTitle:horTitles[0] forState:UIControlStateNormal];
    [monthButton setTitleColor:WEEKDAY_FONT_COLOR forState:UIControlStateNormal];
    monthButton.titleLabel.font = [UIFont fontWithName:@"Microsoft YaHei" size:9.0f];
    monthButton.layer.borderColor = WEEKDAY_SELECT_COLOR.CGColor;
    monthButton.layer.borderWidth = 0.3f;
    monthButton.layer.masksToBounds = YES;
    [weekHeaderView addSubview:monthButton];

    
    NSArray *weekDays = @[@"一",@"二",@"三",@"四",@"五",@"六",@"日"];
    for (int i = 0; i< 7; i++) {
        TwoTitleButton *button = [[TwoTitleButton alloc] initWithFrame:CGRectMake((i+0.5)*kWidthGrid, 0, kWidthGrid, 30)];
        NSString *title = [NSString stringWithFormat:@"周%@",weekDays[i]];
        button.tag = 9000+i;
        button.title = horTitles[i+1];
        button.subtitle = title;
        button.textColor = WEEKDAY_FONT_COLOR;
        
        NSString *month = [NSString stringWithFormat:@"%d月",[todayComp month]];
        NSString *day = [NSString stringWithFormat:@"%d",[todayComp day]];
        if ([month isEqualToString:horTitles[0]] && [day isEqualToString:horTitles[i+1]]) {
            button.backgroundColor = WEEKDAY_SELECT_COLOR;
        }
        
        [weekHeaderView addSubview:button];
    
    }
    [weekView addSubview:weekHeaderView];
    
    //主体部分
    weekScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 30, ScreenWidth, weekView.frame.size.height -30)];
    weekScrollView.bounces = NO;
    weekScrollView.contentSize = CGSizeMake(ScreenWidth, 50*12);
    for (int i = 0; i<12; i++) {
        for (int j = 0; j< 8; j++) {
            if (j == 0) {
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(j*kWidthGrid, i*50,kWidthGrid*0.5, 50)];
                label.backgroundColor = [UIColor clearColor];
                label.layer.borderColor = WEEKDAY_SELECT_COLOR.CGColor;
                label.layer.borderWidth = 0.3f;
                label.layer.masksToBounds = YES;
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = WEEKDAY_FONT_COLOR;
                label.text =[NSString stringWithFormat:@"%d",i+1];
                [weekScrollView addSubview:label];
            } else {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((j-0.5)*kWidthGrid-1, i*50, kWidthGrid, 50+1)];
                imageView.image = [UIImage imageNamed:@"course_excel.png"];
                [weekScrollView addSubview:imageView];
            }
            
        }
    }
    [weekView addSubview:weekScrollView];

    [self.view addSubview:weekView];

}

//另一种加在提示框
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim
{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.dimBackground = isDim;
    _HUD.labelText = title;
    [_HUD show:YES];
}

//隐藏提示框
- (void)hideHUD
{
    [_HUD hide:YES];
}

#pragma mark - 私有方法
//生成随机颜色
- (UIColor *)randomColor
{
    //    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    //    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    //    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    //    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    UIColor *color1 = RGBColor(9, 155, 43, 0.5);
    UIColor *color2 = RGBColor(251, 136, 71, 0.5);
    UIColor *color3 = RGBColor(163, 77, 140, 0.5);
    NSArray *array = [[NSArray alloc] initWithObjects:color1,color2,color3, nil];
    return [array objectAtIndex:arc4random()%3];
}

//处理随机颜色字符串
- (UIColor *)handleRandomColorStr:(NSString *)randomColorStr
{
    NSArray *array = [randomColorStr componentsSeparatedByString:@","];
    if (array.count >2) {
        NSString *red = array[0];
        NSString *green = array[1];
        NSString *blue = array[2];
        return RGBColor(red.floatValue, green.floatValue, blue.floatValue, 0.5);
    }
    return [UIColor lightGrayColor];
}

- (void)courseClick:(UIButton *)sender
{
//    CourseButton *courseButton = (CourseButton *)sender;
//    WeekCourse *weekCourse = courseButton.weekCourse;
//    DetailViewController *detailCtr = [[DetailViewController alloc]init];
//    detailCtr.weekCourse = weekCourse;
//    [self.navigationController pushViewController:detailCtr animated:YES];
    
}
//点击学期
- (void)termAction
{
    TermViewController *termVC = [[TermViewController alloc] init];
    termVC.backBlock = ^{
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *currentWeek = [userDefaults objectForKey:CURRENTWEEK];
        [self loadNetDataWithWeek:currentWeek];
    };
    [self.navigationController pushViewController:termVC animated:YES];
}

//日---周切换方法--翻转过渡动画效果
- (void)dayOrWeekAction:(UIButton *)sender
{
    UIButton *button = (UIButton*)sender;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    [self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:2];
    [UIView setAnimationTransition:dayView.hidden ? UIViewAnimationTransitionFlipFromLeft : UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    if (dayView.hidden) {
        [button setTitle:@"周" forState:UIControlStateNormal];
        dayView.hidden = NO;
        weekView.hidden = YES;
    }else {
        [button setTitle:@"日" forState:UIControlStateNormal];
        dayView.hidden = YES;
        weekView.hidden = NO;
    }
    
}

//返回事件方法
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)weekChooseAction:(id)sender
{
    //本来显示，点击之后要隐藏
    if (weekChoseViewShow) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationRepeatCount:1];
        [UIView setAnimationDuration:0.5f];
        weekChoseScrollView.frame = CGRectMake(0, -60, ScreenWidth, 60);
        [self changeSubViewsFrameByWeek:weekChoseViewShow];
        [UIView commitAnimations];
        weekChoseViewShow = NO;
        if(clickTag!=currentWeekTag){
            WeekChoseView *view = (WeekChoseView *)[weekChoseScrollView viewWithTag:clickTag];
            view.isChosen = NO;
            [view reset];
            clickTag = currentWeekTag;
            NSString *week = [[NSString alloc] initWithFormat:@"%d",clickTag-250+1];
            UIButton *weekButton = (UIButton *)[self.navigationItem.titleView viewWithTag:110];
            [weekButton setTitle:[NSString stringWithFormat:@"第%@周",week] forState:UIControlStateNormal];
            [weekButton setImageEdgeInsets:week.length>1?UIEdgeInsetsMake(0, 60, 0, -60):UIEdgeInsetsMake(0, 40, 0, -60)];
            [self bounceTargetView:weekButton];
            backLabel.hidden = YES;
            //数据也重新加载
            [self loadNetDataWithWeek:week];
        }
    }else {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationRepeatCount:1];
        [UIView setAnimationDuration:0.5f];
        weekChoseScrollView.frame = CGRectMake(0, 0, ScreenWidth, 60);
        [self changeSubViewsFrameByWeek:weekChoseViewShow];
        [UIView commitAnimations];
        weekChoseViewShow = YES;
        
        if(clickTag ==currentWeekTag){
            WeekChoseView *view = (WeekChoseView *)[weekChoseScrollView viewWithTag:currentWeekTag];
            view.isChosen = YES;
            [view reset];
         }
    }
    

}

- (void)bounceTargetView:(UIView *)targetView
{
    [UIView animateWithDuration:0.1 animations:^{
        targetView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            targetView.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                targetView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
}

//修改子类的frame
- (void)changeSubViewsFrameByWeek:(BOOL)_weekViewShow
{
    if (_weekViewShow) {
        //设置日课表视图以及其子视图的frame
        dayView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44);
        CGRect frame = scrollView.frame;
        frame.size.height = dayView.frame.size.height-30;
        scrollView.frame = frame;
        CGSize size = scrollView.contentSize;
        size.height = frame.size.height;
        scrollView.contentSize = size;
        for (int i = 0; i < 7; i++) {
            UITableView *tableView = (UITableView *)[scrollView viewWithTag:10000 + i];
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.size.height = frame.size.height;
            tableView.frame = tableViewFrame;
        }
        
        //设置周课表视图以及其子视图的frame
        weekView.frame = dayView.frame;
        weekScrollView.frame = frame;
    } else {
        dayView.frame = CGRectMake(0, 60, ScreenWidth, ScreenHeight-20-44-60);
        CGRect frame = scrollView.frame;
        frame.size.height = dayView.frame.size.height-30;
        scrollView.frame = frame;
        CGSize size = scrollView.contentSize;
        size.height = frame.size.height;
        scrollView.contentSize = size;
        for (int i = 0; i < 7; i++) {
            UITableView *tableView = (UITableView *)[scrollView viewWithTag:10000 + i];
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.size.height = frame.size.height;
            tableView.frame = tableViewFrame;
        }
        
        //设置周课表视图以及其子视图的frame
        weekView.frame = dayView.frame;
        weekScrollView.frame = frame;
    }
    
}

//修改子类的frame
- (void)changeSubViewsFrame:(BOOL)_toolViewShow
{
    if (_toolViewShow) {
        //设置日课表视图以及其子视图的frame
        dayView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-20-44);
        CGRect frame = scrollView.frame;
        frame.size.height = dayView.frame.size.height-30;
        scrollView.frame = frame;
        CGSize size = scrollView.contentSize;
        size.height = frame.size.height;
        scrollView.contentSize = size;
        for (int i = 0; i < 7; i++) {
            UITableView *tableView = (UITableView *)[scrollView viewWithTag:10000 + i];
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.size.height = frame.size.height;
            tableView.frame = tableViewFrame;
        }
        
        //设置周课表视图以及其子视图的frame
        weekView.frame = dayView.frame;
        weekScrollView.frame = frame;
        
    } else {
        dayView.frame = CGRectMake(0, 40, ScreenWidth, ScreenHeight-20-44-40);
        CGRect frame = scrollView.frame;
        frame.size.height = dayView.frame.size.height-30;
        scrollView.frame = frame;
        CGSize size = scrollView.contentSize;
        size.height = frame.size.height;
        scrollView.contentSize = size;
        for (int i = 0; i < 7; i++) {
            UITableView *tableView = (UITableView *)[scrollView viewWithTag:10000 + i];
            CGRect tableViewFrame = tableView.frame;
            tableViewFrame.size.height = frame.size.height;
            tableView.frame = tableViewFrame;
        }
        
        //设置周课表视图以及其子视图的frame
        weekView.frame = dayView.frame;
        weekScrollView.frame = frame;

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    //本来显示，点击之后要隐藏
    if (weekChoseViewShow) {
        [UIView animateWithDuration:0.5 animations:^{
            weekChoseScrollView.frame = CGRectMake(0, -60, ScreenWidth, 60);
            [self changeSubViewsFrameByWeek:weekChoseViewShow];
            weekChoseViewShow = NO;
        } completion:^(BOOL finished) {
            if (_scrollView == scrollView) {
                int page = scrollView.contentOffset.x/ScreenWidth;
                for (int i = 0; i < 7; i++) {
                    TwoTitleButton *button = (TwoTitleButton *)[dayView viewWithTag:9000+i];
                    if (page == i) {
                        button.backgroundColor = WEEKDAY_SELECT_COLOR;
                        if (sliderLabel) {
                            [UIView beginAnimations:nil context:nil];
                            [UIView setAnimationDuration:0.2];
                            CGRect rect = sliderLabel.frame;
                            rect.origin.x = (i+0.5)*kWidthGrid;
                            sliderLabel.frame = rect;
                            [UIView commitAnimations];
                        }
                    }else {
                        button.backgroundColor = [UIColor clearColor];
                    }
                    
                }
            }

        }];
    } else {
        if (_scrollView == scrollView) {
            int page = scrollView.contentOffset.x/ScreenWidth;
            for (int i = 0; i < 7; i++) {
                TwoTitleButton *button = (TwoTitleButton *)[dayView viewWithTag:9000+i];
                if (page == i) {
                    button.backgroundColor = WEEKDAY_SELECT_COLOR;
                    if (sliderLabel) {
                        [UIView beginAnimations:nil context:nil];
                        [UIView setAnimationDuration:0.2];
                        CGRect rect = sliderLabel.frame;
                        rect.origin.x = (i+0.5)*kWidthGrid;
                        sliderLabel.frame = rect;
                        [UIView commitAnimations];
                    }
                }else {
                    button.backgroundColor = [UIColor clearColor];
                }
                
            }
        }

    }
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int tag = tableView.tag - 10000;
    return [dataArray[tag] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = tableView.tag - 10000;
    static NSString *identifier = @"dayCell";
    DayTableViewCell *dayCell = [tableView dequeueReusableCellWithIdentifier:identifier];
    dayCell.backgroundColor = [UIColor clearColor];
    if (dayCell == nil) {
        dayCell = [[[NSBundle mainBundle] loadNibNamed:@"DayTableViewCell" owner:self options:nil] objectAtIndex:0];
        dayCell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    dayCell.weekCourse = [dataArray[tag] objectAtIndex:indexPath.row];
    
    return dayCell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 120) {
        return 44;
    }
    int tag = tableView.tag - 10000;
    WeekCourse *weekCourse = [dataArray[tag] objectAtIndex:indexPath.row];
    if (weekCourse.haveLesson) {
       return 76;
    }
    
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = tableView.tag - 10000;
    WeekCourse *weekCourse = [dataArray[tag] objectAtIndex:indexPath.row];
    if (weekCourse.haveLesson) {
//        DetailViewController *detailCtr = [[DetailViewController alloc]init];
//        detailCtr.weekCourse = weekCourse;
//        [self.navigationController pushViewController:detailCtr animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - WeekChoseViewDelegate
- (void)tapAction:(int)tag
{
    if (clickTag == 0) {
        clickTag = tag;
    }else {
        WeekChoseView *view = (WeekChoseView *)[weekChoseScrollView viewWithTag:clickTag];
        view.isChosen = NO;
        [view reset];
        clickTag = tag;
    }
    NSString *week = [[NSString alloc] initWithFormat:@"%d",tag-250+1];
    UIButton *weekButton = (UIButton *)[self.navigationItem.titleView viewWithTag:110];
    [weekButton setTitle:[NSString stringWithFormat:@"第%@周",week] forState:UIControlStateNormal];
    [weekButton setImageEdgeInsets:week.length>1?UIEdgeInsetsMake(0, 60, 0, -60):UIEdgeInsetsMake(0, 40, 0, -60)];
    [self bounceTargetView:weekButton];
    
    if(clickTag !=currentWeekTag){
        backLabel.hidden = NO;
    }
    else if(clickTag == currentWeekTag){
        backLabel.hidden = YES;
    }

    //重新加载
    [self loadNetDataWithWeek:week];
}

- (void)setCurrentWeek:(NSString *)number
{
    NSString *title = [NSString stringWithFormat:@"将第%@周设置为本周？",number];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //点击取消
    }else {
        //点击确定按钮
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        //先取消原来本周控件的背景色
        NSString *currentWeek = [userDefaults objectForKey:@"currentWeek"];
        WeekChoseView *weekChoseView = (WeekChoseView *)[weekChoseScrollView viewWithTag:(currentWeek.intValue +250-1)];
        weekChoseView.isCurrentWeek = NO;
        [weekChoseView reset];
        
        WeekChoseView *newView = (WeekChoseView *)[weekChoseScrollView viewWithTag:clickTag];
        newView.isCurrentWeek = YES;
        currentWeekTag = clickTag;
        [newView reset];
        [userDefaults setObject:[NSString stringWithFormat:@"%d",clickTag-250+1] forKey:@"currentWeek"];
        [userDefaults synchronize];
        
        backLabel.hidden = YES;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        weekChoseScrollView.frame = CGRectMake(0, -60, ScreenWidth, 60);
        [self changeSubViewsFrameByWeek:weekChoseViewShow];
        weekChoseViewShow = NO;
        [UIView commitAnimations];
    }
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	hud = nil;
}



@end
