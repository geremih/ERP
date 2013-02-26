//
//  LoginViewController.m
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/22/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import "LoginViewController.h"
#import "GridViewController.h"
@interface LoginViewController ()

@end

@implementation LoginViewController


@synthesize myParser = _myParser, rollNumber , password , passline,activityIndicator ,webHandler , reach = _reach, html = _html   ;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    //Get user defaults and push if already set
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs integerForKey:@"LoggedIn"] ==1)
    {
        NSLog(@"He was logged in ");
        self.timetable = [prefs objectForKey:@"TimeTable"];
        [self performSegueWithIdentifier:@"SendToGrid" sender:self];
        
    }
    [self.navigationController setDelegate:self];

    //Notification for reachability
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    
    self.reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    [self.reach startNotifier];
    self.webHandler = [[WebHandler alloc] init];
    [self loadCaptcha];
}

-(void) loadCaptcha {
    [self.gettingCaptchaIndicator startAnimating];
    
    
    dispatch_queue_t DownloadQueue = dispatch_queue_create("get captcha", NULL) ;
    
    dispatch_async( DownloadQueue , ^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.captcha.image = [webHandler requestCaptcha];
           
            [self.gettingCaptchaIndicator stopAnimating];
        });
    });
    
    dispatch_release(DownloadQueue);
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)logInPressed:(id)sender {
    
    //Called when login is pressed
    
    [self.passline  resignFirstResponder];
    [self.view setUserInteractionEnabled:NO];
    [self.activityIndicator startAnimating];
   
    dispatch_queue_t DownloadQueue = dispatch_queue_create("get timetable", NULL) ;
    
    dispatch_async( DownloadQueue , ^{
        self.html =  [self.webHandler getTimeTableHTMLForUser:self.rollNumber.text password:self.password.text passline:self.passline.text ];
        
        if([self.html isEqualToString:@"Error"])
        {
            
            NSLog(@"ERRROR!!");
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self setViewToDefault];
                UIAlertView *alert=  [[UIAlertView alloc] initWithTitle:@"Error" message:@"Incorrect Credententials" delegate:nil cancelButtonTitle:@"Retry" otherButtonTitles: nil];;
                [alert show];
            });
            
        }
        
        else {
        self.myParser = [[Parser alloc]init   ];
        self.timetable = [self.myParser getTimeTableDictionaryfromHTML:self.html];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self performSegueWithIdentifier:@"SendToGrid" sender:self];
            
        });
        }
    });
    dispatch_release(DownloadQueue);
    
    
}
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    //Function to cycle text fields when next is pressed
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
        if(nextTag ==4)
            [self logInPressed:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}


- (void)viewDidUnload {
    [self setRollNumber:nil];
    [self setPassword:nil];
    [self setActivityIndicator:nil];
    [super viewDidUnload];
}






-(void)setViewToDefault{
    [self loadCaptcha];
    [self.view setUserInteractionEnabled:YES];
    [self.activityIndicator stopAnimating];
    self.rollNumber.text = @"";
    self.password.text = @"";
    self.passline.text = @"";
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if(![reach isReachable])
    {
        UIAlertView * alert=[[UIAlertView alloc] init];
        [alert setDelegate:self];
        [alert setTitle:@"No connection"];
        [alert addButtonWithTitle:@"Retry"];
        [alert show];
    }
}


-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    //Is called when user logs out and view pushes back in
    if([viewController isKindOfClass:[LoginViewController class]]){
        
        [self setViewToDefault];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"%c",[self.reach isReachable]);
    if([self.reach isReachable])
    {
        [alertView dismissWithClickedButtonIndex:-1 animated:YES]   ;
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ( [segue.identifier isEqualToString:@"SendToGrid"])
    {
        GridViewController *newcontroller = segue.destinationViewController;
        newcontroller.timetable =  self.timetable;
    }
}

@end
