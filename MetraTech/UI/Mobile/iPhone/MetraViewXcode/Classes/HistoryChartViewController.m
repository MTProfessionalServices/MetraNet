//
//  HistoryChartViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "HistoryChartViewController.h"
#import "MetraViewXcodeAppDelegate.h"
#import "HistoryViewController.h"

@implementation HistoryChartViewController

@synthesize webView, detailsButton;
@synthesize spinner;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
 // Custom initialization
 }
 return self;
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[[self webView] setDelegate: self];
	
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage 
										  sharedHTTPCookieStorage]; 
	[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]; 
	
	NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		XLog(@"THE COOKIES:%@", [cookie description]);
	}
	
	NSString *urlAddress = [[((MetraViewXcodeAppDelegate *)[UIApplication sharedApplication].delegate).mv GetUsageHistoryChartLink] retain];
	NSURL *url = [NSURL URLWithString:urlAddress];
	[urlAddress release];
    XLog(@"%@", url);
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];

	// detailsButton
	detailsButton = [[[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(goDetails:)] autorelease];
	self.navigationItem.rightBarButtonItem = detailsButton;
}

-(void) goDetails:(id)sender {
	// show details
	HistoryViewController *details = [[HistoryViewController alloc] initWithNibName:@"HistoryView" bundle:nil];
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
	[detailsButton release];
	[webView release];
	[spinner release];
    [super dealloc];
}

@end
