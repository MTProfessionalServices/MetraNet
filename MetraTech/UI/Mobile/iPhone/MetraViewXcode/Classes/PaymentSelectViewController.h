//
//  PaymentSelectViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/23/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PaymentSelectViewController : UITableViewController {

	NSArray *dataSourceArray;
	
	UIBarButtonItem *addButton;
}

@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) UIBarButtonItem *addButton;

-(void)addPaymentMethod:(id)sender;
@end
