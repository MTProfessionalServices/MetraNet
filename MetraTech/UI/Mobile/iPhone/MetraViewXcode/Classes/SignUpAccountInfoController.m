//
//  SignUpAccountInfoController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/7/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "SignUpAccountInfoController.h"
#import "MetraViewXcodeAppDelegate.h"

#define kTextFieldWidth	        150.0
#define kLeftMargin				150.0
#define kTextFieldHeight		30.0

static NSString *kSectionTitleKey = @"sectionTitleKey";
static NSString *kControlTypeKey = @"controlTypeKey";
static NSString *kLabelKey = @"labelKey";
static NSString *kViewKey = @"viewKey";
static NSString *kFieldsKey = @"fieldsKey";
static NSString *kValueKey = @"valueKey";

const NSInteger kAccountViewTag = 1;

@implementation SignUpAccountInfoController

@synthesize labelPlan, labelTerm;

@synthesize textFieldCardNumber;
@synthesize textFieldSecurityCode;
@synthesize textFieldExpirationDate;
@synthesize textFieldFullName;	
@synthesize textFieldCompanyName;	
@synthesize textFieldAddress1;
@synthesize textFieldAddress2;
@synthesize textFieldCity;
@synthesize textFieldState;
@synthesize textFieldZip;
@synthesize textFieldPhoneNumber;
@synthesize textFieldCountry;
@synthesize textFieldEmail;
@synthesize textFieldUsername;
@synthesize textFieldPassword;

@synthesize submitButton;
//@synthesize navigationItem;

@synthesize dataSourceArray;
@synthesize poid;

- (void)setPoid:(NSString *)newPoid
{
    if (newPoid != poid)
    {
        [poid release];
        poid = nil;
        
        poid = [newPoid retain]; 
	}
}

- (void)freeOutletsAndSubviews
{
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	[labelPlan release]; labelPlan = nil;
	[labelTerm release]; labelTerm = nil;
	
	
	[textFieldCardNumber release]; textFieldCardNumber = nil;
	[textFieldSecurityCode release]; textFieldSecurityCode = nil;
	[textFieldExpirationDate release]; textFieldExpirationDate = nil;
	[textFieldFullName release];	 textFieldFullName = nil;
	[textFieldCompanyName release];	 textFieldCompanyName = nil;
	[textFieldAddress1 release]; textFieldAddress1 = nil;
	[textFieldAddress2 release]; textFieldAddress2 = nil;
	[textFieldCity release]; textFieldCity = nil;
	[textFieldState release]; textFieldState = nil;
	[textFieldZip release]; textFieldZip = nil;
	[textFieldPhoneNumber release]; textFieldPhoneNumber = nil;
	[textFieldCountry release]; textFieldCountry = nil;
	[textFieldEmail release]; textFieldEmail = nil;
	[textFieldUsername release]; textFieldUsername = nil;
	[textFieldPassword release]; textFieldPassword = nil;
	
//	[saveButton release];
//	[navigationItem release];
}

