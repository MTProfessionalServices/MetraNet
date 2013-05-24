//
//  MetraViewXcodeAppDelegate.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/14/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "MetraViewXcodeAppDelegate.h"

@implementation MetraViewXcodeAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize	serverName;
@synthesize	virtualDirectory;
@synthesize mv;
@synthesize webView;
@synthesize buttonInfo, buttonBack, buttonForward, buttonBackToLogin;
@synthesize textUsername;
@synthesize textPassword;
@synthesize buttonLogin;
@synthesize spinner;
@synthesize spinnerWeb;
@synthesize signUp;
@synthesize	signUpNav;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    
	// Add the tab bar controller's current view as a subview of the window
	[window addSubview:tabBarController.view];
	tabBarController.view.hidden = true;	
	[tabBarController.moreNavigationController setDelegate:self];
	
	textPassword.delegate = self;
	textUsername.delegate = self;

	// Get ServerName from settings
	serverName = [[NSUserDefaults standardUserDefaults] stringForKey:@"ServerName"];
	if ([serverName caseInsensitiveCompare:@""] == NSOrderedSame) {
		// The server to used if not specified in settings
		serverName = @"http://ultimatedev/metraview";
	}
	
	// Defaults for testing
#ifdef DEBUG_MODE
	textUsername.text = @"demo";
	textPassword.text = @"demo1234";
#endif
	
	// Parse the Virtual Directory name from the end of the server string
	NSRange range = [serverName rangeOfString:@"/" options:NSBackwardsSearch];
	if (range.location != NSNotFound) {
		virtualDirectory = [serverName substringFromIndex:range.location + 1];
	}
	
	XLog(@"Server: %@", serverName);
	XLog(@"Virtual Dir:%@", virtualDirectory);
	
	// Create MetraViewLib
    mv = [[MetraViewLib alloc] initWithServer: serverName :virtualDirectory]; 
	
    webView.hidden = YES; 
	buttonBack.hidden = YES;
	buttonForward.hidden = YES;
	buttonBackToLogin.hidden = YES;
	[[self webView] setDelegate: self];

	// Create activity indicator
	spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(141.0, 244.0, 37.0, 37.0)];
	[window addSubview:spinner]; 
	spinner.hidesWhenStopped = YES;
	
	// signup view 
 	[window addSubview:signUpNav.view];
	[window addSubview:signUp.view];
	
	signUpNav.view.hidden = YES;
	signUp.view.hidden = YES;
	
	// Make sure we accept cookies
	/*
	NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage 
										  sharedHTTPCookieStorage]; 
	[cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways]; 
	
	NSHTTPCookie *cookie;
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	
	for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
		XLog(@"%@", [cookie description]);
	}
    */
}

// We don't need Edit button in More screen. 
- (void)navigationController:(UINavigationController *)navigationController
	  willShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated {
	
    UINavigationBar *morenavbar = navigationController.navigationBar;
    UINavigationItem *morenavitem = morenavbar.topItem;

    morenavitem.rightBarButtonItem = nil;
}

// Show web page with more info
- (void)moreInfo {
	
	signUpNav.view.hidden = !signUpNav.view.hidden;
	signUp.view.hidden = !signUp.view.hidden;
	[signUp refresh];
	
	/*
	if (webView.hidden) {
		
		//SignUpViewController *signUp = [[SignUpViewController alloc] initWithNibName:@"SignUpView" bundle:nil];
		//[window.subviews[0].navigationController pushViewController:signUp animated:YES];
		//signUp release];
		
		// Web signup
		
		buttonBack.hidden = NO;
		buttonForward.hidden = NO;
		buttonBackToLogin.hidden = NO;
		buttonInfo.hidden = YES;
		
		// replace metraview with enrollment page
		NSString *str = serverName;
		int stringLength = [str length];
		NSRange range = NSMakeRange(0, stringLength);
		NSString *newStr = [str stringByReplacingOccurrencesOfString:@"metraview" withString:@"enrollment/planselection.aspx" options:NSCaseInsensitiveSearch range:range];

		NSString *urlAddress = newStr;
		NSURL *url = [NSURL URLWithString:urlAddress];
		NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
		[webView loadRequest:requestObj];
		 
	}
	else {
		buttonBack.hidden = YES;
        buttonForward.hidden = YES;
		buttonBackToLogin.hidden = YES;
		buttonInfo.hidden = NO;
	}

	
	webView.hidden = !webView.hidden;
	 */
}

- (void)goBackToLogin {
	buttonBack.hidden = YES;
	buttonForward.hidden = YES;
	buttonBackToLogin.hidden = YES;
	webView.hidden = YES;
	buttonInfo.hidden = NO;
}

- (void)goBack {
	[webView goBack];
}

- (void)goForward {
	[webView goForward];
}

// Keyboard trickery
- (BOOL)textFieldShouldReturn: (UITextField *)textField{

    if(textField == textUsername)
	{
		[textField resignFirstResponder];
		[textPassword becomeFirstResponder];	
	}
	
	if(textField == textPassword)
	{
		[textField resignFirstResponder];
		[self doLogin];
	}
    return YES;
} 

// Login
-(IBAction) doLogin {
	[textUsername resignFirstResponder];
	[textPassword resignFirstResponder];
	
	// start spinning
	[NSThread detachNewThreadSelector: @selector(spinStart) toTarget:self withObject:nil];
	
	bool result = [mv Login:textUsername.text :textPassword.text];
		
    // stop spinning...
	[NSThread detachNewThreadSelector: @selector(spinEnd) toTarget:self withObject:nil]; 
	
	if (result) { 
		tabBarController.view.hidden = false;
		[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshBill" object:nil];
	}
	else {
		UIAlertView *msg = [[UIAlertView alloc] initWithTitle: @"Login Error" message: @"Invalid username or password.  Please try again." delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[msg show];
		[msg release];
	}	
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)spinStart {
	[spinner startAnimating];
}

- (void)spinEnd {
	[spinner stopAnimating];
}

- (void)webViewDidStartLoad:(UIWebView *)wv {
    [spinnerWeb startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [spinnerWeb stopAnimating];
}

- (void)dealloc {
    [tabBarController release];
    [window release];
	[serverName release];
	[mv release];
	[webView release];
	[spinner release];
	[buttonInfo release];
	[buttonLogin release];
	[buttonBackToLogin release];
	[buttonBack release];
	[buttonForward release];
	[spinnerWeb release];
	[signUp release];
	[signUpNav release];
    [super dealloc];
}

@end

