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
@property (weak, nonatomic) IBOutlet UILabel *secretQuestion;
@property (weak, nonatomic) IBOutlet UITextField *answerText;
@property (strong, nonatomic) NSString * questionid;
@property (strong, nonatomic) NSString * html;
@property (strong, nonatomic) Reachability *reach;
@property (strong,nonatomic) Parser * myParser;
@property ( strong ,nonatomic) NSDictionary * timetable;

@property (strong , nonatomic) WebHandler * webHandler;
-(void) hideSecretQuestonRelatedStuff;
-(void) showSecretQuestonRelatedStuff;
-(void)setViewToDefault;
-(void)reachabilityChanged:(NSNotification*)note;
@end
