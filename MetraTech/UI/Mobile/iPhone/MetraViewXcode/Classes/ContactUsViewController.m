//
//  ContactUsViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/25/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "ContactUsViewController.h"
#import "MetraViewXcodeAppDelegate.h"

@implementation ContactUsViewController

@synthesize webView, emailButton;
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
	
	NSString *urlAddress = @"http://www.metratech.com/Contact-Us.aspx";
	NSURL *url = [NSURL URLWithString:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
	
	// email button
	emailButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendEmail:)];
    self.navigationItem.rightBarButtonItem = emailButton;
}

-(void) sendEmail:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc]
								 initWithTitle:@"Do you want to leave the application?"
								 delegate:self
								 cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
								 otherButtonTitles:@"Email", @"Call Support", nil];
	
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.tabBarController.view];
    [popupQuery release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	switch(buttonIndex) {
		case 0:
		{
			// Email
			NSURL* mailURL = [NSURL URLWithString: @"mailto:support@metratech.com?subject=Question"];
			[[UIApplication sharedApplication] openURL: mailURL];
			break;
		}
		case 1:
		{
			// Call 	
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel:17818398300"]];
			break;
		}
		case 2:
			//cancel
			break;
		default:
			break;
	}
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
	[emailButton release];
	[webView release];
	[spinner release];
    [super dealloc];
}


@end
