//
//  PaymentAddViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/23/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "PaymentAddViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "CVVView.h"
#import "CheckView.h"

#define kTextFieldWidth	        170.0
#define kLeftMargin				135.0
#define kTextFieldHeight		30.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kControlTypeKey = @"controlTypeKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kViewKey = @"viewKey";
static NSString *kFieldsKey = @"fieldsKey";
static NSString *kValueKey = @"valueKey";

const NSInteger kTagLabel = 0;
const NSInteger kTagPaymentMehtod = 1;
const NSInteger kTagTextField = 2;
const NSInteger kTagCVV = 3;
const NSInteger kTagDatePicker= 4;
const NSInteger kTagRoutingNumber= 5;
const NSInteger kTagBankNumber= 6;
const NSInteger kTagAccountType= 7;

@implementation PaymentAddViewController

@synthesize segPaymentMethod, textFieldCCNumber, textFieldCCV, labelExpDate, switchCheckingSavings, textFieldRoutingNumber, textFieldBankAccount;
@synthesize dataSourceArrayCredit, dataSourceArrayChecking ;
@synthesize saveButton;

- (void)freeOutletsAndSubviews
{
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	[segPaymentMethod release]; segPaymentMethod = nil;
	[textFieldCCNumber release]; textFieldCCNumber = nil;
	[textFieldCCV release]; textFieldCCV = nil;
	[labelExpDate release]; labelExpDate = nil;
	
	[switchCheckingSavings release]; switchCheckingSavings = nil;
	[textFieldRoutingNumber release]; textFieldRoutingNumber = nil;
	[textFieldBankAccount release]; textFieldBankAccount = nil;
}

- (void)dealloc
{
	[self freeOutletsAndSubviews];
	[dataSourceArrayCredit release];
	[dataSourceArrayChecking release];
	[saveButton release];
	[super dealloc];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self freeOutletsAndSubviews];
	self.dataSourceArrayCredit = nil;
	self.dataSourceArrayChecking = nil;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// add button
	saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePaymentMethod:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	
	selectedPaymentMethod  = 0;  // default to credit view (credit/debit = 0, checking/savings = 1)
	selectedAccountType = 0;     // bank account type (checking = 0, savings = 1)
	
	// Credit View
	self.dataSourceArrayCredit = [NSArray arrayWithObjects:
							
							// Section 0   
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Select Payment Type", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  // PaymentMethod 
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"PaymentMethod", kControlTypeKey,
							   @"Payment Method", kLabelKey,
							   self.segPaymentMethod, kViewKey,
							   @"0", kValueKey,
							   nil],
							  
							  nil], kFieldsKey,
							 
							 nil],
							
							// Section 1  
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Credit / Debit Information", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  // CCNumber 
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Card #", kLabelKey,
							   self.textFieldCCNumber, kViewKey,
							   @"", kValueKey,
							   nil],
							  
							  // CVV
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"CVV", kControlTypeKey,
							   @"CVV", kLabelKey,
							   self.textFieldCCV, kViewKey,
							   @"", kValueKey,
							   nil],
							  
							  // Expiration Date
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"DatePicker", kControlTypeKey,
							   @"Exp. Date", kLabelKey,
							   self.labelExpDate, kViewKey,
							   @"<mm/yyyy>", kValueKey,
							   nil],

							  nil], kFieldsKey,
							 
							 nil],
							
							nil];
	
	// Checking View
	self.dataSourceArrayChecking = [NSArray arrayWithObjects:
								  
								  // Section 0   
								  [NSDictionary dictionaryWithObjectsAndKeys:
								   @"Select Payment Type", kSectionTitleKey,
								   
								   // Array of Fields
								   [NSArray arrayWithObjects:
									
									// PaymentMethod 
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"PaymentMethod", kControlTypeKey,
									 @"Payment Method", kLabelKey,
									 self.segPaymentMethod, kViewKey,
									 @"1", kValueKey,
									 nil],
									
									nil], kFieldsKey,
								   
								   nil],
								  
								  // Section 1  
								  [NSDictionary dictionaryWithObjectsAndKeys:
								   @"Checking / Saving Information", kSectionTitleKey,
								   
								   // Array of Fields
								   [NSArray arrayWithObjects:
																		
									// Routing # 
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"RoutingNumber", kControlTypeKey,
									 @"Routing #", kLabelKey,
									 self.textFieldRoutingNumber, kViewKey,
									 @"", kValueKey,
									 nil],
									
									// Bank Account # 
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"BankNumber", kControlTypeKey,
									 @"Bank Act. #", kLabelKey,
									 self.textFieldBankAccount, kViewKey,
									 @"", kValueKey,
									 nil],
									
									// Bank Account Type
									[NSDictionary dictionaryWithObjectsAndKeys:
									 @"AccountType", kControlTypeKey,
									 @"Act. Type", kLabelKey,
									 self.switchCheckingSavings, kViewKey,
									 @"0", kValueKey,
									 nil],
									
									nil], kFieldsKey,
								   
								   nil],
								  
								  nil];
	
	
    // title	
	self.title = NSLocalizedString(@"Add Payment", @"");		
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
}

