//
//  LoginViewController.h
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/22/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "WebHandler.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate ,UIAlertViewDelegate ,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextField *rollNumber;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSString * html;
@property (strong, nonatomic) Reachability *reach;
@property (strong,nonatomic) Parser * myParser;
@property ( strong ,nonatomic) NSDictionary * timetable;
@property ( weak, nonatomic) IBOutlet UIImageView *captcha;
@property ( weak , nonatomic) IBOutlet UITextField *passline;
@property (strong , nonatomic) WebHandler * webHandler;
@property (weak , nonatomic) IBOutlet UIActivityIndicatorView * gettingCaptchaIndicator;
-(void)setViewToDefault;
-(void) loadCaptcha;
-(void)reachabilityChanged:(NSNotification*)note;
@end