- (void)dealloc
{
	[self freeOutletsAndSubviews];
	[dataSourceArray release];
	[poid release];
	[submitButton release];
	[super dealloc];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

// called after the view controller's view is released and set to nil.
// For example, a memory warning which causes the view to be purged. Not invoked as a result of -dealloc.
// So release any properties that are loaded in viewDidLoad or can be recreated lazily.
- (void)viewDidUnload
{
	[super viewDidUnload];
	
	[self freeOutletsAndSubviews];
	self.dataSourceArray = nil;
	//self.accountInfo = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return AUTO_ROTATE;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.dataSourceArray = [NSArray arrayWithObjects:
							
							// Section 0   
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Plan Information", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  // Username 
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"Label", kControlTypeKey,
							   @"Plan", kLabelKey,
							   self.labelPlan, kViewKey,
							   self.labelPlan.text, kValueKey,
							   nil],
							  
							  // Account Id
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"Label", kControlTypeKey,
							   @"Term", kLabelKey,
							   self.labelTerm, kViewKey,
							   self.labelTerm.text, kValueKey,
							   nil],
							  
							  nil], kFieldsKey,
							 
							 nil],
							
							// Section 1
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Billing Information", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Card Number", kLabelKey,
							   self.textFieldCardNumber, kViewKey,
							   @"4242424242424242", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Security Code", kLabelKey,
							   self.textFieldSecurityCode, kViewKey,
							   @"201", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Exp. Date", kLabelKey,
							   self.textFieldExpirationDate, kViewKey,
							   @"12/2010", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Full Name", kLabelKey,
							   self.textFieldFullName, kViewKey,
							   @"Test Account", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Company Name", kLabelKey,
							   self.textFieldCompanyName, kViewKey,
							   @"MetraTech Corp.", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Address 1", kLabelKey,
							   self.textFieldAddress1, kViewKey,
							   @"200 West St.", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Address 2", kLabelKey,
							   self.textFieldAddress2, kViewKey,
							   @"", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*City", kLabelKey,
							   self.textFieldCity, kViewKey,
							   @"Waltham", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*State", kLabelKey,
							   self.textFieldState, kViewKey,
							   @"MA", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Zip", kLabelKey,
							   self.textFieldZip, kViewKey,
							   @"02451", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Country", kLabelKey,
							   self.textFieldCountry, kViewKey,
							   @"USA", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Phone Number", kLabelKey,
							   self.textFieldPhoneNumber, kViewKey,
							   @"1 781 839 8421", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Email", kLabelKey,
							   self.textFieldEmail, kViewKey,
							   @"test@MetraTech Corp.", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Username", kLabelKey,
							   self.textFieldUsername, kViewKey,
							   @"TestAccount1", kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"*Password", kLabelKey,
							   self.textFieldPassword, kViewKey,
							   @"Metra#1234", kValueKey,
							   nil],
							  
							  nil], kFieldsKey,
							 
							 nil],
							
							nil];
	
	
	self.title = NSLocalizedString(@"Sign Up", @"");		
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
	
	
	// submit button
	submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStylePlain target:self action:@selector(submit:)];
    self.navigationItem.rightBarButtonItem = submitButton;
	
	/*		
	 //TODO:  select country from list
	 countryArray = [NSLocale ISOCountryCodes];
	 
	 sortedCountryArray = [[NSMutableArray alloc] init];
	 NSLocale *locale = [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease];
	 
	 for (NSString *countryCode in countryArray) {
	 
	 NSString *displayNameString = [locale displayNameForKey:NSLocaleCountryCode value:countryCode];
	 [sortedCountryArray addObject:displayNameString];
	 
	 }
	 
	 [sortedCountryArray sortUsingSelector:@selector(compare:)];
	 */
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [[self.dataSourceArray objectAtIndex: section] valueForKey:kSectionTitleKey];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[[self.dataSourceArray objectAtIndex: section] objectForKey:kFieldsKey] count];
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
	
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	else
	{
		// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
		UIView *viewToCheck = nil;
		viewToCheck = [cell.contentView viewWithTag:kAccountViewTag];
		if (!viewToCheck)
			[viewToCheck removeFromSuperview];
	}
	
    // Set up the cell...
	NSArray *fieldList = [[dataSourceArray objectAtIndex:section] objectForKey:kFieldsKey];
	NSDictionary *currentField = [fieldList objectAtIndex:row];
	NSString *controlType = [currentField valueForKey:kControlTypeKey];
	NSString *labelValue = [currentField valueForKey:kLabelKey];
	NSString *curValue = [currentField valueForKey:kValueKey];
	
	XLog(@"%@ = %@", labelValue, curValue);
	
	// create the right control type
	if ([controlType isEqualToString:@"Label"]) {
		UILabel *textLabel = [currentField valueForKey:kViewKey];
		textLabel.text = curValue;
		[cell.contentView addSubview:textLabel];
	} else if ([controlType isEqualToString:@"TextField"]) {
		UITextField *textField = [currentField valueForKey:kViewKey];
		textField.text = curValue;
		[cell.contentView addSubview:textField];
	}

	// add the label 
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 14.0, 130.0, 20.0)];
	label.text = labelValue;
	label.textColor = [UIColor blackColor];
	label.font = [UIFont boldSystemFontOfSize:17.0];
	label.backgroundColor = [UIColor whiteColor];
    [cell addSubview:label];
	
	[label release];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	switch (section)
	{
		case 1:
			return @"* required fields";
			break;
		default:
			return @"";
			break;
	}
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
	lbl.textColor = [UIColor darkGrayColor];
	lbl.font = [UIFont systemFontOfSize:17.0];
	lbl.backgroundColor = [UIColor whiteColor];
	
	lbl.tag = kAccountViewTag;		// tag this control so we can remove it later for recycled cells
	return lbl;
}

- (UILabel *)labelPlan
{
	if (labelPlan == nil)
	{
		labelPlan = [self allocLabel];
	}
	return labelPlan;
}

- (UILabel *)labelTerm
{
	if (labelTerm == nil)
	{
		labelTerm = [self allocLabel];
	}
	return labelTerm;
}

