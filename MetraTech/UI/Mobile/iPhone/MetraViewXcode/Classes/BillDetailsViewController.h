//
//  BillDetailsViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/24/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BillDetailsViewController : UIViewController <UIWebViewDelegate> {

		IBOutlet UIActivityIndicatorView *spinner;
		IBOutlet UIWebView *pdfView;
	
	@public
		NSString *UrlAddress;
	
}

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIWebView *pdfView;
@property (nonatomic, retain) NSString *UrlAddress;

@end
