//
//  PaymentHistoryViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/29/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PaymentHistoryViewController : UITableViewController {

	NSArray *dataSourceArray;
}

@property (nonatomic, retain) NSArray *dataSourceArray;

@end
