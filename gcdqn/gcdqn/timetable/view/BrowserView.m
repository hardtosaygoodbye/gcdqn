//
//  BrowserView.m
//  buttonDemo
//
//  Created by lixu on 16/8/1.
//  Copyright © 2016年 lixu. All rights reserved.
//

#import "BrowserView.h"

#define kBaseTag 100
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kItemSpacing 25.0
#define kItemWidth  60.0
#define kItemHeight 85.0
#define kItemSelectedWidth  75.0
#define kItemSelectedHeight 108.0
#define kScrollViewContentOffset (kScreenWidth / 2.0 - (kItemWidth / 2.0 + kItemSpacing))

@interface BrowserView () <UIScrollViewDelegate>

@property (nonatomic, assign, readwrite) NSInteger      currentIndex;
@property (nonatomic, strong, readwrite) NSMutableArray *models;
@property (nonatomic, strong, readwrite) NSMutableArray *items;
@property (nonatomic, assign, readwrite) CGPoint        scrollViewContentOffset;
@property (nonatomic, strong, readwrite) UIScrollView   *scrollView;
@property (nonatomic, strong, readwrite) UIImageView    *backgroundView;

@end

@implementation BrowserView
-(instancetype)initWithFrame:(CGRect)frame models:(NSArray *)models currentIndex:(NSInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.models = [models mutableCopy];
        [self commonInit];
        [self setCurrentModelIndex:index];
    }
    
    return self;
}

- (void)setCurrentModelIndex:(NSInteger)index
{
    if (index >= 0 && index < self.models.count) {
        self.currentIndex = index;
        CGPoint point = CGPointMake((kItemSpacing + kItemWidth) * index - kScrollViewContentOffset, 0);
        [self.scrollView setContentOffset:point animated:NO];
        
        [self backgroundViewFadeTransition];
    }
}

#pragma mark - Setup

- (void)commonInit
{
    _backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    _backgroundView.contentMode = UIViewContentModeScaleToFill;//图片按照UIImageView区域变形填满，达到背景颜色和当前的图片颜色一致（下面代码会处理）
    _backgroundView.backgroundColor = [UIColor grayColor];
    [self addSubview:_backgroundView];
    if (self.models.count > 0) {
        [_backgroundView setImage:[UIImage imageNamed:@"image0"]];
    }
    
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];//当前视图添加blur效果
    blurView.frame = self.bounds;
    [self addSubview:blurView];
    
    [self setupScrollView];
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [self addSubview:_scrollView];
    _scrollView.showsHorizontalScrollIndicator = NO;//不显示滑动条
    _scrollView.decelerationRate = UIScrollViewDecelerationRateFast;//滑动后快速减速
    _scrollView.alwaysBounceHorizontal = YES;//视图总是能拖动
    _scrollView.delegate = self;
    _scrollView.contentInset = UIEdgeInsetsMake(0, kScrollViewContentOffset, 0, kScrollViewContentOffset);//跟上下左右的边距,以便滑动到最两端的图片能显示到中间
    //    _scrollView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20);//跟上下左右的边距
    _scrollView.contentSize = CGSizeMake((kItemWidth + kItemSpacing) * self.models.count + kItemSpacing, BrowserHeight);
    if (LX_DEBUG) {
        NSLog(@"_scrollView.contentOffset = %@",NSStringFromCGPoint(_scrollView.contentOffset));
    }
    NSInteger i = 0;
    _items = [NSMutableArray array];
    for (TimetableModel *movie in self.models) {
        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake((kItemSpacing + kItemWidth) * i + kItemSpacing, BrowserHeight - kItemHeight, kItemWidth, kItemHeight)];
        [_scrollView addSubview:itemView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kItemWidth, kItemHeight)];
        button.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:0.7];
        button.layer.borderWidth = 1.0;
        
        button.userInteractionEnabled = YES;
        button.tag = i + kBaseTag;
        [itemView addSubview:button];
        [self.items addObject:button];
        
        [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:movie.name forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:10];
        i++;
    }
}

