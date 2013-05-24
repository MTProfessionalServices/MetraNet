//
//  BillViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "BillViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "BillDetailsViewController.h"

@implementation BillViewController

@synthesize pdfButton;
@synthesize logoutButton;
@synthesize list;

/*
-(id)init {
	self = [super initWithStyle: UITableViewStyleGrouped];
	
	if(self != nil) {
		self.title = @"foo";
	}
	
	return self;
}
*/

-(void)refresh {
	
	if (okToLoad) {
		// load data
		list = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetBillSummary] retain];
		if (list == nil) {
			okToLoad = false;
			UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Session Timeout" message: @"Your session has timed out.  For security reasons you need to relogin." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
			[msg show];
			[msg release];
			((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
			return;
		}
	    [self.tableView reloadData];
    }
	
	// set ok to load after first refresh
	if (!okToLoad) {
		okToLoad = true;
	}
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

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh) name:@"RefreshBill" object:nil];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	//self.parentViewController.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	//self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
	//self.tableView.backgroundColor = [UIColor clearColor];
	[self refresh];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[list release];
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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if(((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv.AccountId == 0) {
		return 0;
	}
	
	if([list count] == 0) {
		return 0;
	}
				
	switch (section) {
		case 0:
			return 2;
			break;
		case 1:
			return 2;
			break;
			
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Payment Information";
			break;
		case 1:
			return @"Balance";
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
		[[cell textLabel] setTextAlignment:UITextAlignmentRight];
    }
    
    // Set up the cell...
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	int i = 0;
	if (indexPath.section == 1) {
		i = indexPath.row + 2;  // offset for first section
	}
	else {
		i = indexPath.row;
	}
	
	NSDictionary *listItem = [list objectAtIndex:i];
	[[cell textLabel] setText:[listItem objectForKey:@"Amount"]];
	[[cell textLabel] setTextColor:[UIColor darkTextColor]];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 13.0, 155.0, 20.0)];
	label.text = [listItem objectForKey:@"Name"];
    [cell addSubview:label];
	
	[label release];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
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
	if (section == 0) {
		return 0;
	}
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
        [button setTitle:@"Make a Payment" forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		
		//the button should be as big as a table view cell
        [button setFrame:CGRectMake(10, 3, 300, 44)];
		
        //set action of the button
        [button addTarget:self action:@selector(goToPay:) forControlEvents:UIControlEventTouchUpInside];
		
        //add the button to the view
        [footerView addSubview:button];
    }
	
    //return the view for the footer
    return footerView;
}

- (void)goToPay:(id)sender {
	[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]).tabBarController setSelectedIndex:1];
}

- (void)viewPDF:(id)sender {
	
	// Navigation logic may go here. Create and push another view controller.
	BillDetailsViewController *billDetailsViewController = [[BillDetailsViewController alloc] initWithNibName:@"BillDetailsView" bundle:nil];
	billDetailsViewController.UrlAddress = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetPdfLink];
	
	if (billDetailsViewController.UrlAddress == nil) {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"No Bill Found" message: @"The current bill is not available yet." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}
	else {
		XLog(@"%@", billDetailsViewController.UrlAddress);

		[self.navigationController pushViewController:billDetailsViewController animated:YES];		
	}

	[billDetailsViewController release];
}

//logout
-(void)logout:(id)sender {

	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:nil
								 delegate:self
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:@"Logout"
								 otherButtonTitles:nil];
	
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.tabBarController.view];
    [popupQuery release];
	
	
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout" 
	//					 message:[NSString stringWithFormat:@"Are you sure you want to logout?"] delegate:self 
	//				     cancelButtonTitle:@"Cancel" otherButtonTitles: @"OK" , nil];
	//[alert show];	
	//[alert release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch(buttonIndex) {
		case 0:
			// OK, to logout
            [self logoutNow];
			break;
		case 1:
			//cancel
			break;
		default:
			break;
	}
}

/*
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex { 
	
	switch(buttonIndex) {
		case 0:
			//cancel
			break;
		case 1:
			// OK, to logout
            [self logoutNow];
			break;
		default:
			break;
	}
}
*/
-(void)logoutNow {
	bool result = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv Logout];
	if (result) { 
		((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).tabBarController.view.hidden = true;
	}
	else {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Logout Error" message: @"Please just close the app." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}	
}

- (void)dealloc {
    [footerView release];
	[logoutButton release];
	[pdfButton release];
	[list release];
	[super dealloc];
}


@end

