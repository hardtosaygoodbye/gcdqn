//
//  timetableViewModel.m
//  gcdqn
//
//  Created by admin on 16/7/21.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "timetableViewModel.h"

@interface timetableViewModel()

@end

@implementation timetableViewModel


//模拟从本地获取json，转nsdata，转字典
-(NSArray *)data
{
    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"course" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSArray *arr = dic[@"data"][@"lessonList"];
    _data = arr;
    NSLog(@"%@",arr[0]);
    return _data;
}

@end
