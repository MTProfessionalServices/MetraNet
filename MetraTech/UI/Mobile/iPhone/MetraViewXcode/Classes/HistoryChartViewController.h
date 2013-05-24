//
//  HistoryChartViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryChartViewController : UIViewController <UIWebViewDelegate> {

		IBOutlet UIWebView *webView;
		UIBarButtonItem *detailsButton;
		IBOutlet UIActivityIndicatorView *spinner;
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *detailsButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

-(void) goDetails:(id)sender;

@end
