//
//  TermCell.h
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TermCellDelegate <NSObject>

- (void)choseTerm:(UIButton *)button;

@end

@interface TermCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIButton *checkButton;
@property (retain, nonatomic) IBOutlet UILabel *termLabel;

@property (assign, nonatomic) BOOL  isChecked;
@property (assign, nonatomic) id<TermCellDelegate> delegate;

- (IBAction)checkAction:(UIButton *)sender;

@end
