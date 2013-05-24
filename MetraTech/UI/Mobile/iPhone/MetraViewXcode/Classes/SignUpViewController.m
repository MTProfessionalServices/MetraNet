//
//  SignUpViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/6/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "SignUpViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "SignUpViewDetailsController.h"

@implementation SignUpViewController

@synthesize dataSourceArray, buttonBack;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
				self.title = NSLocalizedString(@"Sign Up", @"");
    }
    return self;
}
*/

-(void)refresh {
  	dataSourceArray = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetPlanSelection] retain];
	[self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
	
	self.title = NSLocalizedString(@"Sign Up", @"");
		
	
	buttonBack = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)] autorelease];
    self.navigationItem.leftBarButtonItem = buttonBack;
	
	// turn on editing
	self.editing = NO;
}

-(void)goBack:(id)sender {
	[((MetraViewXcodeAppDelegate*)[[UIApplication sharedApplication] delegate]) moreInfo];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
			return @"Choose a Plan";
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
	    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	else
	{
		// a cell is being recycled, remove the old img
		[cell.imageView setImage:nil];
	}	
	
    // Set up the cell...
	NSDictionary *item = [dataSourceArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [item objectForKey:@"offering"], [item objectForKey:@"description"]];
	
	
	int pricingLength = [[item objectForKey:@"pricing"] length];
	NSRange rangePrice = NSMakeRange(0, pricingLength);
	NSString *price = [[item objectForKey:@"pricing"] stringByReplacingOccurrencesOfString:@"**" withString:@"\n" options:NSCaseInsensitiveSearch range:rangePrice];
	
	cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", price];
	
		
//	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 5.0, 100.0, 20.0)];
//	label.text = @"amount";//[item objectForKey:@"amount"];
//  [cell addSubview:label];
//	[label release];

//  UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(200.0, 25.0, 100.0, 20.0)];
//	label2.text = @"amount2";//[item objectForKey:@"amount"];
//  [cell addSubview:label2];
//	[label2 release];

	int stringLength = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv.Server length];
	NSRange range = NSMakeRange(0, stringLength);
	NSString *imgUrl = [((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv.Server stringByReplacingOccurrencesOfString:((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv.VirtualDirectory withString:[item objectForKey:@"imageUrl"] options:NSCaseInsensitiveSearch range:range];
	UIImage *img = [[UIImage imageWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: imgUrl]]] retain];
	XLog(@"%@", imgUrl);
	//[imgUrl release];
	
	if (img != nil) { // Image was loaded successfully.
    	[cell.imageView setImage:img];
		[img release]; // Release the image now that we have a UIImageView that contains it.
	}
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	SignUpViewDetailsController *signUpViewDetailsController = [[SignUpViewDetailsController alloc] initWithNibName:@"SignUpViewDetails" bundle:nil];
	NSDictionary *item = [dataSourceArray objectAtIndex:indexPath.row];
	[signUpViewDetailsController setItem:item];
	[self.navigationController pushViewController:signUpViewDetailsController animated:YES];
	[signUpViewDetailsController release];
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
	[buttonBack release];
    [super dealloc];
}


@end

