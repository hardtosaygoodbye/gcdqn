//
//  BrowserView.h
//  buttonDemo
//
//  Created by lixu on 16/8/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimetableModel.h"
#import "Public.h"

#define BrowserHeight 125.0

@class BrowserView;
@protocol BrowserViewDelegate <NSObject>

@optional
- (void)browser:(BrowserView *)browser didSelectItem:(TimetableModel *)model;
- (void)browser:(BrowserView *)browser didEndScrollingAtIndex:(NSInteger)index;
//- (void)browser:(BrowserView *)browser didChangeItem:(NSString *)name;

@end

@interface BrowserView : UIView

@property (nonatomic, assign, readwrite) id<BrowserViewDelegate> delegate;
//@property (nonatomic, assign, readonly)  NSInteger currentIndex;

- (instancetype)initWithFrame:(CGRect)frame models:(NSArray *)models currentIndex:(NSInteger)index;

//- (void)setCurrentModelIndex:(NSInteger)index;
@end
