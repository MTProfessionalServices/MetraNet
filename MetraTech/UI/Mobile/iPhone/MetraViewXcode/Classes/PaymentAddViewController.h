//
//  PaymentAddViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/23/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateViewController.h"

@interface PaymentAddViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, DateViewDelegate>{
	
	UISegmentedControl *segPaymentMethod;
	UITextField	*textFieldCCNumber;
	UITextField	*textFieldCCV;
	UILabel	*labelExpDate;
	
	UISegmentedControl *switchCheckingSavings;
	int selectedAccountType;
	UITextField *textFieldRoutingNumber;
	UITextField *textFieldBankAccount;

	NSArray	*dataSourceArrayCredit;
	NSArray	*dataSourceArrayChecking;
	int selectedPaymentMethod;
	
	UIBarButtonItem *saveButton;
}

@property (nonatomic, retain, readonly) UISegmentedControl *segPaymentMethod;
@property (nonatomic, retain, readonly) UITextField	*textFieldCCNumber;
@property (nonatomic, retain, readonly) UITextField	*textFieldCCV;
@property (nonatomic, retain, readonly) UILabel	*labelExpDate;

@property (nonatomic, retain, readonly) UISegmentedControl *switchCheckingSavings;
@property (nonatomic, retain, readonly) UITextField	*textFieldRoutingNumber;
@property (nonatomic, retain, readonly) UITextField	*textFieldBankAccount;

@property (nonatomic, retain) NSArray *dataSourceArrayCredit;
@property (nonatomic, retain) NSArray *dataSourceArrayChecking;

@property (nonatomic, retain) UIBarButtonItem *saveButton;

-(void)freeOutletsAndSubviews;
-(UILabel *)allocLabel;
-(UITextField *)allocTextField: (NSString*)placeHolderText;
-(void)paymenMethodAction:(UISegmentedControl*)sender;
-(void)savePaymentMethod:(id)sender;
-(void)cvvClicked:(id)sender;
-(void)checkClicked:(id)sender;
-(void)takeNewDate:(NSString *)newDate;

@end
