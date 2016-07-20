//
//  WeekCourse.m
//  ismarter2.0_sz
//
//  Created by MacOS on 14-12-25.
//
//

#import "WeekCourse.h"

@implementation WeekCourse

- (id)initWithPropertiesDictionary:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        if (dic != nil) {
            self.studentId = [dic objectForKey:@"studentId"];
            self.term = [dic objectForKey:@"term"];
            self.weeks = [dic objectForKey:@"weeks"];
            self.day = [dic objectForKey:@"weekDay"];
            self.lesson = [dic objectForKey:@"lessons"];
            self.lessonsNum = [dic objectForKey:@"lessonsNum"];
            self.courseCode = [dic objectForKey:@"courseCode"];
            self.courseName = [dic objectForKey:@"courseName"];
            self.classRoom = [dic objectForKey:@"claRoom"];
            self.teacherName = [dic objectForKey:@"teacherName"];
            self.seWeek = [dic objectForKey:@"seWeek"];
            self.capter = [dic objectForKey:@"capter"];
        }
    }
    return self;
}

- (NSString *)description
{
    NSString *result = @"";
    result = [result stringByAppendingFormat:@"studentId : %@\n",self.studentId];
    result = [result stringByAppendingFormat:@"term : %@\n",self.term];
    result = [result stringByAppendingFormat:@"weeks : %@\n",self.weeks];
    result = [result stringByAppendingFormat:@"day : %@\n",self.day];
    result = [result stringByAppendingFormat:@"lesson : %@\n",self.lesson];
    result = [result stringByAppendingFormat:@"lessonsNum : %@\n",self.lessonsNum];
    result = [result stringByAppendingFormat:@"courseCode : %@\n",self.courseCode];
    result = [result stringByAppendingFormat:@"courseName : %@\n",self.courseName];
    result = [result stringByAppendingFormat:@"classRoom : %@\n",self.classRoom];
    result = [result stringByAppendingFormat:@"teacherName : %@\n",self.teacherName];
    result = [result stringByAppendingFormat:@"seWeek: %@\n",self.seWeek];
    result = [result stringByAppendingFormat:@"capter: %@\n",self.capter];
    return result;
}


@end
