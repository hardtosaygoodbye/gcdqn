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
#import "CourseDetailViewController.h"
#import "BrowserView.h"


#define kWidthGrid self.frame.size.width/7.5
@interface WeekView()<BrowserViewDelegate>
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) NSString *currentWeek;

@property (nonatomic,strong) BrowserView *browser;
@property (nonatomic,strong) UIView *browserBackgroundView;

//传递到详情页面的数据
@property (nonatomic,strong) NSMutableArray *courseDataArray;

//每个课时对应按钮，比如离散数学是周一的第7，8，9课时
@property (nonatomic,strong) NSMutableDictionary<NSString *,UIButton *> *courseButtonDictionary;

//每个课时对应是否有课
@property (nonatomic,strong) NSMutableDictionary *haveAClass;
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
        
        //将按钮添加到滚动视图
        [self addAllButtonsToMainScrollView];
    }
    return self;
}

#pragma mark - courseButtonDictionary,haveAClass
-(NSMutableDictionary<NSString *,UIButton *> *)courseButtonDictionary
{
    if (!_courseButtonDictionary) {
        _courseButtonDictionary = [[NSMutableDictionary alloc] init];
    }
    return _courseButtonDictionary;
}

-(NSMutableDictionary *)haveAClass
{
    if (!_haveAClass) {
        _haveAClass = [[NSMutableDictionary alloc] init];
    }
    return _haveAClass;
}

-(NSMutableArray *)courseDataArray
{
    if (!_courseDataArray) {
        _courseDataArray = [[NSMutableArray alloc] init];
    }
    return _courseDataArray;
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
            
            static int tag = 0;
            btn.tag = 100 + tag;
            [btn addTarget:self action:@selector(displayCourseDetailView:) forControlEvents:UIControlEventTouchUpInside];
            /***（二）***/
            /*
             *遍历当前课程，对应的每个课时
             *haveAClass有课的课时value赋值为YES
             *所以如果value已经为YES，则这里有课程冲突
             *有冲突的地方需合并button，并设置背景色为红色提醒
             */
            BOOL isUpdate = NO;
            for (int i = [sectionstart intValue]; i <= [sectionend intValue]; i++) {
                NSString *aClass = [NSString stringWithFormat:@"%d,%d",[weekDayNum intValue],i];
                if (![[self.haveAClass valueForKey:aClass] boolValue]) {
                    [self.haveAClass setValue:[NSNumber numberWithBool:YES] forKey:aClass];
                }else {
                    if (!isUpdate) {
                        UIButton *oldBtn = [self.courseButtonDictionary objectForKey:aClass];
                        
                        CGFloat Y =  oldBtn.frame.origin.y < positionBeginY ? oldBtn.frame.origin.y : positionBeginY;
                        CGFloat endY = (oldBtn.frame.size.height + oldBtn.frame.origin.y) < positionEndY ? positionEndY : oldBtn.frame.size.height + oldBtn.frame.origin.y;
                        [btn setFrame:CGRectMake(positionX, Y, kWidthGrid, endY - Y)];
                        [btn setBackgroundColor:[UIColor redColor]];
                        NSString *oldBtnTitle = [oldBtn.currentTitle stringByAppendingString:@"+"];
                        [btn setTitle:[oldBtnTitle stringByAppendingString:btn.currentTitle] forState:UIControlStateNormal];
                        [oldBtn setFrame:CGRectMake(0, 0, 0, 0)];
                        
                        id obj = self.courseDataArray[oldBtn.tag-100];
                        if ([obj isKindOfClass:[NSMutableArray class]]) {
                            [(NSMutableArray *)obj addObject:model];
                            self.courseDataArray[tag] = obj;
                            if (LX_DEBUG) NSLog(@"LX_DEBUG//WeekView.m--_showTimetable--self.courseDataArray addObject--obj != TimetableModel//model.name = %@",model.name);
                        }else if ([obj isKindOfClass:[TimetableModel class]]){
                            NSMutableArray *models = [[NSMutableArray alloc] init];
                            [models addObject:obj];
                            [models addObject:model];
                            self.courseDataArray[tag] = models;
                            if (LX_DEBUG) NSLog(@"LX_DEBUG//WeekView.m--_showTimetable--self.courseDataArray addObject--obj = TimetableModel//model.name = %@",model.name);
                        }
                        
                        isUpdate = YES;
                    }
                }
                //标记每个课时的位置，对应于哪一个button
                [self.courseButtonDictionary setObject:btn forKey:aClass];
            }
            if (!isUpdate) {
                self.courseDataArray[tag] = model;
            }
            tag++;
        }
    }
}

