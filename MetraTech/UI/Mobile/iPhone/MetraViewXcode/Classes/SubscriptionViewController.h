//
//  SubscriptionViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/12/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SubscriptionViewController : UITableViewController {
	NSArray *dataSourceArray;
	UIBarButtonItem *addButton;
}

@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) UIBarButtonItem *addButton;

-(void)addMethod:(id)sender;
@end
