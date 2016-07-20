//
//  TermViewController.m
//  JKCourse
//
//  Created by MacOS on 15-1-23.
//  Copyright (c) 2015年 Joker. All rights reserved.
//

#import "TermViewController.h"
#import "TermCell.h"
#import "Term.h"
#import "Public.h"
#import "JKCourse-Prefix.pch"
@interface TermViewController ()

@end

@implementation TermViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"学期";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //左侧按钮
    UIButton *leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 51, 30)];
    [leftButton setImage:[UIImage imageNamed:@"bb_back_bt.png"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;

    
     self.view.backgroundColor = RGBColor(229, 235, 242, 1);
    
    //初始化表格
    _tableView = [[YFJLeftSwipeDeleteTableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-64) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    [self.view addSubview:_tableView];
    
    //初始化添加学期的视图
    [self _initTermView];
    
    [self showHUD:@"正在加载..." isDim:NO];
    //加载数据
    [self performSelector:@selector(loadTermDatas) withObject:nil afterDelay:0.5];
}


- (void)loadTermDatas
{
    NSString *termPath = [[NSBundle mainBundle] pathForResource:@"terms" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:termPath];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    _termsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < array.count; i++) {
        Term *term = [[Term alloc] initWithPropertiesDictionary:array[i]];
        [_termsArray addObject:term];
    }
    [_tableView reloadData];
    [self hideHUD];
}

- (void)_initTermView
{
    overLayView = [[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    overLayView.backgroundColor = RGBColor(173, 176, 182, 0.7);
    overLayView.hidden = YES;
    overLayView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overLayClick)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [overLayView addGestureRecognizer:tapGestureRecognizer];
    
    self.years = [[NSArray alloc] initWithObjects:@"2005-2006",@"2006-2007",@"2007-2008",@"2008-2009",@"2009-2010",@"2010-2011",@"2011-2012",@"2012-2013",@"2013-2014",@"2014-2015",@"2015-2016",@"2016-2017",@"2017-2018",@"2018-2019",@"2019-2020", nil];
    self.terms = [[NSArray alloc] initWithObjects:@"1",@"2", nil];
    
    termView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight-20-44-256, ScreenWidth, 256)];
    termView.backgroundColor = [UIColor whiteColor];
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 60, 30)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:WEEKDAY_FONT_COLOR forState:UIControlStateNormal];
    [termView addSubview:cancelButton];

    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-160)/2, 5, 160, 30)];
    titleLabel.text = @"请选择学年学期";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [termView addSubview:titleLabel];
 
    
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth-70, 5, 60, 30)];
    [doneButton setTitle:@"创建" forState:UIControlStateNormal];
    [doneButton setTitleColor:WEEKDAY_FONT_COLOR forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    [termView addSubview:doneButton];

    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, ScreenWidth, 216)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator = YES;
    [termView addSubview:pickerView];
    [overLayView addSubview:termView];
    
    [self.view addSubview:overLayView];
    overLayView.hidden = YES;
    
    NSDate *today = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:today];
    
    int year = dateComponents.year;
    NSString  *str = [NSString stringWithFormat:@"%d-%d",year,year+1];
    NSInteger index = [_years indexOfObject:str];
    [pickerView selectRow:index inComponent:0 animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private method
//返回事件方法
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction
{
    NSInteger firstIndex = [pickerView selectedRowInComponent:0];
    NSInteger sencoudIndex = [pickerView selectedRowInComponent:1];
    
    NSString  *year = [_years objectAtIndex:firstIndex];
    NSString  *_term = [_terms objectAtIndex:sencoudIndex];
    Term  *term = [[Term alloc] init];
    term.year = year;
    term.term = _term;
    [_termsArray addObject:term];
    [_tableView reloadData];
    
}

- (void)addTermAction:(id)sender{
    overLayView.hidden = NO;
    termView.hidden = NO;
    
    //动画
    termView.transform = CGAffineTransformMakeScale(1.3, 1.3);
    termView.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        termView.alpha = 1;
        termView.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}

- (void)overLayClick
{
    overLayView.hidden = YES; //隐藏
    
    //动画
    [UIView animateWithDuration:.15 animations:^{
        termView.transform = CGAffineTransformMakeScale(1.3, 1.3);
        termView.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            overLayView.hidden = YES;
            termView.hidden = YES;
        }
    }];
}

