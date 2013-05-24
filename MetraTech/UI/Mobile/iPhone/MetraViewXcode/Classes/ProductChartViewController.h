//
//  ProductChartViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProductChartViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *spinner;
	NSString *intervalId;
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSString *intervalId;

-(void)refresh;

@end