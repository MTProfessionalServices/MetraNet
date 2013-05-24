//
//  AvailableSubscriptionsViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/12/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AvailableSubscriptionsViewController : UITableViewController {
	NSArray *dataSourceArray;
	NSString *poid;
}

@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) NSString *poid;

-(void) subscribe;
@end