//另一种加在提示框
- (void)showHUD:(NSString *)title isDim:(BOOL)isDim
{
    _HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_HUD];
    _HUD.delegate = self;
    _HUD.dimBackground = isDim;
    _HUD.labelText = title;
    [_HUD show:YES];
}

//隐藏提示框
- (void)hideHUD
{
    [_HUD hide:YES];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _termsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"termCell";
    TermCell *cell = (TermCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"TermCell" owner:self options:nil] lastObject];
    }
    Term *term = _termsArray[indexPath.row];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *currentYear = [userDefaults objectForKey:CURRENTYEAR];
    NSString *currentTerm = [userDefaults objectForKey:CURRENTTERM];
    
    NSString *text = [NSString stringWithFormat:@"%@学年  第%@学期",term.year,term.term];

    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.termLabel.text = text;
    if ([currentYear isEqual:term.year] && [currentTerm isEqual:term.term]) {
       term.isChecked = YES;
    }else {
        term.isChecked = NO;
    }
    cell.isChecked = term.isChecked;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_termsArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 88;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 88)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 22)];
    view.backgroundColor = RGBColor(229, 235, 242, 1);
    [headerView addSubview:view];
    
    headerView.backgroundColor = [UIColor clearColor];
    
    UIButton *semesterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    semesterButton.backgroundColor = RGBColor(207, 213, 220, 1);
    semesterButton.frame = CGRectMake(0, 22, ScreenWidth, 44);
    [semesterButton addTarget:self action:@selector(addTermAction:) forControlEvents:UIControlEventTouchUpInside];
    [semesterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [semesterButton setTitle:@"添加新的学期" forState:UIControlStateNormal];
    [semesterButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -19)];
    [semesterButton setImage:[UIImage imageNamed:@"course_add"] forState:UIControlStateNormal];
    [headerView addSubview:semesterButton];
    return headerView;
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [_years count];
    }
    
    return [_terms count];
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = nil;
    if (component == 0) {
        title = [[NSString alloc] initWithFormat:@"%@学年",_years[row]];
    }else {
        title = [[NSString alloc] initWithFormat:@"第%@学期",_terms[row]];
    }
    return title;
}

- (UIView *)pickerView:(UIPickerView *)_pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
    }
    // Fill the label text here
    pickerLabel.text=[self pickerView:_pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (component == 0) {
        return 200;
    }
    
    return ScreenWidth-200;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //第0列
    if(component == 0)
    {
        NSLog(@"第0列:%@",_years[row]);
    }
    //第1列
    if(component == 1)
    {
        NSLog(@"第1列:%@",_terms[row]);
    }
}

#pragma mark - TermCellDelegate
- (void)choseTerm:(UIButton *)button
{
    _clickIndex = button.tag;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"确定修改学期吗？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark - MBProgressHUDDelegate
- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[hud removeFromSuperview];
	hud = nil;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"取消");
        return;
    }
    
    for (Term *term in _termsArray) {
        term.isChecked = NO;
    }
    Term *term = _termsArray[_clickIndex];
    term.isChecked = YES;
    
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setObject:term.year forKey:CURRENTYEAR];
    [userdefaults setObject:term.term forKey:CURRENTTERM];
    [userdefaults synchronize];
    
    NSLog(@"Term:%@",term);
    [_tableView reloadData];
    
    [self.navigationController popViewControllerAnimated:YES];
    _backBlock();
}

@end
