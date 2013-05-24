//
//  SignUpViewDetailsController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/6/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpViewDetailsController : UITableViewController {

	NSDictionary *item; 
	NSDictionary *planDetails;
	NSArray *planFeatures;
	NSArray *planPoIds;
	NSArray *planPrices;
	NSArray *priceDescriptions; 
}

@property (nonatomic, retain) NSDictionary *item;
@property (nonatomic, retain) NSDictionary *planDetails;
@property (nonatomic, retain) NSArray *planFeatures;
@property (nonatomic, retain) NSArray *planPoIds;
@property (nonatomic, retain) NSArray *planPrices;
@property (nonatomic, retain) NSArray *priceDescriptions;

@end
