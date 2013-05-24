//
//  AccountInfoController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/21/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "AccountInfoController.h"
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

const NSInteger kViewTag = 1;

@implementation AccountInfoController

@synthesize labelUsername, labelAccountId, textFieldFirstName, textFieldLastName, 
			textFieldMiddleInitial, textFieldAddress1, textFieldAddress2, textFieldAddress3,
            textFieldCity, textFieldState, textFieldZip, textFieldPhoneNumber, textFieldEmail;

@synthesize saveButton;
@synthesize navigationItem;

@synthesize accountInfo;
@synthesize dataSourceArray;

- (void)freeOutletsAndSubviews
{
	// release the controls and set them nil in case they were ever created
	// note: we can't use "self.xxx = nil" since they are read only properties
	[labelUsername release]; labelUsername = nil;
	[labelAccountId release]; labelAccountId = nil;
	[textFieldFirstName release]; textFieldFirstName = nil;
	[textFieldMiddleInitial release]; textFieldMiddleInitial = nil;
	[textFieldLastName release]; textFieldLastName = nil;
	[textFieldAddress1 release]; textFieldAddress1 = nil;
	[textFieldAddress2 release]; textFieldAddress2 = nil;
	[textFieldAddress3 release]; textFieldAddress3 = nil;
	[textFieldCity release]; textFieldCity = nil;
	[textFieldState release]; textFieldState = nil;
	[textFieldZip release]; textFieldZip = nil;
	[textFieldPhoneNumber release]; textFieldPhoneNumber = nil;
	[textFieldEmail release]; textFieldEmail = nil;
	
	[saveButton release];
	[navigationItem release];
}

- (void)dealloc
{
	[self freeOutletsAndSubviews];
	[accountInfo release];
	[dataSourceArray release];
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
	
	//[self freeOutletsAndSubviews];
	self.dataSourceArray = nil;
	self.accountInfo = nil;
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return AUTO_ROTATE;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	accountInfo = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAccountInfo] retain];
	if (accountInfo == nil) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Session Timeout" message: @"Your session has timed out.  For security reasons you need to relogin." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
		[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]).tabBarController setSelectedIndex:0];
		((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
		return;
	}
	
	self.dataSourceArray = [NSArray arrayWithObjects:
							
							// Section 0   
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Account Properties", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  // Username 
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"Label", kControlTypeKey,
							   @"Username", kLabelKey,
							   self.labelUsername, kViewKey,
							   [accountInfo valueForKey:@"username"], kValueKey,
							   nil],
							  
							  // Account Id
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"Label", kControlTypeKey,
							   @"Account ID", kLabelKey,
							   self.labelAccountId, kViewKey,
							   [accountInfo valueForKey:@"accountId"], kValueKey,
							   nil],
							  
							  nil], kFieldsKey,
							 
							 nil],
							
							// Section 1
							[NSDictionary dictionaryWithObjectsAndKeys:
							 @"Contact Information", kSectionTitleKey,
							 
							 // Array of Fields
							 [NSArray arrayWithObjects:
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"First Name", kLabelKey,
							   self.textFieldFirstName, kViewKey,
							   [accountInfo valueForKey:@"firstName"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Middle Initial", kLabelKey,
							   self.textFieldMiddleInitial, kViewKey,
							   [accountInfo valueForKey:@"middleInitial"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Last Name", kLabelKey,
							   self.textFieldLastName, kViewKey,
							   [accountInfo valueForKey:@"lastName"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Address 1", kLabelKey,
							   self.textFieldAddress1, kViewKey,
							   [accountInfo valueForKey:@"address1"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Address 2", kLabelKey,
							   self.textFieldAddress2, kViewKey,
							   [accountInfo valueForKey:@"address2"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Address 3", kLabelKey,
							   self.textFieldAddress3, kViewKey,
							   [accountInfo valueForKey:@"address3"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"City", kLabelKey,
							   self.textFieldCity, kViewKey,
							   [accountInfo valueForKey:@"city"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"State", kLabelKey,
							   self.textFieldState, kViewKey,
							   [accountInfo valueForKey:@"state"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Zip", kLabelKey,
							   self.textFieldZip, kViewKey,
							   [accountInfo valueForKey:@"zip"], kValueKey,
							   nil],

							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Phone Number", kLabelKey,
							   self.textFieldPhoneNumber, kViewKey,
							   [accountInfo valueForKey:@"phoneNumber"], kValueKey,
							   nil],
							  
							  [NSDictionary dictionaryWithObjectsAndKeys:
							   @"TextField", kControlTypeKey,
							   @"Email", kLabelKey,
							   self.textFieldEmail, kViewKey,
							   [accountInfo valueForKey:@"email"], kValueKey,
							   nil],
							  
							  nil], kFieldsKey,
							 
							 nil],
							
							nil];
	
	
	self.title = NSLocalizedString(@"Account Info", @"");		
	
	// we aren't editing any fields yet, it will be in edit when the user touches an edit field
	self.editing = NO;
	
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
	return [self.dataSourceArray count];
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
		viewToCheck = [cell.contentView viewWithTag:kViewTag];
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
	
	lbl.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
	return lbl;
}
	
- (UILabel *)labelUsername
{
	if (labelUsername == nil)
	{
		labelUsername = [self allocLabel];
	}
	return labelUsername;
}

- (UILabel *)labelAccountId
{
	if (labelAccountId == nil)
	{
		labelAccountId = [self allocLabel];
	}
	return labelAccountId;
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
	
	field.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
	
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

- (UITextField *)textFieldFirstName
{
	if (textFieldFirstName == nil)
	{
		textFieldFirstName = [self allocTextField: @"<First Name>"];
	}
	return textFieldFirstName;
}

- (UITextField *)textFieldMiddleInitial
{
	if (textFieldMiddleInitial == nil)
	{
		textFieldMiddleInitial = [self allocTextField: @"<Middle Initial>"];
	}
	return textFieldMiddleInitial;
}

- (UITextField *)textFieldLastName
{
	if (textFieldLastName == nil)
	{
		textFieldLastName = [self allocTextField: @"<Last Name>"];
	}
	return textFieldLastName;
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

- (UITextField *)textFieldAddress3
{
	if (textFieldAddress3 == nil)
	{
		textFieldAddress3 = [self allocTextField: @"<Address 3>"];
	}
	return textFieldAddress3;
}

- (UITextField *)textFieldCity
{
	if (textFieldCity == nil)
	{
		textFieldCity = [self allocTextField: @"<City>"];
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

- (UITextField *)textFieldEmail
{
	if (textFieldEmail == nil)
	{
		textFieldEmail = [self allocTextField: @"<Email>"];
	}
	return textFieldEmail;
}

- (void)saveItem:(id)sender {
	
	NSError *error = nil;

	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv UpdateAccount:textFieldFirstName.text 
				  :textFieldMiddleInitial.text :textFieldLastName.text :textFieldAddress1.text :textFieldAddress2.text 
				  :textFieldAddress3.text :textFieldCity.text :textFieldState.text :textFieldZip.text 
				  :textFieldPhoneNumber.text :textFieldEmail.text :&error] ;
	if (result) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Account Updated" message: @"Your account information was successfully updated." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Updating Account" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Updating Account" message: @"Please check your network, and values and try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}

	}
}

	
@end
