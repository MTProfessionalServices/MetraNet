//
//  DateViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/2/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "DateViewController.h"

@implementation DateViewController
@synthesize pickerView;
@synthesize dateTableView;
@synthesize dateAsString;
@synthesize delegate;

-(id)init {
	self = [super init];
	if(self != nil) {
		months = [[NSMutableArray alloc] init];
		[months addObject: @"01"];
		[months addObject: @"02"];
		[months addObject: @"03"];
		[months addObject: @"04"];
		[months addObject: @"05"];
		[months addObject: @"06"];
		[months addObject: @"07"];
		[months addObject: @"08"];
		[months addObject: @"09"];
		[months addObject: @"10"];
		[months addObject: @"11"];
		[months addObject: @"12"];
		
		years = [[NSMutableArray alloc] init];
		[years addObject: @"2010"];
		[years addObject: @"2011"];
		[years addObject: @"2012"];
		[years addObject: @"2013"];
		[years addObject: @"2014"];
		[years addObject: @"2015"];
		[years addObject: @"2016"];
		[years addObject: @"2017"];
		[years addObject: @"2018"];
		[years addObject: @"2019"];
		[years addObject: @"2020"];
		[years addObject: @"2021"];
		[years addObject: @"2022"];
		[years addObject: @"2023"];
		[years addObject: @"2024"];
		[years addObject: @"2025"];
		
		selection[0] = selection[1] = 0;
	}
	return self;
}

-(void)updateText
{
	self.dateAsString =  [NSString stringWithFormat:@"%@/%@", [months objectAtIndex:selection[0]], [years objectAtIndex:selection[1]]];
	[dateTableView reloadData];
}

-(IBAction)cancel
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)save
{
    [self.delegate takeNewDate:dateAsString];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)loadView
{
    UIView *theView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = theView;
    [theView release];
	
    UITableView *theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 67.0, 320.0, 480.0) style:UITableViewStyleGrouped];
    theTableView.delegate = self;
    theTableView.dataSource = self;
    [self.view addSubview:theTableView];
    self.dateTableView = theTableView;
    [theTableView release];
    
    UIPickerView *theDatePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 200.0, 320.0, 216.0)];
    theDatePicker.delegate = self;
	theDatePicker.dataSource = self;
	theDatePicker.showsSelectionIndicator = YES;
    self.pickerView = theDatePicker;
    [theDatePicker release];
    [self.view addSubview:pickerView];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
                                     initWithTitle:NSLocalizedString(@"Cancel", @"Cancel - for button to cancel changes")
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(cancel)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle:NSLocalizedString(@"Select", @"Select - for button to save changes")
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(save)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton release];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
}

/*
 could set selected here
- (void)viewWillAppear:(BOOL)animated
{
    if (self.date != nil)
        [self.pickerView setDate:date animated:YES];
    else 
        [self.pickerView setDate:[NSDate date] animated:YES];
    
    [super viewWillAppear:animated];
}
*/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc 
{
    [pickerView release];
    [dateTableView release];
    [dateAsString release];
	[months release];
	[years release];
    [super dealloc];
}
#pragma mark -
#pragma mark Table View Methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *DateCellIdentifier = @"DateCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DateCellIdentifier];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:DateCellIdentifier] autorelease];
        [[cell textLabel] setFont:[UIFont systemFontOfSize:17.0]];
        [[cell textLabel] setTextColor:[UIColor colorWithRed:0.243 green:0.306 blue:0.435 alpha:1.0]];
    }
    
  //  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  //  [formatter setDateFormat:@"MMMM dd, yyyy"];
  
	
	[[cell textLabel] setText:dateAsString];
  //  [formatter release];
	
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;   
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Select Expiration Date (mm/yyyy)";
			break;
		default:
			return @"";
			break;
	}
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger) component {
	switch (component) {
		case (0):
			return [months count];	
			break;
		case (1):
			return [years count];
			break;
		default:
			return 0;
			break;
	}
}

-(NSInteger)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	switch (component) {
		case (0):
			return (int)[months objectAtIndex: row];
			break;
		case (1):
			return (int)[years objectAtIndex: row];
			break;
		default:
			return 0;
			break;
	}
}

-(NSInteger)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	selection[component] = row;
	[self updateText];
	return row;
}

@end