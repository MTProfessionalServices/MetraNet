//
//  SignUpViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/6/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SignUpViewController : UITableViewController {

	NSArray *dataSourceArray;
	UIBarButtonItem *buttonBack; 
}

@property (nonatomic, retain) NSArray *dataSourceArray;
@property (nonatomic, retain) UIBarButtonItem *buttonBack;

-(void)goBack:(id)sender;
-(void)refresh;

@end
