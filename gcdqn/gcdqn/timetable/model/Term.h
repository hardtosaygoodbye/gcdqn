//
//  Term.h
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Term : NSObject

@property (nonatomic, copy) NSString     *year;
@property (nonatomic, copy) NSString     *term;

@property (nonatomic, assign) BOOL      isChecked;

- (id)initWithPropertiesDictionary:(NSDictionary *)dic;

@end
