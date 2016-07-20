//
//  Term.m
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import "Term.h"

@implementation Term

- (id)initWithPropertiesDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        if (dic != nil) {
            self.year = [dic objectForKey:@"year"];
            self.term = [dic objectForKey:@"term"];
        }
    }
    
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"year : %@\n",self.year];
    result = [result stringByAppendingFormat:@"term : %@\n",self.term];
    return result;
}



@end
