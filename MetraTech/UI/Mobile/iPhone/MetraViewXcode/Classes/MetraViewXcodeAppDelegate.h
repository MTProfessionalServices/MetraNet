//
//  MetraViewXcodeAppDelegate.h
//  MetraViewXcode
//
//  Created by Kevin Boucher on 4/14/10.
//  Copyright 2010 MetraTech Corp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "lib/JSON/JSON.h"
#import "MetraViewLib.h"
#import "SignUpViewController.h"

// Turn on auto rotate with device orientation?
#define AUTO_ROTATE NO;

@interface MetraViewXcodeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, UITextFieldDelegate, UIWebViewDelegate, UINavigationControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	NSString *serverName;
	NSString *virtualDirectory;
    MetraViewLib *mv;
	UIActivityIndicatorView *spinner;
	
	IBOutlet UINavigationController *signUpNav;
	IBOutlet SignUpViewController *signUp;
	
	IBOutlet UITextField *textUsername;
	IBOutlet UITextField *textPassword;
	IBOutlet UIButton *buttonLogin;
	IBOutlet UIWebView *webView;
	IBOutlet UIButton *buttonInfo;
	IBOutlet UIButton *buttonBack;
	IBOutlet UIButton *buttonForward;
	IBOutlet UIButton *buttonBackToLogin;
	
	IBOutlet UIActivityIndicatorView *spinnerWeb;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) NSString *serverName;
@property (nonatomic, retain) NSString *virtualDirectory;
@property (nonatomic, retain) MetraViewLib *mv;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@property (nonatomic, retain) IBOutlet UINavigationController *signUpNav;
@property (nonatomic, retain) IBOutlet SignUpViewController *signUp;

@property (nonatomic, retain) IBOutlet UITextField *textUsername;
@property (nonatomic, retain) IBOutlet UITextField *textPassword;
@property (nonatomic, retain) IBOutlet UIButton *buttonLogin;
@property (nonatomic, retain) IBOutlet UIButton *buttonInfo;
@property (nonatomic, retain) IBOutlet UIButton *buttonBack;
@property (nonatomic, retain) IBOutlet UIButton *buttonForward;
@property (nonatomic, retain) IBOutlet UIButton *buttonBackToLogin;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinnerWeb;

-(IBAction)doLogin;
-(IBAction)goBackToLogin;
-(IBAction)goBack;
-(IBAction)goForward;
-(IBAction)moreInfo;

- (void)spinStart;
- (void)spinEnd;

@end
