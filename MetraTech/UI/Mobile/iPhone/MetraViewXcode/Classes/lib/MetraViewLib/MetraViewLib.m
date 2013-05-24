//
//  MetraViewLib.m
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/16/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import "MetraViewLib.h"
#import "../ASIHttpRequest/ASIFormDataRequest.h"
#import "../JSON/JSON.h"

@implementation MetraViewLib 

@synthesize Username; 
@synthesize AccountId; 
@synthesize Server; 
@synthesize VirtualDirectory;

// Method definitions

// Init with server name
-(id)initWithServer: (NSString *)server: (NSString *)virtualDirectory
{
	if (self = [super init])
    {
		[self setServer:server];
		[self setVirtualDirectory:virtualDirectory];
    }
    return self;
}

// Login
// Returns true on success and creates a valid session on the MetraView web server
-(BOOL)Login:(NSString *) username: (NSString *) password {
	bool result = false;
	if (DEBUG_SERVER) {
		sleep(1);
		Username = @"demo";
		AccountId = 123;
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/Login.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/Login.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];
    [request setPostValue:username forKey:@"username"];
    [request setPostValue:password forKey:@"password"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Login request...");
    [request startSynchronous];
	XLog(@"Login request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"id\" is \"%@\"", [dictionary objectForKey:@"id"]);
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			Username = username;
			AccountId = (int)[dictionary objectForKey:@"id"];
			result = true;
		}
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
		result = false;
    }

	return result;
}

// Logout
// Returns true on success and removes the session on the MetraView web server
-(BOOL)Logout {
	bool result = false;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/Logout.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/Logout.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Logout request...");
    [request startSynchronous];
	XLog(@"Logout request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
		result = false;
    }
	
	return result;
}

