//
//  TimetableViewController.m
//  gcdqn
//
//  Created by admin on 16/7/19.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "TimetableViewController.h"
#import "WeekView.h"
@interface TimetableViewController ()

@end

@implementation TimetableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blueColor];
    //获取当前状态栏的高度
    CGRect statusRect = [[UIApplication sharedApplication]statusBarFrame];
    NSLog(@"状态栏高度：%f",statusRect.size.height);
    //获取导航栏的高度
    CGRect navRect = self.navigationController.navigationBar.frame;
    NSLog(@"导航栏高度：%f",navRect.size.height);
    //将周课程表添加到视图控制器中
    WeekView *weekView = [[WeekView alloc]initWithFrame:CGRectMake(0, statusRect.size.height+navRect.size.height, self.view.frame.size.width, self.view.frame.size.height-(statusRect.size.height+navRect.size.height))];
    weekView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:weekView];
    
    weekView.ctrl = self;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
