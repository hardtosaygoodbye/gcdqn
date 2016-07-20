//
//  BaseNavigationController.m
//  I3IntelligentEye
//
//  Created by MacOS on 14-7-17.
//  Copyright (c) 2014年 d-5. All rights reserved.
//

#import "BaseNavigationController.h"
#import "Public.h"
@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

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
    // Do any additional setup after loading the view.
    [self loadThemeImage];
    
    [self.navigationBar setBarStyle:UIBarStyleBlack];
    
    //添加向右的清扫手势
    UISwipeGestureRecognizer *swipGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipAction:)];
    swipGesture.direction = UISwipeGestureRecognizerDirectionRight;
    // 响应的手指数
    swipGesture.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:swipGesture];
    
}

- (void)swipAction:(UISwipeGestureRecognizer *)gesture
{
    if (self.viewControllers.count <= 1) {
        return;
    }
    [self popViewControllerAnimated:NO];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadThemeImage
{
    //导航栏背景色 RGB 值 32，81，148
    if (SystemVersion >=7.0) {
        UIImage *image = [UIImage imageNamed:@"navigationbar_bg"];
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    }
    else if (SystemVersion >= 5.0) { //判断系统版本方法一
        UIImage *image = [UIImage imageNamed:@"navigationbar_bg_4"];
        [self.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    } else {
        //调用setNeedsDisplay方法会让绚烂引擎异步调用drawRect方法
//        [self.navigationBar setNeedsDisplay];
    }
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

@end
