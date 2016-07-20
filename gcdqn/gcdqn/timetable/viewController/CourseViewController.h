//
//  CourseViewController.h
//  Course
//
//  Created by MacOS on 14-12-16.
//  Copyright (c) 2014年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface CourseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD           *_HUD;
    
    UITableView *weekTableView;  //周课表的表格
    UITableView *dayTableView;  //日课表的表格
    UIScrollView *scrollView; //日课表的滚动视图（里面装了7个tableView）
    UIScrollView *weekScrollView;  //周课表的滚动视图
    UIView       *dayView;  //日课表的视图
    UIView       *weekView; //周课表的视图
    
    UIImageView  *bgImageView; //背景视图
    UILabel      *sliderLabel; //日课表滑块
    
    UIScrollView *weekChoseScrollView; //横向滚动的周选择视图
    BOOL         weekChoseViewShow;  //周选择视图的显示与否
    
    UIView       *toolView;     //显示学期和工具箱的视图
    UIButton     *termButton;   //学期按钮
    UIButton     *toolButton;   //工具箱按钮
    
    BOOL         toolViewShow;
    
    BOOL        isWeek;
    
    NSArray *horTitles;  //横向的标题，（月份、日期）
    NSDateComponents *todayComp;  //今天的扩展
    NSArray *dataArray;   //日课表中每个cell的数据
    
    int         clickTag;  //点击的周tag值
    UILabel     *backLabel;
    int         currentWeekTag;
    
}

@property (nonatomic, retain) NSArray *colors;
//@property (nonatomic, copy) NSString    *selectTitle;

//一种带文字的提示框
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim;

@end
