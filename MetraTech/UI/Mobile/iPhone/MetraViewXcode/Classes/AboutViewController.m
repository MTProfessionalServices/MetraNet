//
//  AboutViewController.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "AboutViewController.h"


@implementation AboutViewController

@synthesize about;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"About", @"");		
	
     NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
     NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	
	 NSString *aboutInfo =  [NSString stringWithFormat:@"%@ - Version:  %@ \r\n"
							      "------------------------------------------ \r\n"
							      "Attributions:\r\n"
							      "Glyphish Icons by Joseph Wain \r\n    http://glyphish.com \r\n"
							      "ASIHttpRequest Library \r\n    http://allseeing-i.com/ASIHTTPRequest \r\n"
							      "json-framework \r\n    http://code.google.com/p/json-framework \r\n"
							      "©2010 MetraTech Corp. All rights reserved.\r\n    http://metratech.com", appName, version];
	[about setTextColor:[UIColor whiteColor]];
	[about setFont:[UIFont systemFontOfSize:13]];
	 about.text = aboutInfo;
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[about release];
    [super dealloc];
}


@end
