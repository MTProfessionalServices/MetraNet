//
//  SignUpAccountInfoController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/7/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpAccountInfoController : UITableViewController <UITextFieldDelegate> {
		
		NSString *poid; 	
		UILabel	*labelPlan;
		UILabel	*labelTerm;
		
		UITextField	*textFieldCardNumber;
		UITextField	*textFieldSecurityCode;
		UITextField	*textFieldExpirationDate;
        UITextField	*textFieldFullName;	
	    UITextField	*textFieldCompanyName;	
	    UITextField	*textFieldAddress1;
		UITextField	*textFieldAddress2;
		UITextField	*textFieldCity;
		UITextField	*textFieldState;
		UITextField	*textFieldZip;
		UITextField	*textFieldPhoneNumber;
   	    UITextField	*textFieldCountry;
		UITextField	*textFieldEmail;
        UITextField	*textFieldUsername;
	    UITextField	*textFieldPassword;
		
		NSArray	*dataSourceArray;
		
		UIBarButtonItem *submitButton;
}

	@property (nonatomic, retain, readonly) NSString *poid;	
	@property (nonatomic, retain, readonly) UILabel	*labelPlan;
	@property (nonatomic, retain, readonly) UILabel	*labelTerm;
	
    @property (nonatomic, retain, readonly) UITextField	*textFieldCardNumber;
    @property (nonatomic, retain, readonly) UITextField	*textFieldSecurityCode;
    @property (nonatomic, retain, readonly) UITextField	*textFieldExpirationDate;
	@property (nonatomic, retain, readonly) UITextField	*textFieldFullName;	
	@property (nonatomic, retain, readonly) UITextField	*textFieldCompanyName;	
	@property (nonatomic, retain, readonly) UITextField	*textFieldAddress1;
	@property (nonatomic, retain, readonly) UITextField	*textFieldAddress2;
	@property (nonatomic, retain, readonly) UITextField	*textFieldCity;
	@property (nonatomic, retain, readonly) UITextField	*textFieldState;
	@property (nonatomic, retain, readonly) UITextField	*textFieldZip;
	@property (nonatomic, retain, readonly) UITextField	*textFieldPhoneNumber;
	@property (nonatomic, retain, readonly) UITextField	*textFieldCountry;
	@property (nonatomic, retain, readonly) UITextField	*textFieldEmail;
	@property (nonatomic, retain, readonly) UITextField	*textFieldUsername;
	@property (nonatomic, retain, readonly) UITextField	*textFieldPassword;

	@property (nonatomic, retain) NSArray *dataSourceArray;
	
    @property (nonatomic, retain) UIBarButtonItem *submitButton;
	
	-(void)freeOutletsAndSubviews;
	-(UILabel *)allocLabel;
	-(UITextField *)allocTextField: (NSString*)placeHolderText;
	-(UITextField *)allocPassword: (NSString*)placeHolderText;
	-(void)setPoid:(NSString *)newPoid;
    -(void)submit:(id)sender;

@end
