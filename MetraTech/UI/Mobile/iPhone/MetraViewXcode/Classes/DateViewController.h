//
//  DateViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/2/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateViewDelegate <NSObject>
@required
- (void)takeNewDate:(NSString *)newDate;
//- (UINavigationController *)navController;          // Return the navigation controller
@end

@interface DateViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIPickerView            *pickerView;
    UITableView             *dateTableView;
	NSMutableArray *months;
	NSMutableArray *years;
	int selection[2];
    id <DateViewDelegate>   delegate;   // weak ref
	NSString *dateAsString;
}

@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UITableView *dateTableView;
@property (nonatomic, assign) id <DateViewDelegate> delegate;
@property (nonatomic, retain) NSString *dateAsString;

-(void)updateText;
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component;
-(NSInteger)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(NSInteger)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;

@end