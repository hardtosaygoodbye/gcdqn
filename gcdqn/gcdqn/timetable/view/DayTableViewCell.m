//
//  DayTableViewCell.m
//  Course
//
//  Created by MacOS on 14-12-16.
//  Copyright (c) 2014年 Joker. All rights reserved.
//

#import "DayTableViewCell.h"
#import "Public.h"
@implementation DayTableViewCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setWeekCourse:(WeekCourse *)weekCourse
{
    if (_weekCourse != weekCourse) {
        _weekCourse = weekCourse;
    }
    
    self.capterLabel.text = weekCourse.capter;
    self.courseNameLabel.text = weekCourse.courseName;
    self.addressLabel.text = weekCourse.classRoom;
    self.circleLabel.text = weekCourse.seWeek?[NSString stringWithFormat:@"%@周",weekCourse.seWeek]:nil;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_weekCourse.haveLesson) {
        self.addressIcon.hidden = NO;
        self.circleIcon.hidden = NO;
        self.capterLabel.textColor = RGBColor(255, 122, 58, 1);
    } else{
        self.addressIcon.hidden = YES;
        self.circleIcon.hidden = YES;
        CGRect frame = self.capterLabel.frame;
        int y = (self.bounds.size.height - frame.size.height)/2;
        frame.origin.y = y;
        self.capterLabel.frame = frame;
        self.capterLabel.textColor = WEEKDAY_FONT_COLOR;
    }
}


@end