// Change exp date event
- (void)takeNewDate:(NSString *)newDate
{
	labelExpDate.text = [NSString stringWithFormat:@"%@", newDate];
}

-(void)savePaymentMethod:(id)sender {
	
	// Save Payment Method
	if (selectedPaymentMethod == 0) {
		// Add Credit / Debit
		XLog(@"Save payment method %d  CCNumber:%@ CCV:%@ ExpDate:%@", selectedPaymentMethod, textFieldCCNumber.text, textFieldCCV.text, labelExpDate.text);
		
	}
	else {
		// Add ACH
		XLog(@"Save payment method %d and bank account type %d Bank %@ Routing %@", selectedPaymentMethod,  selectedAccountType, textFieldBankAccount.text, textFieldRoutingNumber.text);
	}
	
	NSError *error = nil;
	
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv AddPaymentMethod:selectedPaymentMethod :textFieldCCNumber.text 
				  :textFieldCCV.text :labelExpDate.text :selectedAccountType :textFieldBankAccount.text :textFieldRoutingNumber.text :&error];
	if (result) {
		// go back to list of payment options
		[self.navigationController popViewControllerAnimated:YES];
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Adding Payment Method" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Adding Payment Method" message: @"Please check your network, and values and try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
	}
	

}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	 if (selectedPaymentMethod == 0) {
		return [dataSourceArrayCredit count];
	 }
	 else {
		return [dataSourceArrayChecking count];
	 }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (selectedPaymentMethod == 0) {
		return [[self.dataSourceArrayCredit objectAtIndex: section] valueForKey:kSectionTitleKey];
	}
	else {
		return [[self.dataSourceArrayChecking objectAtIndex: section] valueForKey:kSectionTitleKey];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (selectedPaymentMethod == 0) {
		return [[[self.dataSourceArrayCredit objectAtIndex: section] objectForKey:kFieldsKey] count];
	}
	else {
		return [[[self.dataSourceArrayChecking objectAtIndex: section] objectForKey:kFieldsKey] count];
	}
}

// to determine specific row height for each cell, override this.
// In this example, each row is determined by its subviews that are embedded.

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

