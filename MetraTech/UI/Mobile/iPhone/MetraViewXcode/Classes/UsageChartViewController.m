//
//  UsageChartViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/18/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "UsageChartViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "ProductChartViewController.h"

@implementation UsageChartViewController

@synthesize webView;
@synthesize detailsButton;
@synthesize spinner;
@synthesize intervalId;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

-(void)refresh {
	
	NSString *urlAddress = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetUsageChartLink:intervalId] retain];
	NSURL *url = [NSURL URLWithString:urlAddress];
	[urlAddress release];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self webView] setDelegate: self];
	
	// detailsButton
	detailsButton = [[[UIBarButtonItem alloc] initWithTitle:@"Products" style:UIBarButtonItemStylePlain target:self action:@selector(goDetails:)] autorelease];
	self.navigationItem.rightBarButtonItem = detailsButton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
}

-(void) goDetails:(id)sender {
	// show details
	ProductChartViewController *details = [[ProductChartViewController alloc] initWithNibName:@"ProductChartView" bundle:nil];
	details.intervalId = intervalId;
	[self.navigationController pushViewController:details animated:YES];
	[details release];
}

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

- (void)webViewDidStartLoad:(UIWebView *)wv {
    [spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [spinner stopAnimating];
}


- (void)dealloc {
	//[detailsButton release];
	[webView release];
	[spinner release];
	[intervalId release];
    [super dealloc];
}


@end
