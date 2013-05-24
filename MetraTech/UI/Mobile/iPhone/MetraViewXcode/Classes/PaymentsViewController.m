//
//  PaymentsViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "PaymentsViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "PaymentSelectViewController.h"
#import "PaymentHistoryViewController.h"
#import "PaymentAddViewController.h"

#define NUMBERS	@"0123456789"
#define NUMBERSPERIOD	@"0123456789."

#define kTextFieldWidth	        130.0
#define kLeftMargin				150.0
#define kTextFieldHeight		30.0

const NSInteger kPaymentsViewTag = 2;

@implementation PaymentsViewController

@synthesize labelAmountDue, textFieldAmountDue;

@synthesize footerView;
@synthesize dictionary;
@synthesize historyButton;

 -(id)init {
	 self = [super initWithStyle: UITableViewStyleGrouped];
 
	 if(self != nil) {
		 [self refresh];	 
	 }
 
	 return self;
 }
 

-(void)refresh {
	
	// load data
	dictionary = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetPaymentInfo] retain];
	
	/* TODO
	if (dictionary == nil) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Session Timeout" message: @"Your session has timed out.  For security reasons you need to relogin." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
		[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]).tabBarController setSelectedIndex:0];
		((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
		return;
	}
	 */
	
	[self.tableView reloadData];
}

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[textFieldAmountDue release];
	textFieldAmountDue = nil;
	[labelAmountDue release];
	labelAmountDue = nil;
		
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = NSLocalizedString(@"Payments", @"");
	
	// history button
	historyButton = [[[UIBarButtonItem alloc] initWithTitle:@"History" style:UIBarButtonItemStylePlain target:self action:@selector(showHistory:)] autorelease];
    self.navigationItem.rightBarButtonItem = historyButton;
}

-(void)showHistory:(id)sender {
	// show history
	PaymentHistoryViewController *history = [[PaymentHistoryViewController alloc] initWithNibName:@"PaymentHistoryView" bundle:nil];
	[self.navigationController pushViewController:history animated:YES];
	[history release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self refresh];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[dictionary release];
}

/*
 - (void)viewDidDisappear:(BOOL)animated {
 [super viewDidDisappear:animated];
 }
 */

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return AUTO_ROTATE;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv.AccountId == 0) {
		return 0;
	}
	
	switch (section) {
		case 0:
			return 3;
			break;
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Make a Payment";
			break;
		default:
			return @"";
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	else
	{
		// a cell is being recycled, remove the old edit field (if it contains one of our tagged edit fields)
		UIView *viewToCheck = nil;
		viewToCheck = [cell.contentView viewWithTag:kPaymentsViewTag];
		if (!viewToCheck)
			[viewToCheck removeFromSuperview];
	}

    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				[[cell textLabel] setText:[dictionary objectForKey:@"amountDueAsString"]];
				UILabel *textLabel = self.labelAmountDue;
				textLabel.text = [dictionary objectForKey:@"amountDueAsString"];
				textLabel.textAlignment = UITextAlignmentRight;
				[cell.contentView addSubview:textLabel];
				
				UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 140.0, 20.0)];
				label.text = @"Amount Due";
				[cell addSubview:label];
				[label release]; 
				break; 
			case 1:
				[[cell textLabel] setText:[dictionary objectForKey:@"amountDue"]];
				UITextField *textField = self.textFieldAmountDue;
				textField.text = [dictionary objectForKey:@"amountDue"];
				textField.textAlignment = UITextAlignmentRight;
				
				[cell.contentView addSubview:textField];
				
				UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 140.0, 20.0)];
				label2.text = @"Amount to Pay";
				[cell addSubview:label2];
				[label2 release];
				break;
			case 2:
				if ([[dictionary objectForKey:@"paymentType"] isEqualToString: @"none"]) {
					[[cell textLabel] setText:@"Add a Payment Method"];
				}
				else  {
					[[cell textLabel] setText:[NSString stringWithFormat:@"%@ ending in xxx%@", [dictionary objectForKey:@"paymentType"],
											                                                    [dictionary objectForKey:@"endingDigits"]]];
				}
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			default:
				break;
		}		
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		if(indexPath.row == 2)
		{
			if ([[dictionary objectForKey:@"paymentType"] isEqualToString: @"none"]) {
				// Create and push the add payment view controller.
				PaymentAddViewController *paymentAddViewController = [[PaymentAddViewController alloc] initWithNibName:@"PaymentAddView" bundle:nil];
				[self.navigationController pushViewController:paymentAddViewController animated:YES];
				[paymentAddViewController release];
			}
			else  {
				// Create and push the select payment view controller.
				PaymentSelectViewController *paymentSelectViewController = [[PaymentSelectViewController alloc] initWithNibName:@"PaymentSelectView" bundle:nil];
				[self.navigationController pushViewController:paymentSelectViewController animated:YES];
				[paymentSelectViewController release];}
		}
	}
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

