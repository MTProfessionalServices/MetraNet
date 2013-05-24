//
//  AvailableSubscriptionsViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/12/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "AvailableSubscriptionsViewController.h"
#import "MetraViewXcodeAppDelegate.h"

@implementation AvailableSubscriptionsViewController

@synthesize dataSourceArray;
@synthesize poid;

/*
 - (id)initWithStyle:(UITableViewStyle)style {
 // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 if (self = [super initWithStyle:style]) {
 }
 return self;
 }
 */


-(void)refresh {
	
	// load data
	dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetAvailableSubscriptions] retain];
	
	//list = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetBillSummary] retain];
	if (dataSourceArray == nil) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Session Timeout" message: @"Your session has timed out.  For security reasons you need to relogin." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
		((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
		return;
	}
	[self.tableView reloadData];
	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	self.title = NSLocalizedString(@"Select Subscription", @"");		
	
	// turn on editing
	self.editing = NO;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
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
			return @"";
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
    // Set up the cell...
	NSDictionary *item = [dataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"name"]];
	
	cell.detailTextLabel.numberOfLines = 3;
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [item objectForKey:@"description"]];
	
	//UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(220.0, 15.0, 100.0, 20.0)];
	//label.text = [item objectForKey:@"date"];
    //[cell addSubview:label];
	//[label release];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
	NSDictionary *item = [dataSourceArray objectAtIndex:indexPath.row];
	poid = [item objectForKey:@"poid"];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Subscription" 
													message:[NSString stringWithFormat:@"You are about to subscribe to %@.",
															 [item objectForKey:@"name"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK" , nil];
	[alert show];	
	[alert release];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	
	switch(buttonIndex) {
		case 0:
			//cancel
			break;
		case 1:
			// OK, subscribe
			[self subscribe];
			break;
		default:
			break;
	}
    [self refresh];
}

// Go ahead and subscribe
-(void) subscribe {
	NSError *error = nil;
 
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv Subscribe: poid : &error];
	if (result) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Subscription Successful" 
													  message: [NSString stringWithFormat:@"Thank you.",
																@""] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}
	else {
		if (error) {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Subscribing" message: [error localizedDescription] delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];	
		}
		else {
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Error Subscribing" message: @"Sorry for the inconvenience.  Please check back later." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

- (void)dealloc {
	[dataSourceArray release];
	[poid release];
    [super dealloc];
}


@end

