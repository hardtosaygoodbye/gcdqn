//
//  TermViewController.h
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YFJLeftSwipeDeleteTableView.h"
#import "TermCell.h"
#import "MBProgressHUD.h"


typedef void(^BackBlock)(void);

@interface TermViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,TermCellDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate,MBProgressHUDDelegate>
{
    MBProgressHUD   *_HUD;
    UIView          *overLayView;               //一个遮罩视图
    UIView          *termView;                  //放学年学期视图
    UIPickerView    *pickerView;                //
}

@property (nonatomic, retain) NSArray   *years;
@property (nonatomic, retain) NSArray   *terms;

@property (nonatomic, copy) BackBlock   backBlock;

@property (nonatomic, retain) YFJLeftSwipeDeleteTableView *tableView;
@property (nonatomic, retain) NSMutableArray   *termsArray;
@property (nonatomic, assign) NSInteger     clickIndex;

@end
