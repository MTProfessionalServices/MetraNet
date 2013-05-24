//
//  HistoryViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/12/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HistoryViewController : UITableViewController {
	NSArray *dataSourceArray;
}

@property (nonatomic, retain) NSArray *dataSourceArray;

@end
