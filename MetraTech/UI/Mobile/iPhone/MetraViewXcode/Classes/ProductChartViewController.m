//
//  ProductChartViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "ProductChartViewController.h"
#import "MetraViewXcodeAppDelegate.h"


@implementation ProductChartViewController

@synthesize webView;
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
	
	NSString *urlAddress = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetProductChartLink:intervalId] retain];
	NSURL *url = [NSURL URLWithString:urlAddress];
	[urlAddress release];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self webView] setDelegate: self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refresh];
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
