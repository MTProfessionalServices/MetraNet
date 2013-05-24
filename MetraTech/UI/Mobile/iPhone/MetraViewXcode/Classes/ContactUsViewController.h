//
//  ContactUsViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/25/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ContactUsViewController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate>  {
	
	IBOutlet UIWebView *webView;
	UIBarButtonItem *emailButton;
	IBOutlet UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIBarButtonItem *emailButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

-(void) sendEmail:(id)sender;
@end
