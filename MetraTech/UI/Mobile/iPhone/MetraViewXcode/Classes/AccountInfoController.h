//
//  AccountInfoController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/21/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountInfoController : UITableViewController <UITextFieldDelegate>{
	
	UILabel	*labelUsername;
	UILabel	*labelAccountId;
	
	UITextField	*textFieldFirstName;
	UITextField	*textFieldMiddleInitial;
	UITextField	*textFieldLastName;
	UITextField	*textFieldAddress1;
	UITextField	*textFieldAddress2;
	UITextField	*textFieldAddress3;
	UITextField	*textFieldCity;
	UITextField	*textFieldState;
	UITextField	*textFieldZip;
	UITextField	*textFieldPhoneNumber;
	UITextField	*textFieldEmail;
	
	NSDictionary *accountInfo;
	NSArray	*dataSourceArray;
	
	IBOutlet UINavigationItem *navigationItem;
	IBOutlet UIBarButtonItem *saveButton;
}

@property (nonatomic, retain, readonly) UILabel	*labelUsername;
@property (nonatomic, retain, readonly) UILabel	*labelAccountId;

@property (nonatomic, retain, readonly) UITextField	*textFieldFirstName;
@property (nonatomic, retain, readonly) UITextField	*textFieldLastName;
@property (nonatomic, retain, readonly) UITextField	*textFieldMiddleInitial;
@property (nonatomic, retain, readonly) UITextField	*textFieldAddress1;
@property (nonatomic, retain, readonly) UITextField	*textFieldAddress2;
@property (nonatomic, retain, readonly) UITextField	*textFieldAddress3;
@property (nonatomic, retain, readonly) UITextField	*textFieldCity;
@property (nonatomic, retain, readonly) UITextField	*textFieldState;
@property (nonatomic, retain, readonly) UITextField	*textFieldZip;
@property (nonatomic, retain, readonly) UITextField	*textFieldPhoneNumber;
@property (nonatomic, retain, readonly) UITextField	*textFieldEmail;

@property (nonatomic, retain) NSDictionary *accountInfo;
@property (nonatomic, retain) NSArray *dataSourceArray;

@property (nonatomic, retain) IBOutlet UINavigationItem *navigationItem;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;

-(void)freeOutletsAndSubviews;
-(UILabel *)allocLabel;
-(UITextField *)allocTextField: (NSString*)placeHolderText;
-(void)saveItem:(id)sender;
@end
