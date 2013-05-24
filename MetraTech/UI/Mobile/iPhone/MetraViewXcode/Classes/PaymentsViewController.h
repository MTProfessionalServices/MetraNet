//
//  PaymentsViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PaymentsViewController : UITableViewController <UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIAlertViewDelegate> {

	UILabel *labelAmountDue;
	UITextField	*textFieldAmountDue;
	
	UIView *footerView;
	NSDictionary *dictionary;
	
	UIBarButtonItem *historyButton;
}

@property (nonatomic, retain, readonly) UILabel	*labelAmountDue;
@property (nonatomic, retain, readonly) UITextField	*textFieldAmountDue;

@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, retain) NSDictionary *dictionary;

@property (nonatomic, retain) UIBarButtonItem *historyButton;

-(void)refresh;
-(void)makePayment;
-(void)showHistory:(id)sender;

@end
