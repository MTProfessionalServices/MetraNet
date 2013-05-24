//
//  HistoryViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/12/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "HistoryViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "UsageChartViewController.h"

@implementation HistoryViewController

@synthesize dataSourceArray;

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
	dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetUsageHistory] retain];
	if (dataSourceArray == nil) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Session Timeout" message: @"Your session has timed out.  For security reasons you need to relogin." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
		[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]).tabBarController setSelectedIndex:0];
		((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
		return;
	}
	[self.tableView reloadData];

}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	
	self.title = NSLocalizedString(@"Usage", @"");		

	
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
    // Set up the cell...
	NSDictionary *listItem = [dataSourceArray objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[listItem objectForKey:@"totalAsString"]];
	[[cell textLabel] setTextColor:[UIColor darkTextColor]];
	[[cell textLabel] setTextAlignment:UITextAlignmentRight];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 180.0, 20.0)];
	label.text = [listItem objectForKey:@"group"];
    [cell addSubview:label];
	
	[label release];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	UsageChartViewController *usageChartViewController = [[UsageChartViewController alloc] initWithNibName:@"UsageChartView" bundle:nil];
	NSDictionary *item = [dataSourceArray objectAtIndex:indexPath.row];
	usageChartViewController.intervalId = [item objectForKey:@"intervalId"];
	[self.navigationController pushViewController:usageChartViewController animated:YES];
	[usageChartViewController release];
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
	return 50.0;
}

- (void)dealloc {
	[dataSourceArray release];
    [super dealloc];
}


@end