// to determine which UITableViewCell to be used on a given row.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
	
	// Set up the cell...
	NSArray *fieldList;
	if (selectedPaymentMethod == 0) {
		fieldList = [[dataSourceArrayCredit objectAtIndex:section] objectForKey:kFieldsKey];
	}
	else {
		fieldList = [[dataSourceArrayChecking objectAtIndex:section] objectForKey:kFieldsKey];		
	}
	
	NSDictionary *currentField = [fieldList objectAtIndex:row];
	NSString *controlType = [currentField valueForKey:kControlTypeKey];
	NSString *labelValue = [currentField valueForKey:kLabelKey];
	NSString *curValue = [currentField valueForKey:kValueKey];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:controlType];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:controlType] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	else
	{
		// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
		UIView *viewToCheck = nil;
		NSInteger viewTag = 0;
		if ([controlType isEqualToString:@"Label"]) {
			viewTag = kTagLabel;
		} else if ([controlType isEqualToString:@"TextField"]) {
			viewTag = kTagTextField;
		} else if ([controlType isEqualToString:@"PaymentMethod"]) {
			viewTag = kTagPaymentMehtod;
		} else if ([controlType isEqualToString:@"AccountType"]) {
			viewTag = kTagAccountType;
		} else if ([controlType isEqualToString:@"CVV"]) {
			viewTag = kTagCVV;
		} else if ([controlType isEqualToString:@"RoutingNumber"]) {
			viewTag = kTagRoutingNumber;
		} else if ([controlType isEqualToString:@"BankNumber"]) {
			viewTag = kTagBankNumber;
		} else if ([controlType isEqualToString:@"DatePicker"]) {
			viewTag = kTagDatePicker;
		} 
		
		viewToCheck = [cell.contentView viewWithTag:viewTag];
		if (!viewToCheck)
			[viewToCheck removeFromSuperview];
	}
	
	XLog(@"%@ = %@", labelValue, curValue);
	
	// create the right control type
	if ([controlType isEqualToString:@"Label"]) {
		
		// label
		UILabel *textLabel = [currentField valueForKey:kViewKey];
		textLabel.text = curValue;
		[cell.contentView addSubview:textLabel];
	} else if ([controlType isEqualToString:@"TextField"]) {

		// textfield
		UITextField *textField = [currentField valueForKey:kViewKey];
		textField.text = curValue;
		[cell.contentView addSubview:textField];
	} else if ([controlType isEqualToString:@"PaymentMethod"]) {
		
		// Payment method
		UISegmentedControl *seg = [currentField valueForKey:kViewKey];
        [cell.contentView addSubview:seg];
	} else if ([controlType isEqualToString:@"AccountType"]) {
		
		// add account type switch
		UISegmentedControl *swithAccountType = [currentField valueForKey:kViewKey];
		[cell addSubview:swithAccountType];
	} else if ([controlType isEqualToString:@"CVV"]) {
		
		// textfield
		UITextField *textField = [currentField valueForKey:kViewKey];
		textField.text = curValue;
		[cell.contentView addSubview:textField];
		
		// add info for CVV
		UIButton *ccv = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
		ccv.frame = CGRectMake(0.0, 10.0, 25.0, 25.0);
		[ccv setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		[ccv addTarget:self action:@selector(cvvClicked:) forControlEvents:UIControlEventTouchUpInside];	
		ccv.tag = kTagCVV;
		[cell addSubview:ccv];
		[ccv release];
	} else if ([controlType isEqualToString:@"RoutingNumber"]) {
		
		// textfield
		UITextField *textField = [currentField valueForKey:kViewKey];
		textField.text = curValue;
		[cell.contentView addSubview:textField];
		
		// add info for RoutingNumber
		UIButton *b = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
		b.frame = CGRectMake(0.0, 10.0, 25.0, 25.0);
		[b setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		[b addTarget:self action:@selector(checkClicked:) forControlEvents:UIControlEventTouchUpInside];	
		b.tag = kTagRoutingNumber;
		[cell addSubview:b];
		[b release];
	} else if ([controlType isEqualToString:@"BankNumber"]) {
		
		// textfield
		UITextField *textField = [currentField valueForKey:kViewKey];
		textField.text = curValue;
		[cell.contentView addSubview:textField];
		
		// add info for Bank number
		UIButton *b = [[UIButton buttonWithType:UIButtonTypeInfoDark] retain];
		b.frame = CGRectMake(0.0, 10.0, 25.0, 25.0);
		[b setTitle:@"Detail Disclosure" forState:UIControlStateNormal];
		[b addTarget:self action:@selector(checkClicked:) forControlEvents:UIControlEventTouchUpInside];	
		b.tag = kTagBankNumber;
		[cell addSubview:b];
		[b release];
	} else if ([controlType isEqualToString:@"DatePicker"]) {
		// add exp date picker
		UILabel *textLabel = [currentField valueForKey:kViewKey];
		textLabel.text = curValue;
		[cell.contentView addSubview:textLabel];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	// add the label
	if(![controlType isEqualToString:@"PaymentMethod"])  // no label for payment method
	{
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 13.0, 100.0, 20.0)];
		label.text = labelValue;
		[cell addSubview:label];
		[label release];
	}

	return cell;
}

// select row
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 1) {
		if(indexPath.row == 2)
		{
			if (selectedPaymentMethod == 0) {
				DateViewController *controller = [[DateViewController alloc] init];
				controller.delegate = self;
				controller.dateAsString = @"01/2010";
				//controller.datePicker.datePickerMode = UIDateP;
				[self.navigationController pushViewController:controller animated:YES];
				[controller release];
			}
		}
	}
}

// show CVV info			 
-(void)cvvClicked:(id)sender {
	CVVView *cvvView = [[CVVView alloc] initWithNibName:@"CVVView" bundle:nil];
	[self.navigationController pushViewController:cvvView animated:YES];
	[cvvView release];			 
}
			 
// show check info			 
-(void)checkClicked:(id)sender {
	CheckView *checkView = [[CVVView alloc] initWithNibName:@"CheckView" bundle:nil];
	[self.navigationController pushViewController:checkView animated:YES];
	[checkView release];			 
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	// the user pressed the "Done" button, so dismiss the keyboard
	[textField resignFirstResponder];
	return YES;
}

#pragma mark -
#pragma mark Text Fields

