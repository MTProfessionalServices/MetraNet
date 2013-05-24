//
//  PaymentSelectViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/23/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "PaymentSelectViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "PaymentAddViewController.h"

@implementation PaymentSelectViewController

@synthesize dataSourceArray;
@synthesize addButton;

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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	self.title = NSLocalizedString(@"Payment Methods", @"");		
	
	dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAvailablePaymentOptions] retain];
	
	// turn on editing
	self.editing = NO;
	
	// add button
	addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPaymentMethod:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)addPaymentMethod:(id)sender {
	
	// Navigation logic may go here. Create and push another view controller.
	PaymentAddViewController *paymentAddViewController = [[PaymentAddViewController alloc] initWithNibName:@"PaymentAddView" bundle:nil];
	[self.navigationController pushViewController:paymentAddViewController animated:YES];
	[paymentAddViewController release];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAvailablePaymentOptions] retain];
    [self.tableView reloadData];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

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
    return [dataSourceArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Select payment method";
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
		//cell.textAlignment = UITextAlignmentRight;
    }
    
    // Set up the cell...
	//cell.selectionStyle = U;
	
	NSDictionary *listItem = [dataSourceArray objectAtIndex:indexPath.row];
	[[cell textLabel] setText:[NSString stringWithFormat:@"%@ ending in xxx%@", [listItem objectForKey:@"type"],[listItem objectForKey:@"endingDigits"]]];
	
	if ([[listItem objectForKey:@"priority"] isEqualToString:@"1"]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.editingAccessoryType = UITableViewCellAccessoryNone;
	}

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	 
	NSError *error = nil;
	NSDictionary *listItem = [dataSourceArray objectAtIndex:indexPath.row];
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv MakePaymentActive: [listItem objectForKey:@"piid"] :&error];
	if (result) {
		dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAvailablePaymentOptions] retain];
		[self.tableView reloadData];
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Setting Active Payment Method" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Setting Active Payment Method" message: @"Please check your network and try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
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



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		
		NSError *error = nil;
		
		NSDictionary *listItem = [dataSourceArray objectAtIndex:indexPath.row];
		bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv DeletePaymentMethod:[listItem objectForKey:@"piid"] :&error];
		if (result) {
			dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAvailablePaymentOptions] retain];
			[self.tableView reloadData];
		}
		else {
			if (error) {
				UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Deleting Payment Method" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
				[msg show];
				[msg release];	
			}
			else {
				UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Deleting Payment Method" message: @"Please check your network and try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
				[msg show];
				[msg release];	
			}
		}
		
		
		//UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"delete" message: [NSString stringWithFormat:@"%d", indexPath.row] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		//[msg show];
		//[msg release];
		
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



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


- (void)dealloc {
	[dataSourceArray release];
	[addButton release];
    [super dealloc];
}


@end

