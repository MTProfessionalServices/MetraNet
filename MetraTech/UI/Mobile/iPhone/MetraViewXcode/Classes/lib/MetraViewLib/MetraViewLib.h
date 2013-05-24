//
//  MetraViewLib.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DEBUG_SERVER
	#define DEBUG_SERVER 0 // Set to 1 to disable network activity for testing
#endif

#ifndef DEBUG_CERT
	#define VALIDATE_CERT NO // Set to NO to accept test SSL certs
#endif

@interface MetraViewLib : NSObject {
	// Instance variable declarations
	NSString *Username;
	int AccountId;
	NSString *Server;
	NSString *VirtualDirectory;
}
// Properties
@property (retain) NSString* Username; 
@property int AccountId;
@property (retain) NSString* Server;
@property (retain) NSString* VirtualDirectory;

// Method declarations
-(id)initWithServer: (NSString *)server : (NSString *)virtualDirectory;
-(BOOL)Login:(NSString *) username: (NSString *) password;
-(BOOL)Logout;
-(NSArray*)GetBillSummary;
-(NSString*)GetPdfLink;
-(NSDictionary*)GetPaymentInfo;
-(NSArray*)GetAvailablePaymentOptions;
-(NSDictionary*)GetAccountInfo;
-(bool)UpdateAccount: (NSString *) firstName   : (NSString *) middleInitial
                    : (NSString *) lastName    : (NSString *) address1 
					: (NSString *) address2    : (NSString *) address3
					: (NSString *) city        : (NSString *) state 
					: (NSString *) zip   	   : (NSString *) phoneNumber
					: (NSString *) email       : (NSError**)error;

-(bool)AddPaymentMethod: (int) paymentMethod        : (NSString *) creditCardNumber
				       : (NSString *) CVV           : (NSString *) expDate 
					   : (int) accountType	        : (NSString *) accountNumber
					   : (NSString *) routingNumber : (NSError**)error;

-(bool)DeletePaymentMethod: (NSString *) PIID : (NSError**)error; 
-(bool)MakePaymentActive: (NSString *) PIID : (NSError**)error;
-(bool)MakePayment: (NSString *) PIID : (NSString *) amountToPay : (NSString **) outConfirmationNumber : (NSError**)error;
-(NSArray*)GetPaymentHistory;
-(NSArray*)GetPlanSelection;
-(NSDictionary*)GetPlanDetails: (NSString *) offering;
-(NSString*)GetSignUpTermsLink: (NSString *) poid;
-(bool)SignUp: (NSString *) poid : (NSString *) cardNumber: (NSString *) securityCode
			 : (NSString *) expirationDate: (NSString *) fullName: (NSString *) address1 
			 : (NSString *) address2: (NSString *) city
			 : (NSString *) state: (NSString *) zip
			 : (NSString *) country: (NSString *) phoneNumber
             : (NSString *) email 
             : (NSString *) username: (NSString *) password
			 : (NSError**)error;
-(NSArray*)GetUsageHistory;
-(NSArray*)GetSubscriptions;
-(NSArray*)GetAvailableSubscriptions;
-(bool)Subscribe: (NSString *) poid : (NSError**)error;
-(NSString*)GetUsageHistoryChartLink;
-(NSString*)GetUsageChartLink: (NSString *) intervalId;
-(NSString*)GetProductChartLink: (NSString *) intervalId;
@end
