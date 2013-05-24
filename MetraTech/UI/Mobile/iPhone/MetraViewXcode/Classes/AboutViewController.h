//
//  AboutViewController.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 5/19/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController <UITextViewDelegate> {
	IBOutlet UITextView *about;
}

@property (nonatomic, retain) IBOutlet UITextView *about;

@end
