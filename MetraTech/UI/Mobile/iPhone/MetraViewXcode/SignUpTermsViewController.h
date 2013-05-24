//
//  SignUpTermsViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpTermsViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView *webView;
	IBOutlet UIActivityIndicatorView *spinner;
	NSString *poid;
	
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) NSString *poid;

-(void)refresh;

@end