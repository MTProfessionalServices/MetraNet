//
//  SignUpViewDetailsController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/6/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "SignUpViewDetailsController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "SignUpAccountInfoController.h"
#import "SignUpTermsViewController.h"

@implementation SignUpViewDetailsController

@synthesize item;
@synthesize planDetails;
@synthesize planFeatures;
@synthesize planPoIds;
@synthesize planPrices;
@synthesize priceDescriptions;

- (void)setItem:(NSDictionary *)newItem
{
    if (newItem != item)
    {
        [item release];
        item = nil;
        
        item = [newItem retain]; 
		
		planDetails = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetPlanDetails:[item objectForKey:@"offering"]] retain];
		planFeatures = [[planDetails objectForKey:@"features"] retain];
		planPoIds = [[planDetails objectForKey:@"poIds"] retain];
		planPrices = [[planDetails objectForKey:@"prices"] retain];
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

    self.navigationItem.leftBarButtonItem.title = @"back";
	
	self.title = @"Sign Up";
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
    return 3;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
		{
			NSString *pricingString = [NSString stringWithFormat:@"%@", [item objectForKey:@"pricing"]];
			priceDescriptions = [[pricingString componentsSeparatedByString: @"**"] retain];
			return [priceDescriptions count];
			break;
		}
		case 1:
			return [planFeatures count];
			break;
		case 2:
			return 1;
			break;	
		default:
			return 0;
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	switch (section) {
		case 0:
			return @"Selected Plan";
			break;
		case 1:
			return @"Plan Features";
			break;		
		case 2:
			return @"Legal";
			break;			
		default:
			return @"";
			break;
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%d", indexPath.section];  // the cells in each section look like other cells in that section
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.accessoryType = UITableViewCellAccessoryNone;
    	
	if (indexPath.section == 0) {
		switch (indexPath.row) {
			case 0:
				cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", [item objectForKey:@"offering"], [item objectForKey:@"description"]];
				cell.detailTextLabel.numberOfLines = 2;

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
				break;
			default:
				// price case
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.textLabel.text = [NSString stringWithFormat:@"%@", [priceDescriptions objectAtIndex:indexPath.row -1]];
				break;
		}
	}
	
	if (indexPath.section == 1) {
		// Features
		NSDictionary *feature = [planFeatures objectAtIndex:indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"%@", [feature objectForKey:@"feature"]];
		cell.detailTextLabel.numberOfLines = 5;
		cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [feature objectForKey:@"description"]];
	}
	
	if (indexPath.section == 2) {
		// Terms & Conditions
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = [NSString stringWithFormat:@"%@", @"Terms of Service"];
	}
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	
	// SignUp clicked
	if (indexPath.section == 0) {
		if (indexPath.row > 0) {
			NSDictionary *poids = [planPoIds objectAtIndex:indexPath.row -1];
			NSString *poid = [poids objectForKey:@"poId"];
			
			NSDictionary *prices = [planPrices objectAtIndex:indexPath.row -1];
			NSString *price = [prices objectForKey:@"price"];
			
			// Navigation logic may go here. Create and push another view controller.
			SignUpAccountInfoController *signUpAccountInfoController = [[SignUpAccountInfoController alloc] initWithNibName:@"SignUpAccountInfo" bundle:nil];
			[signUpAccountInfoController setPoid:poid];
			signUpAccountInfoController.labelPlan.text = [item objectForKey:@"offering"];
			signUpAccountInfoController.labelTerm.text = price;
			[self.navigationController pushViewController:signUpAccountInfoController animated:YES];
			[signUpAccountInfoController release];  
		}
	}
	
	// Terms & Conditions
	if (indexPath.section == 2) {
		if(indexPath.row == 0)
		{
			SignUpTermsViewController *details = [[SignUpTermsViewController alloc] initWithNibName:@"SignUpTermsView" bundle:nil];
			NSDictionary *poids = [planPoIds objectAtIndex:0];
			NSString *poid = [poids objectForKey:@"poId"];
			details.poid = poid;
			[self.navigationController pushViewController:details animated:YES];
			[details release];
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
    switch (indexPath.section) {
		case 0:
			if (indexPath.row == 0) {
				return 70;
			}
			return 50;
			break;
		case 1:
		{
			NSDictionary *feature = [planFeatures objectAtIndex:indexPath.row];
			NSString *str = [NSString stringWithFormat:@"%@", [feature objectForKey:@"description"]];	
			if ([str length] < 41) {
				return 50;
			}
			if ([str length] < 82) {
				return 70;
			}
			if ([str length] < 123) {
				return 90;
			}
			if ([str length] < 164) {
				return 110;
			}
			if ([str length] < 205) {
				return 130;
			}
			return 150;
			break;
		}
		default:
			return 50;
			break;
	}
}


- (void)dealloc {
	[item release];
	[planDetails release];
	[planFeatures release];
	[planPoIds release];
	[priceDescriptions release];
    [super dealloc];
}


@end