#pragma mark - Layout
/*
 1)直接调用setLayoutSubviews。（这个在上面苹果官方文档里有说明）
 2)addSubview的时候。
 3)当view的frame发生改变的时候。
 4)滑动UIScrollView的时候。
 5)旋转Screen会触发父UIView上的layoutSubviews事件。
 6)改变一个UIView大小的时候也会触发父UIView上的layoutSubviews事件。
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.models.count != 0) {
        static dispatch_once_t onceToken;//只执行一次，最开始的时候设置标题label.text
        dispatch_once(&onceToken, ^{
//            if ([self.delegate respondsToSelector:@selector(browser:didChangeItem:)]) {
//                TimetableModel *model = (TimetableModel *)self.models[self.currentIndex];
//                [self.delegate browser:self didChangeItem:model.name];
//            }
            if ([self.delegate respondsToSelector:@selector(browser:didEndScrollingAtIndex:)]) {
                [self.delegate browser:self didEndScrollingAtIndex:self.currentIndex];
            }
        });
        [self adjustSubviews:self.scrollView];
    }
}

- (void)adjustSubviews:(UIScrollView *)scrollView
{
    
    NSInteger index = (scrollView.contentOffset.x + kScrollViewContentOffset) / (kItemWidth + kItemSpacing);
    index = MIN(self.models.count - 1, MAX(0, index));//index范围，必须是（0到self.movies.count - 1之间）
    
    CGFloat scale = (scrollView.contentOffset.x + kScrollViewContentOffset - (kItemWidth + kItemSpacing) * index) / (kItemWidth + kItemSpacing);
    
    if (self.models.count > 0) {
        CGFloat height;
        CGFloat width;
        
        if (scale < 0.0) {
            scale = 1 - MIN(1.0, ABS(scale));
            
            UIImageView *leftView = self.items[index];
            leftView.layer.borderColor = [UIColor colorWithWhite:1 alpha:scale].CGColor;
            height = kItemHeight + (kItemSelectedHeight - kItemHeight) * scale;
            width = kItemWidth + (kItemSelectedWidth - kItemWidth) * scale;
            leftView.frame = CGRectMake(-(width - kItemWidth) / 2, -(height - kItemHeight), width, height);
            
            if (index + 1 < self.models.count) {
                UIImageView *rightView = self.items[index + 1];
                rightView.frame = CGRectMake(0, 0, kItemWidth, kItemHeight);
                rightView.layer.borderColor = [UIColor clearColor].CGColor;
            }
            
        } else if (scale <= 1.0) {
            if (index + 1 >= self.models.count) {
                
                scale = 1 - MIN(1.0, ABS(scale));
                
                UIButton *button = self.items[self.models.count - 1];
                button.layer.borderColor = [UIColor colorWithWhite:1 alpha:scale].CGColor;
                height = kItemHeight + (kItemSelectedHeight - kItemHeight) * scale;
                width = kItemWidth + (kItemSelectedWidth - kItemWidth) * scale;
                button.frame = CGRectMake(-(width - kItemWidth) / 2, -(height - kItemHeight), width, height);
                
            } else {
                CGFloat scaleLeft = 1 - MIN(1.0, ABS(scale));
                UIImageView *leftView = self.items[index];
                leftView.layer.borderColor = [UIColor colorWithWhite:1 alpha:scaleLeft].CGColor;
                height = kItemHeight + (kItemSelectedHeight - kItemHeight) * scaleLeft;
                width = kItemWidth + (kItemSelectedWidth - kItemWidth) * scaleLeft;
                leftView.frame = CGRectMake(-(width - kItemWidth) / 2, -(height - kItemHeight), width, height);
                
                CGFloat scaleRight = MIN(1.0, ABS(scale));
                UIImageView *rightView = self.items[index + 1];
                rightView.layer.borderColor = [UIColor colorWithWhite:1 alpha:scaleRight].CGColor;
                height = kItemHeight + (kItemSelectedHeight - kItemHeight) * scaleRight;
                width = kItemWidth + (kItemSelectedWidth - kItemWidth) * scaleRight;
                rightView.frame = CGRectMake(-(width - kItemWidth) / 2, -(height - kItemHeight), width, height);
            }
        }
        
        for (UIImageView *imgView in self.items) {
            if (imgView.tag != index + kBaseTag && imgView.tag != (index + kBaseTag + 1)) {
                imgView.frame = CGRectMake(0, 0, kItemWidth, kItemHeight);
                imgView.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }
    }
}

#pragma mark - Tap Detection

- (void)clickBtn:(UIButton *)btn
{
    if (btn.tag == self.currentIndex + kBaseTag) {
        if ([self.delegate respondsToSelector:@selector(browser:didSelectItem:)]) {
            [self.delegate browser:self didSelectItem:(TimetableModel *)self.models[self.currentIndex]];
            return;
        }
    }
    
    CGPoint point = [btn.superview convertPoint:btn.center toView:self.scrollView];
    point = CGPointMake(point.x - kScrollViewContentOffset - ((kItemWidth / 2 + kItemSpacing)), 0);
    self.scrollViewContentOffset = point;
    
    [self.scrollView setContentOffset:point animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = (scrollView.contentOffset.x + kScrollViewContentOffset + (kItemWidth / 2 + kItemSpacing / 2)) / (kItemWidth + kItemSpacing);
    index = MIN(self.models.count - 1, MAX(0, index));
    
    if (self.currentIndex != index) {
        self.currentIndex = index;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(BrowserDidEndScrolling) object:nil];
    
    [self adjustSubviews:scrollView];
    
    if (LX_DEBUG) {
        NSLog(@"_scrollView.contentOffset = %@",NSStringFromCGPoint(_scrollView.contentOffset));
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSInteger index = (targetContentOffset->x + kScrollViewContentOffset + (kItemWidth / 2 + kItemSpacing / 2)) / (kItemWidth + kItemSpacing);
    targetContentOffset->x = (kItemSpacing + kItemWidth) * index - kScrollViewContentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self performSelector:@selector(BrowserDidEndScrolling) withObject:nil afterDelay:0.1];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (!CGPointEqualToPoint(self.scrollViewContentOffset, self.scrollView.contentOffset)) {
        [self.scrollView setContentOffset:self.scrollViewContentOffset animated:YES];
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self BrowserDidEndScrolling];
        });
    }
    
}

#pragma mark - end scrolling handling

- (void)BrowserDidEndScrolling
{
    if ([self.delegate respondsToSelector:@selector(browser:didEndScrollingAtIndex:)]) {
        [self.delegate browser:self didEndScrollingAtIndex: self.currentIndex];
    }
    
    if (self.currentIndex < self.models.count) {
        [self backgroundViewFadeTransition];
    }
}

#pragma mark - backgroundView

- (void)backgroundViewFadeTransition
{
    [self.backgroundView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%u",(arc4random()%4)+5]]];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.45f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.backgroundView.layer addAnimation:transition forKey:nil];
}

#pragma mark - setters

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    
//    if ([self.delegate respondsToSelector:@selector(browser:didChangeItem:)]) {
//        TimetableModel *model = (TimetableModel *)self.models[self.currentIndex];
//        [self.delegate browser:self didChangeItem:model.name];
//    }
}
@end
