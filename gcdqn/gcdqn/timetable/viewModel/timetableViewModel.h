//
//  timetableViewModel.h
//  gcdqn
//
//  Created by admin on 16/7/21.
//  Copyright © 2016年 hardtosaygoodbye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface timetableViewModel : NSObject
//@property (nonatomic,strong) NSArray *data;
@property (nonatomic,copy) void (^returnValueBlock)(id returnValue);

- (void)getTimetableData;

@end