-(UITextField *)allocTextField:(NSString*)placeHolderText {
	
	CGRect frame = CGRectMake(kLeftMargin, 13.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *field = [[UITextField alloc] initWithFrame:frame];
	
	field.borderStyle = UITextBorderStyleNone; // UITextBorderStyleRoundedRect;
	field.textColor = [UIColor darkTextColor];
	field.font = [UIFont systemFontOfSize:17.0];
	field.placeholder = placeHolderText;
	field.backgroundColor = [UIColor whiteColor];
	field.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	field.keyboardType = UIKeyboardTypeDefault;
	field.returnKeyType = UIReturnKeyDone;
	
	field.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	
	field.tag = kAccountViewTag;		// tag this control so we can remove it later for recycled cells
	
	field.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	return field;
}

-(UITextField *)allocPassword:(NSString*)placeHolderText {
	
	CGRect frame = CGRectMake(kLeftMargin, 13.0, kTextFieldWidth, kTextFieldHeight);
	UITextField *field = [[UITextField alloc] initWithFrame:frame];
	
	field.borderStyle = UITextBorderStyleNone; // UITextBorderStyleRoundedRect;
	field.textColor = [UIColor darkTextColor];
	field.font = [UIFont systemFontOfSize:17.0];
	field.placeholder = placeHolderText;
	field.backgroundColor = [UIColor whiteColor];
	field.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
	
	field.keyboardType = UIKeyboardTypeDefault;
	field.returnKeyType = UIReturnKeyDone;
	
	field.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	field.secureTextEntry = YES;
	
	field.tag = kAccountViewTag;		// tag this control so we can remove it later for recycled cells
	
	field.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	return field;
}

/*
 -(BOOL) textFieldShouldBeginEditing: (UITextField *) textField
 {
 if ( textField == textFieldCountry ) {
 return NO;
 }
 else {
 return YES;
 }
 
 }	
 */

- (UITextField *)textFieldCardNumber
{
	if (textFieldCardNumber == nil)
	{
		textFieldCardNumber = [self allocTextField: @"<Card Number>"];
	}
	return textFieldCardNumber;
}

- (UITextField *)textFieldSecurityCode
{
	if (textFieldSecurityCode == nil)
	{
		textFieldSecurityCode = [self allocTextField: @"<Security Code>"];
	}
	return textFieldSecurityCode;
}

- (UITextField *)textFieldExpirationDate
{
	if (textFieldExpirationDate == nil)
	{
		textFieldExpirationDate = [self allocTextField: @"<mm/yyyy>"];
	}
	return textFieldExpirationDate;
}

- (UITextField *)textFieldFullName
{
	if (textFieldFullName == nil)
	{
		textFieldFullName = [self allocTextField: @"<Full Name>"];
	}
	return textFieldFullName;
}

- (UITextField *)textFieldCompanyName
{
	if (textFieldCompanyName == nil)
	{
		textFieldCompanyName = [self allocTextField: @"<Company>"];
	}
	return textFieldCompanyName;
}

- (UITextField *)textFieldAddress1
{
	if (textFieldAddress1 == nil)
	{
		textFieldAddress1 = [self allocTextField: @"<Address 1>"];
	}
	return textFieldAddress1;
}

- (UITextField *)textFieldAddress2
{
	if (textFieldAddress2 == nil)
	{
		textFieldAddress2 = [self allocTextField: @"<Address 2>"];
	}
	return textFieldAddress2;
}

- (UITextField *)textFieldCity
{
	if (textFieldCity == nil)
	{
		textFieldCity = [self allocTextField: @"<City"];
	}
	return textFieldCity;
}

- (UITextField *)textFieldState
{
	if (textFieldState == nil)
	{
		textFieldState = [self allocTextField: @"<State>"];
	}
	return textFieldState;
}

- (UITextField *)textFieldZip
{
	if (textFieldZip == nil)
	{
		textFieldZip = [self allocTextField: @"<Zip>"];
	}
	return textFieldZip;
}

- (UITextField *)textFieldPhoneNumber
{
	if (textFieldPhoneNumber == nil)
	{
		textFieldPhoneNumber = [self allocTextField: @"<Phone Number>"];
	}
	return textFieldPhoneNumber;
}

- (UITextField *)textFieldCountry
{
	if (textFieldCountry == nil)
	{
		textFieldCountry = [self allocTextField: @"<Country>"];
	}
	return textFieldCountry;
}

- (UITextField *)textFieldEmail
{
	if (textFieldEmail == nil)
	{
		textFieldEmail = [self allocTextField: @"<Email>"];
	}
	return textFieldEmail;
}

- (UITextField *)textFieldUsername
{
	if (textFieldUsername == nil)
	{
		textFieldUsername = [self allocTextField: @"<Username>"];
	}
	return textFieldUsername;
}

- (UITextField *)textFieldPassword
{
	if (textFieldPassword == nil)
	{
		textFieldPassword = [self allocPassword: @"<Password>"];
	}
	return textFieldPassword;
}

-(void)submit:(id)sender {
	// submit
	NSError *error = nil;
	
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv SignUp:poid :textFieldCardNumber.text 
				  :textFieldSecurityCode.text :textFieldExpirationDate.text :textFieldFullName.text :textFieldAddress1.text 
				  :textFieldAddress2.text :textFieldCity.text :textFieldState.text :textFieldZip.text :textFieldCountry.text 
				  :textFieldPhoneNumber.text :textFieldEmail.text :textFieldUsername.text :textFieldPassword.text :&error];		
	if (result) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Sign Up Successful" message: @"Your account was successfully created." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
		
		// Do login
		// start spinning
		bool result2 = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv Login:textFieldUsername.text :textFieldPassword.text];
		
		if (result2) {
			[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]) moreInfo];
			((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = false;
			[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBill" object:nil];
		}
		else {
			[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]) moreInfo];
		}	
		
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Sign Up Error" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Sign Up Error" message: @"Please check your network, and values and try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		
	}
}


@end