// Bill Summary
// Returns an NSArray containing NSDictionary entries of Name and Amount fields
-(NSArray*)GetBillSummary {
	if (DEBUG_SERVER) {
		return [@"[{\"Name\" : \"a\", \"Amount\" : \"1\"},{\"Name\" : \"a\", \"Amount\" : \"1\"},{\"Name\" : \"a\", \"Amount\" : \"1\"},{\"Name\" : \"a\", \"Amount\" : \"1\"}]" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/BillSummary.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"%@", @"BillSummary request...");
    [request startSynchronous];
	XLog(@"%@", @"BillSummary request done...");
	XLog(@"%@", [request responseString]);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		 NSArray *billItems = [[request responseString] JSONValue];
		return billItems;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetPdfLink
// Returns a valid url to download the bill in PDF form
-(NSString*)GetPdfLink {
	NSString *result = nil;
	if (DEBUG_SERVER) {
		return @"http://www.amazon.com";
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PdfLink.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"PDF Link request...");
    [request startSynchronous];
	XLog(@"PDF Link request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"pdfLink\" is \"%@\"", [dictionary objectForKey:@"pdfLink"]);
	
		result = [NSString stringWithFormat:@"%@%@", Server, (NSString*)[dictionary objectForKey:@"pdfLink"]];
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return result;
}

// GetPaymentInfo
// Returns an NSDictionary containing amountDue, amountDueAsString, activePaymentType, activeEndingDigits, activePIID
-(NSDictionary*)GetPaymentInfo {
	if (DEBUG_SERVER) {
		return [@"{\"amountDue\" : \"a\", \"amountDueAsString\" : \"1\"}" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PaymentInfo.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Payment Info request...");
    [request startSynchronous];
	XLog(@"Payment Info request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"amountDue\" is \"%@\"", [dictionary objectForKey:@"amountDue"]);
		XLog(@"Dictionary value for \"amountDueAsString\" is \"%@\"", [dictionary objectForKey:@"amountDueAsString"]);
		return dictionary;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// Payment Options on file
// Returns an NSArray containing NSDictionary entries of paymentType and endingDigits
-(NSArray*)GetAvailablePaymentOptions {
	if (DEBUG_SERVER) {
		return [@"[{\"paymentType\" : \"a\", \"endingDigits\" : \"1\"},{\"paymentType\" : \"a\", \"endingDigits\" : \"1\"}" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PaymentOptions.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"AvailablePaymentOptions request...");
    [request startSynchronous];
	XLog(@"AvailablePaymentOptions request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *availablePaymentOptions = [[request responseString] JSONValue];
		return availablePaymentOptions;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetAccountInfo
// Returns an NSDictionary containing account properties (username, accountId, firstName, lastName)
-(NSDictionary*)GetAccountInfo {
	if (DEBUG_SERVER) {
		return [@"{\"username\" : \"a\", \"accountId\" : \"1\"}" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/AccountInfo.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Account Info request...");
    [request startSynchronous];
	XLog(@"Account Info request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"firstName\" is \"%@\"", [dictionary objectForKey:@"firstName"]);
		return dictionary;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// Update Account
// Returns YES or NO and sets error on failure
-(bool)UpdateAccount: (NSString *) firstName : (NSString *) middleInitial
                    : (NSString *) lastName  : (NSString *) address1 
					: (NSString *) address2	 : (NSString *) address3
					: (NSString *) city	     : (NSString *) state 
					: (NSString *) zip       : (NSString *) phoneNumber
					: (NSString *) email     : (NSError**)error {
	if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/UpdateAccount.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/UpdateAccount.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:firstName forKey:@"firstName"];
    [request setPostValue:middleInitial forKey:@"middleInitial"];
	[request setPostValue:lastName forKey:@"lastName"];
    [request setPostValue:address1 forKey:@"address1"];
	[request setPostValue:address2 forKey:@"address2"];
    [request setPostValue:address3 forKey:@"address3"];
	[request setPostValue:city forKey:@"city"];
    [request setPostValue:state forKey:@"state"];
	[request setPostValue:zip forKey:@"zip"];
	[request setPostValue:phoneNumber forKey:@"phoneNumber"];
    [request setPostValue:email forKey:@"email"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Update Account request...");
    [request startSynchronous];
	XLog(@"Update Account done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			 errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:100 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:150 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// Add Payment Method
// Returns YES or NO and sets error on failure
// paymentMethod: 0 = credit/debit  1 = checking/savings
// accountType: 0 = checking   1 = savings
-(bool)AddPaymentMethod: (int) paymentMethod        : (NSString *) creditCardNumber
                       : (NSString *) CVV           : (NSString *) expDate 
					   : (int) accountType	        : (NSString *) accountNumber
				       : (NSString *) routingNumber : (NSError**)error {
    if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/AddPaymentMethod.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/AddPaymentMethod.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:[NSString stringWithFormat:@"%d", paymentMethod] forKey:@"paymentMethod"];
    [request setPostValue:creditCardNumber forKey:@"creditCardNumber"];
	[request setPostValue:CVV forKey:@"CVV"];
    [request setPostValue:expDate forKey:@"expDate"];
	[request setPostValue:[NSString stringWithFormat:@"%d", accountType] forKey:@"accountType"];
    [request setPostValue:accountNumber forKey:@"accountNumber"];
	[request setPostValue:routingNumber forKey:@"routingNumber"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Add Payment Method request...");
    [request startSynchronous];
	XLog(@"Add Payment Method done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:200 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		 *error = [NSError errorWithDomain:@"MetraView" code:250 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// DeletePaymnetMethod
// Removes the payment method specified by the passed in PIID.
// Retruns YES or NO indicating success or failure and sets the error on failure.
-(bool)DeletePaymentMethod: (NSString *) PIID : (NSError**)error {
    if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/DeletePaymentMethod.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/AddPaymentMethod.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:PIID forKey:@"PIID"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Delete Payment Method request...");
    [request startSynchronous];
	XLog(@"Delete Payment Method done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:300 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:350 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// MakePaymentActive
// Makes the payment for the passed in PIID active.  Priority = 1
// Returns YES for success, NO on failure and sets error.
-(bool)MakePaymentActive: (NSString *) PIID : (NSError**)error {
	if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PaymentActive.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/PaymentActive.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:PIID forKey:@"PIID"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Payment Active request...");
    [request startSynchronous];
	XLog(@"Payment Active done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:400 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:450 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// MakePayment
// Takes in the payment method to use as identified by the PIID, and the amount to pay
// Returns YES for success and NO for failure.  Sets the outConfirmationNumber on success and the error on failure.
-(bool)MakePayment: (NSString *) PIID : (NSString *) amountToPay : (NSString **) outConfirmationNumber :(NSError**)error {
	if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PayNow.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/PayNow.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:PIID forKey:@"PIID"];
	[request setPostValue:amountToPay forKey:@"amountToPay"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Pay now request...");
    [request startSynchronous];
	XLog(@"Pay now done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			// get confirmationNumber
			XLog(@"Confirmation number is \"%@\"", [dictionary objectForKey:@"confirmationNumber"]);
			*outConfirmationNumber = [[dictionary objectForKey:@"confirmationNumber"] retain];
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:500 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:550 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// GetPaymentHistory
// Returns an NSArray containing NSDictionary entries of date, paymentType, cardNumber, and amount
-(NSArray*)GetPaymentHistory {
	if (DEBUG_SERVER) {
		return [@"[{\"date\" : \"1/1/01\", \"paymentType\" : \"Credit\"},{\"cardNumber\" : \"1234\", \"amount\" : \"1.00\"}" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/PaymentHistory.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"PaymentHistory request...");
    [request startSynchronous];
	XLog(@"PaymentHistory request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *payments = [[request responseString] JSONValue];
		return payments;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetPlanSelection
// Returns an NSArray containing NSDictionary entries of offering, description, imageUrl, pricing
-(NSArray*)GetPlanSelection {
	if (DEBUG_SERVER) {
		return [@"[]" JSONValue];
		//[{"offering" : "My Domain", "description" : "", "imageUrl" : "/Enrollment/images/lego_1.gif","pricing" : "Yearly - $4.08/month**Monthly - $4.95/month**"}, {"offering" : "Combo", "description" : "", "imageUrl" : "/Enrollment/images/lego_2.gif","pricing" : "Yearly - $8.25/month**Monthly - $9.90/month**"}, {"offering" : "Unlimited", "description" : "", "imageUrl" : "/Enrollment/images/lego_3.gif","pricing" : "Yearly - $12.42/month**Monthly - $14.90/month**"}, {"offering" : "eCommerce", "description" : "", "imageUrl" : "/Enrollment/images/lego_4.gif","pricing" : "Yearly - $16.17/month**Monthly - $19.90/month**"}]
	}
	int stringLength = [Server length];
	NSRange range = NSMakeRange(0, stringLength);
	NSString *newStr = [Server stringByReplacingOccurrencesOfString:VirtualDirectory withString:@"enrollment/planselectionmobile.aspx" options:NSCaseInsensitiveSearch range:range];
	NSURL *url = [NSURL URLWithString:newStr];
	XLog(newStr);
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"GetPlanSelection request...");
    [request startSynchronous];
	XLog(@"GetPlanSelection request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *payments = [[request responseString] JSONValue];
		return payments;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetPlanDetails
// Returns an NSDictionary containing features, poIds, and prices.  Features is an NSArray 
// of an NSDictionary containing feature and description.  PoIds is an NSArray  of an NSDictionary 
// that has a poId and prices which has the price.
-(NSDictionary*)GetPlanDetails: (NSString *) offering  {
	if (DEBUG_SERVER) {
		return [@"{\"a\" : \"a\", \"b\" : \"b\"}" JSONValue];
		//{ "features" : [{"feature" : "Use your own domain", "description" : ""}, {"feature" : "Google Analytics", "description" : "Google Analytics is a powerful tool for analyzing traffic to your XDemosite website. You can track site visitors, where they come from, how long they stay, what keywords they use to find your site and more."}, {"feature" : "Storage (500MB)", "description" : ""}, {"feature" : "Bandwidth (500MB)", "description" : ""}, {"feature" : "Premium support", "description" : ""}, {"feature" : "Search engine friendly", "description" : "All XDemosite sites are optimized for search engines. So even though XDemosite utilizes Flash your site can be found and indexed by all the search engines."}],"poIds" : [{"poId" : "142"}, {"poId" : "129"}],"prices" : [{"price" : "Yearly - $4.08/month"}, {"price" : "Monthly - $4.95/month"}]}
	}
	int stringLength = [Server length];
	NSRange range = NSMakeRange(0, stringLength);
	NSString *newStr = [Server stringByReplacingOccurrencesOfString:VirtualDirectory withString:@"enrollment/plandetailsmobile.aspx" options:NSCaseInsensitiveSearch range:range];
	NSURL *url = [NSURL URLWithString:newStr];
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[request setPostValue:offering forKey:@"offering"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Plan details request...");
    [request startSynchronous];
	XLog(@"Plan details request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		return dictionary;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetSignUpTermsLink
// Returns a valid url to show the product terms and conditions
-(NSString*)GetSignUpTermsLink: (NSString *) poid {
	int stringLength = [Server length];
	NSRange range = NSMakeRange(0, stringLength);
	NSString *newStr = [Server stringByReplacingOccurrencesOfString:VirtualDirectory withString:@"enrollment/PlanTerms.aspx" options:NSCaseInsensitiveSearch range:range];
	NSString *result = [NSString stringWithFormat:@"%@?poid=%@", newStr, poid];
	return result;
}

// Sign Up
// Returns YES or NO and sets error on failure
-(bool)SignUp: (NSString *) poid : (NSString *) cardNumber: (NSString *) securityCode
			 : (NSString *) expirationDate: (NSString *) fullName: (NSString *) address1 
			 : (NSString *) address2: (NSString *) city
			 : (NSString *) state: (NSString *) zip
			 : (NSString *) country: (NSString *) phoneNumber
             : (NSString *) email 
             : (NSString *) username: (NSString *) password
			 : (NSError**)error {
	if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	int stringLength = [Server length];
	NSRange range = NSMakeRange(0, stringLength);
	NSString *newStr = [Server stringByReplacingOccurrencesOfString:@"metraview" withString:@"enrollment/PaymentMobile.aspx" options:NSCaseInsensitiveSearch range:range];
	NSURL *url = [NSURL URLWithString:newStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	

    if (poid != nil) [request setPostValue:poid forKey:@"poid"]; 	XLog(@"poid=%@", poid);
    if (cardNumber != nil) [request setPostValue:cardNumber forKey:@"cardNumber"];	XLog(@"cardNumber=%@", cardNumber);
	if (securityCode != nil) [request setPostValue:securityCode forKey:@"securityCode"];	XLog(@"securityCode=%@", securityCode);
    if (expirationDate != nil) [request setPostValue:expirationDate forKey:@"expirationDate"];	XLog(@"expirationDate=%@", expirationDate);
    if (fullName != nil) [request setPostValue:fullName forKey:@"fullName"];	XLog(@"fullName=%@", fullName);
	if (address1 != nil) [request setPostValue:address1 forKey:@"address1"];	XLog(@"address1=%@", address1);
    if (address2 != nil) [request setPostValue:address2 forKey:@"address2"];	XLog(@"address2=%@", address2);
	if (city != nil) [request setPostValue:city forKey:@"city"];	XLog(@"city=%@", city);
    if (state != nil) [request setPostValue:state forKey:@"state"];	XLog(@"state=%@", state);
	if (zip != nil) [request setPostValue:zip forKey:@"zip"];	XLog(@"zip=%@", zip);
	if (country != nil) [request setPostValue:country forKey:@"country"];	XLog(@"country=%@", country);
	if (phoneNumber != nil) [request setPostValue:phoneNumber forKey:@"phoneNumber"];	XLog(@"phoneNumber=%@", phoneNumber);
    if (email != nil) [request setPostValue:email forKey:@"email"];	XLog(@"email=%@", email);
	if (username != nil) [request setPostValue:username forKey:@"username"];	XLog(@"username=%@", username);
    if (password != nil) [request setPostValue:password forKey:@"password"];	XLog(@"password=%@", password);
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Signup request...");
    [request startSynchronous];
	XLog(@"Signup done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		XLog(@"JSON = %@", [request responseString]);
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:600 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:650 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// GetUsageHistory
// Returns an NSArray containing NSDictionary entries of group, total, totalAsString, url
-(NSArray*)GetUsageHistory {
	if (DEBUG_SERVER) {
		return [@"[{\"group\": \"1/1/2010 - 1/31/2010\", \"total\":\"434.640000\", \"totalAsString\": \"$ 434.64\", \"url\":\"Bill.aspx?interval=959447070\"} ] " JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/History.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Usage History request...");
    [request startSynchronous];
	XLog(@"Usage History request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *history = [[request responseString] JSONValue];
		return history;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetSubscriptions
// Returns an NSArray containing NSDictionary entries of name, description, date
-(NSArray*)GetSubscriptions {
	if (DEBUG_SERVER) {
		return [@"[{\"name\": \"Plan a\", \"description\":\"The description...\", \"date\": \"123\"}]" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/Subscriptions.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Subscriptions request...");
    [request startSynchronous];
	XLog(@"Subscriptions request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *history = [[request responseString] JSONValue];
		return history;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// GetAvailableSubscriptions
// Returns an NSArray containing NSDictionary entries of name, description
-(NSArray*)GetAvailableSubscriptions {
	if (DEBUG_SERVER) {
		return [@"[{\"name\": \"Plan a\", \"description\":\"The description...\", \"poid\":\"123\"}]" JSONValue];
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/AvailableSubscriptions.aspx"]];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:60];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Available Subscriptions request...");
    [request startSynchronous];
	XLog(@"Available Subscriptions request done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *error = [request error];
    if (!error) {
		NSArray *history = [[request responseString] JSONValue];
		return history;
    }
    else {
        XLog(@"Error %@", [error localizedDescription]);
    }
	
	return nil;
}

// Subscribe
// Takes in the product offering id
// Returns YES for success and NO for failure.  Sets the outConfirmationNumber on success and the error on failure.
-(bool)Subscribe: (NSString *) poid : (NSError**)error {
	if(error == nil) return NO;
	bool result;
	if (DEBUG_SERVER) {
		sleep(1);
		return true;
	}
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", Server, @"/Mobile/Subscribe.aspx"]];
	XLog(@"%@%@", Server, @"/Mobile/Subscribe.aspx");
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	[request setTimeOutSeconds:30];
	[request setValidatesSecureCertificate:VALIDATE_CERT];	
    [request setPostValue:poid forKey:@"poid"];
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	XLog(@"Subscribe request...");
    [request startSynchronous];
	XLog(@"Subscribe done...");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	NSError *resultError = [request error];
	NSMutableDictionary *errorDetail;
    if (!resultError) {
		NSDictionary *dictionary = [[request responseString] JSONValue];
		XLog(@"Dictionary value for \"success\" is \"%@\"", [dictionary objectForKey:@"success"]);
		
		if ([[dictionary objectForKey:@"success"] isEqualToString: @"true"]) {
			result = true;
		}
		else {
			XLog(@"Error %@", [dictionary objectForKey:@"errorMessage"]);
			errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:[dictionary objectForKey:@"errorMessage"] forKey:NSLocalizedDescriptionKey];
			*error = [NSError errorWithDomain:@"MetraView" code:700 userInfo:errorDetail];
			result = false;
		}
    }
    else {
        XLog(@"Error %@", [resultError localizedDescription]);
		errorDetail = [NSMutableDictionary dictionary];
		[errorDetail setValue:[resultError localizedDescription] forKey:NSLocalizedDescriptionKey];
		*error = [NSError errorWithDomain:@"MetraView" code:750 userInfo:errorDetail];
		result = false;
    }
	
	return result;
}

// GetUsageHistoryChartLink
// Returns a valid url to show the usage history chart
-(NSString*)GetUsageHistoryChartLink {
    NSString *result = [NSString stringWithFormat:@"%@%@", Server, @"/Mobile/HistoryChart.aspx"];
	return result;
}

// GetUsageChartLink
// Returns a valid url to show the usage chart
-(NSString*)GetUsageChartLink: (NSString *) intervalId {
	NSString *result = [NSString stringWithFormat:@"%@%@?intervalId=%@", Server, @"/Mobile/UsageGraph.aspx", intervalId];
	return result;
}

// GetProductChartLink
// Returns a valid url to show the by product chart
-(NSString*)GetProductChartLink: (NSString *) intervalId {
	NSString *result = [NSString stringWithFormat:@"%@%@?intervalId=%@", Server, @"/Mobile/ProductGraph.aspx", intervalId];
	return result;
}

- (void) dealloc {
	[Server release];
	[Username release];
	[super dealloc];
} 
@end