-(UILabel *)allocLabel {
	CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
	UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
	lbl.textColor = [UIColor darkTextColor];
	lbl.font = [UIFont systemFontOfSize:17.0];
	lbl.backgroundColor = [UIColor whiteColor];
	
	lbl.tag = kTagLabel;		// tag this control so we can remove it later for recycled cells
	return lbl;
}

-(UITextField *)allocTextField:(NSString*)placeHolderText {
	
	CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *field = [[UITextField alloc] initWithFrame:frame];
	
	field.borderStyle = UITextBorderStyleRoundedRect;
	field.textColor = [UIColor darkTextColor];
	field.font = [UIFont systemFontOfSize:17.0];
	field.placeholder = placeHolderText;
	field.backgroundColor = [UIColor whiteColor];
	field.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	field.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	field.returnKeyType = UIReturnKeyDone;
	
	field.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	field.tag = kTagTextField;		// tag this control so we can remove it later for recycled cells
	
	field.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	return field;
}

-(UISegmentedControl *)segPaymentMethod {
	if (segPaymentMethod == nil)
	{
		segPaymentMethod = [ [ UISegmentedControl alloc ] initWithFrame: CGRectMake(20, 5, 280, 35) ];
		[segPaymentMethod insertSegmentWithTitle: @"Credit / Debit" atIndex: 0 animated: NO ];
		[segPaymentMethod insertSegmentWithTitle: @"Checking / Saving" atIndex: 1 animated: NO ];
		segPaymentMethod.selectedSegmentIndex = selectedPaymentMethod;
		segPaymentMethod.segmentedControlStyle = UISegmentedControlStyleBar;
		segPaymentMethod.tag = kTagPaymentMehtod;
		[segPaymentMethod addTarget:self action:@selector(paymenMethodAction:) forControlEvents:UIControlEventValueChanged];
	}
	return segPaymentMethod;
}

- (void)paymenMethodAction:(UISegmentedControl*)sender
{
	selectedPaymentMethod = [sender selectedSegmentIndex];
	XLog(@"selected payment: %d", [sender selectedSegmentIndex]);
	[self.view reloadData];
}

- (UITextField *)textFieldCCNumber
{
	if (textFieldCCNumber == nil)
	{
		textFieldCCNumber = [self allocTextField: @"<Card Number>"];
	}
	return textFieldCCNumber;
}

- (UITextField *)textFieldCCV
{
	if (textFieldCCV == nil)
	{
		textFieldCCV = [self allocTextField: @"<CCV>"];
	}
	return textFieldCCV;
}

- (UILabel *)labelExpDate
{
	if (labelExpDate == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		UILabel *lbl = [[UILabel alloc] initWithFrame:frame];
		lbl.textColor = [UIColor darkTextColor];
		lbl.font = [UIFont systemFontOfSize:17.0];
		lbl.backgroundColor = [UIColor whiteColor];
		lbl.text = @"<mm/yyyy>";
		lbl.tag = kTagDatePicker;		// tag this control so we can remove it later for recycled cells
		labelExpDate =  lbl;;
	}
	return labelExpDate;
}

-(UISegmentedControl *)switchCheckingSavings {
	if (switchCheckingSavings == nil)
	{
		switchCheckingSavings = [ [ UISegmentedControl alloc ] initWithFrame: CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight)];
		[switchCheckingSavings insertSegmentWithTitle: @"Checking" atIndex: 0 animated: NO ];
		[switchCheckingSavings insertSegmentWithTitle: @"Savings" atIndex: 1 animated: NO ];
		switchCheckingSavings.selectedSegmentIndex = selectedAccountType;
		switchCheckingSavings.segmentedControlStyle = UISegmentedControlStyleBar;
		switchCheckingSavings.tag = kTagAccountType;
		[switchCheckingSavings addTarget:self action:@selector(accountTypeAction:) forControlEvents:UIControlEventValueChanged];
	}
	return switchCheckingSavings;
}

- (void)accountTypeAction:(UISegmentedControl*)sender
{
	selectedAccountType = [sender  selectedSegmentIndex];
	XLog(@"selected account type: %d", [sender selectedSegmentIndex]);	
}


- (UITextField *)textFieldRoutingNumber
{
	if (textFieldRoutingNumber == nil)
	{
		textFieldRoutingNumber = [self allocTextField: @"<Routing #>"];
	}
	return textFieldRoutingNumber;
}

- (UITextField *)textFieldBankAccount
{
	if (textFieldBankAccount == nil)
	{
		textFieldBankAccount = [self allocTextField: @"<Bank Account #>"];
	}
	return textFieldBankAccount;
}
@end
