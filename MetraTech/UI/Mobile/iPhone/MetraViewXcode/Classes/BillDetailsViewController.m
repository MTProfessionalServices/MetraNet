//
//  BillDetailsViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/24/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "BillDetailsViewController.h"


@implementation BillDetailsViewController

@synthesize spinner;
@synthesize pdfView;
@synthesize UrlAddress;

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	[spinner release];
	spinner = nil;
	[UrlAddress release];
	UrlAddress = nil;
	[pdfView release];
	pdfView = nil;
}

- (void)dealloc {
	[spinner release];
	[UrlAddress release];
	[pdfView release];
    [super dealloc];
}

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
	
	[[self pdfView] setDelegate: self];

	
	self.title = NSLocalizedString(@"View Bill", @"");		
	
	if(UrlAddress != nil)
	{
	  // Create activity indicator
	//  spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(141.0, 244.0, 37.0, 37.0)];
	//  [self.view addSubview:spinner]; 
	//  spinner.hidesWhenStopped = YES;	
	
	  // Load Url	
	  NSURL *url = [NSURL URLWithString:UrlAddress];
	  NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	  pdfView.scalesPageToFit = YES;
		//[spinner startAnimating];
	  [pdfView loadRequest:requestObj];
		// [spinner stopAnimating];
	}
	else {
		XLog(@"No url specified before creating bill detail view.", @"");
	}

}

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

- (void)webViewDidStartLoad:(UIWebView *)wv {
    [spinner startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [spinner stopAnimating];
}

@end