// specify the height of your footer section
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    //differ between your sections or if you
    //have only on section return a static value

    return 50;
}

// custom view for footer. will be adjusted to default or specified footer height
// Notice: this will work only for one section within the table view
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
    if(footerView == nil) {
        //allocate the view if it doesn't exist yet
        footerView  = [[UIView alloc] init];
		
        //we would like to show a gloosy red button, so get the image first
        UIImage *image = [[UIImage imageNamed:@"button_green.png"]
						  stretchableImageWithLeftCapWidth:8 topCapHeight:8];
		
        //create the button
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setBackgroundImage:image forState:UIControlStateNormal];
		
        //set title, font size and font color
        [button setTitle:@"Pay Now" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//the button should be as big as a table view cell
        [button setFrame:CGRectMake(10, 3, 300, 44)];
		
        //set action of the button
        [button addTarget:self action:@selector(payNow:) forControlEvents:UIControlEventTouchUpInside];
		
        //add the button to the view
        [footerView addSubview:button];
    }
	
    //return the view for the footer
    return footerView;
}

- (void)payNow:(id)sender {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Payment" 
						  message:[NSString stringWithFormat:@"You are about to make a payment of %@, using %@ ending in %@.",
								   textFieldAmountDue.text, [dictionary objectForKey:@"paymentType"], [dictionary objectForKey:@"endingDigits"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK" , nil];
	[alert show];	
	[alert release];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	
	switch(buttonIndex) {
		case 0:
			//cancel
			break;
		case 1:
			// OK, make payment
			[self makePayment];
			break;
		default:
			break;
	}
    [self refresh];
}

// Make the actual payment
-(void) makePayment {
	NSError *error = nil;
	NSString *confirmationNumber; 
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv MakePayment: [dictionary objectForKey:@"piid"] 
																										   : textFieldAmountDue.text
																										   : &confirmationNumber
																										   : &error];
	if (result) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Payment Made" 
													  message: [NSString stringWithFormat:@"Thank you.  Your payment is being processed.  Your payment confimation number is %@.",
																confirmationNumber] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Making Payment" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Making Payment" message: @"Sorry for the inconvenience.  Please check back later." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
	}
	
	[confirmationNumber release];
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
- (UILabel *)labelAmountDue
{
	if (labelAmountDue == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		labelAmountDue = [[UILabel alloc] initWithFrame:frame];
		
		labelAmountDue.textColor = [UIColor darkTextColor];
		labelAmountDue.font = [UIFont systemFontOfSize:17.0];
		labelAmountDue.backgroundColor = [UIColor whiteColor];
		
		labelAmountDue.tag = kPaymentsViewTag;		// tag this control so we can remove it later for recycled cells
	}
	return labelAmountDue;
}

- (UITextField *)textFieldAmountDue
{
	if (textFieldAmountDue == nil)
	{
		CGRect frame = CGRectMake(kLeftMargin, 8.0, kTextFieldWidth, kTextFieldHeight);
		textFieldAmountDue = [[UITextField alloc] initWithFrame:frame];
		
		textFieldAmountDue.borderStyle = UITextBorderStyleRoundedRect;
		textFieldAmountDue.textColor = [UIColor darkTextColor];
		textFieldAmountDue.font = [UIFont systemFontOfSize:17.0];
		textFieldAmountDue.placeholder = @"enter amount";
		textFieldAmountDue.backgroundColor = [UIColor whiteColor];
		textFieldAmountDue.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
		textFieldAmountDue.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
		textFieldAmountDue.returnKeyType = UIReturnKeyDone;
		
		textFieldAmountDue.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
		
		textFieldAmountDue.tag = kPaymentsViewTag;		// tag this control so we can remove it later for recycled cells
		
		textFieldAmountDue.delegate = self;	// let us be the delegate so we know when the keyboard's "Done" button is pressed
	}
	return textFieldAmountDue;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    NSString *filtered;
    
	if (string.length > 0) // user pressed a key other than delete
	{
      // Check for period, if not found allow numbers and period
      if ([textFieldAmountDue.text rangeOfString:@"."].location == NSNotFound)
      {
        cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERSPERIOD] invertedSet];
        filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
      }
    
      // Period is in use, only allow numbers
      cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERS] invertedSet];
      filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
		
	  // Get the pieces separated by a decimal point, only allow 2 places after it
	  NSArray *parts = [textFieldAmountDue.text componentsSeparatedByString:@"."];
	  NSString *rightSide = [parts objectAtIndex:1];
	  if ([rightSide length] > 1) {
		  return NO;
	  }
		
      return [string isEqualToString:filtered];
	}
	return YES;
}

- (void)dealloc {
	[labelAmountDue release];
	[textFieldAmountDue release];
    [footerView release];
	[dictionary release];
	[historyButton release];
	[super dealloc];
}


@end

