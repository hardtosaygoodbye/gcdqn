//
//  timetableViewModel.m
//  gcdqn
//
//  Created by admin on 16/7/21.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import "timetableViewModel.h"
#import "TimetableModel.h"
@interface timetableViewModel()

@end

@implementation timetableViewModel


////模拟从本地获取json，转nsdata，转字典
//-(NSArray *)data
//{
//    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"course" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
//    NSArray *arr = dic[@"data"][@"lessonList"];
//    _data = arr;
//    NSLog(@"%@",arr[0]);
//    return _data;
//}

/*
 @property (nonatomic,copy) NSString *name;
 @property (nonatomic,copy) NSString *smartPeriod;
 @property (nonatomic,strong) NSNumber *day;
 @property (nonatomic,strong) NSNumber *sectionstart;
 @property (nonatomic,strong) NSNumber *sectionend;
 */

- (void)getTimetableData
{
    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"course" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:nil];
    NSArray *arr = dic[@"data"][@"lessonList"];
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    for (int i=0; i<arr.count; i++) {
        NSDictionary *tempDic = arr[i];
        TimetableModel *model = [[TimetableModel alloc]init];
        model.name = tempDic[@"name"];
        model.smartPeriod = tempDic[@"smartPeriod"];
        model.day = tempDic[@"day"];
        model.sectionstart = tempDic[@"sectionstart"];
        model.sectionend = tempDic[@"sectionend"];
        model.teacher = tempDic[@"teacher"];
        model.locale = tempDic[@"locale"];
        model.period = tempDic[@"period"];
        [modelArray addObject:model];
    }
    
    _returnValueBlock(modelArray);
    
}

@end
