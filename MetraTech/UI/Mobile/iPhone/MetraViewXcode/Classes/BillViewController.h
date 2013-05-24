//
//  BillViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BillViewController : UITableViewController <UIAlertViewDelegate, UIActionSheetDelegate> {
	UIView *footerView;
	bool okToLoad;
	IBOutlet UIBarButtonItem *pdfButton;
	IBOutlet UIBarButtonItem *logoutButton;
	NSArray *list;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *pdfButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, retain) NSArray *list;

-(void)refresh;
-(void)goToPay:(id)sender;
-(void)viewPDF:(id)sender;
-(void)logout:(id)sender;
-(void)logoutNow;

@end
