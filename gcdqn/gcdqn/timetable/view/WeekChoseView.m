//
//  WeekChoseView.m
//  ismarter2.0_sz
//
//  Created by MacOS on 15-1-4.
//
//

#import "WeekChoseView.h"
#import <QuartzCore/QuartzCore.h>
#import "Public.h"
@implementation WeekChoseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self _initViews];
    }
    return self;
}

//初始化子视图
- (void)_initViews
{
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAction)];
    [self addGestureRecognizer:tapGesture];
    
    numLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 25, 25)];
    numLabel.textAlignment = NSTextAlignmentCenter;
    numLabel.textColor = WEEKDAY_FONT_COLOR;
    numLabel.layer.cornerRadius = 13.0f;
    numLabel.layer.masksToBounds = YES;
    numLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:numLabel];
    
    setButton = [[UIButton alloc] initWithFrame:CGRectMake(2, 40, 45, 14)];
    [setButton setBackgroundImage:[UIImage imageNamed:@"course_set.png"] forState:UIControlStateNormal];
    [setButton setTitle:@"设为本周" forState:UIControlStateNormal];
    setButton.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    [setButton addTarget:self action:@selector(setWeek:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:setButton];
    setButton.hidden = YES;
}

- (void)setNumber:(NSString *)number
{
    if (_number != number) {
        _number = [number copy];
    }
    
    numLabel.text = _number;
}


- (void)reset
{
    if (self.isChosen) { //被选中后改变:背景变红色，文字变白色，按钮显示
        numLabel.backgroundColor = RGBColor(252, 82, 89, 1);
        numLabel.textColor = [UIColor whiteColor];
        setButton.hidden = NO;
        if (_isCurrentWeek) { //如果正好是当前周，则设置按钮不显示
            setButton.hidden = YES;
        }
    } else {
        setButton.hidden = YES;
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textColor = WEEKDAY_FONT_COLOR;
        if (self.isCurrentWeek) { //没选中时，如果正好是当前周，背景为灰色，文字为白色
            numLabel.backgroundColor = [UIColor lightGrayColor];
            numLabel.textColor = [UIColor whiteColor];
        }
    }

}

- (void)clickAction
{
    if (!self.isChosen) {
        self.isChosen = YES;
        [self reset];
        if ([self.delegate respondsToSelector:@selector(tapAction:)]) {
            [self.delegate tapAction:self.tag];
        }
    }
}

- (void)setWeek:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(setCurrentWeek:)]) {
        [self.delegate setCurrentWeek:self.number];
    }
}

@end
