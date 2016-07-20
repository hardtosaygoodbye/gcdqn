//
//  DayTableViewCell.h
//  Course
//
//  Created by MacOS on 14-12-16.
//  Copyright (c) 2014年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeekCourse.h"

@interface DayTableViewCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *capterLabel;
@property (retain, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *addressIcon;
@property (retain, nonatomic) IBOutlet UILabel *addressLabel;
@property (retain, nonatomic) IBOutlet UIImageView *circleIcon;
@property (retain, nonatomic) IBOutlet UILabel *circleLabel;

@property (nonatomic, retain) WeekCourse *weekCourse;
@end
