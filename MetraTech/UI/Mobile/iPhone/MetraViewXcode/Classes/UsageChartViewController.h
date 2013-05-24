//
//  UsageChartViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/18/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UsageChartViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	UIBarButtonItem *detailsButton;
	IBOutlet UIActivityIndicatorView *spinner;
	NSString *intervalId;
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *detailsButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSString *intervalId;

-(void)refresh;
-(void) goDetails:(id)sender;

@end