//点击按钮进入详情界面，或弹出选择课程视图
-(void)displayCourseDetailView:(UIButton *)button
{
    id obj = self.courseDataArray[button.tag-100];
    if ([obj isKindOfClass:[TimetableModel class]]) {
        
        //没有冲突，直接显示详情
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CourseDetailViewController *courseDVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"courseDVC"];
        courseDVC.view.backgroundColor = [UIColor whiteColor];
        TimetableModel *model = (TimetableModel *)obj;
        courseDVC.title = model.name;
        
        //发送通知
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeekViewToCourseDVC" object:model];
        
        [self.ctrl.navigationController pushViewController:courseDVC animated:YES];
    }else if ([obj isKindOfClass:[NSMutableArray class]]){
        
        //冲突课程浏览器
        UIView *browserBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        browserBackgroundView.backgroundColor = [UIColor grayColor];
        browserBackgroundView.alpha = 0.7f;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapbrowserBackgroundView:)];
        [browserBackgroundView addGestureRecognizer:tapGesture];
        self.browserBackgroundView = browserBackgroundView;
        [self.superview addSubview:browserBackgroundView];
        
        BrowserView *browser = [[BrowserView alloc] initWithFrame:CGRectMake(0, 200, ScreenWidth, BrowserHeight) models:(NSMutableArray *)obj currentIndex:1];
        browser.delegate = self;
        [self.superview addSubview:browser];
        self.browser = browser;
    }
}

//移除browserBackgroundView
-(void)tapbrowserBackgroundView:(UITapGestureRecognizer *)tapGesture
{
    [self.browserBackgroundView removeFromSuperview];
    [self.browser removeFromSuperview];
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
                
                /***（一）***/
                //初始化12*7个课时(NO代表没有课，YES代表有课)，默认没有课
                NSString *aClass = [NSString stringWithFormat:@"%d,%d",j,i+1];//字典的KEY
                [self.haveAClass setObject:[NSNumber numberWithBool:NO] forKey:aClass];
            }
            
        }
    }
    [self addSubview:self.mainScrollView];
}

-(void)addAllButtonsToMainScrollView
{
    //提出所有的button
    NSArray *array = [self.courseButtonDictionary allValues];
    
    //过滤掉重复的部分
    NSSet *set = [NSSet setWithArray:array];
    
    //过滤掉frame为(0,0,0,0)的部分
    for (UIButton *btn in set) {
        if (btn.frame.size.height > 0) {
            [self.mainScrollView addSubview:btn];
        }
    }
}

#pragma mark - BrowserDelegate

- (void)browser:(BrowserView *)movieBrowser didSelectItem:(TimetableModel *)model
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CourseDetailViewController *courseDVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"courseDVC"];
    courseDVC.view.backgroundColor = [UIColor whiteColor];
    courseDVC.title = model.name;
    
    //发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WeekViewToCourseDVC" object:model];
    [self.browserBackgroundView removeFromSuperview];
    [self.browser removeFromSuperview];
    [self.ctrl.navigationController pushViewController:courseDVC animated:YES];
}

/*在冲突课程浏览器下方显示课程名称
- (void)browser:(BrowserView *)movieBrowser didChangeItem:(NSString *)name
{
    NSLog(@"name = %@", name);
    self.courseNameLabel.text = name;
}*/

static NSInteger _lastIndex = -1;
- (void)browser:(BrowserView *)movieBrowser didEndScrollingAtIndex:(NSInteger)index
{
    if (_lastIndex != index) {
        NSLog(@"刷新---%@", ((TimetableModel *)self.courseDataArray[index]).name);
    }
    _lastIndex = index;
}

@end
