//
//  PlayViewController.h
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/17/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebHandler.h"
#import "Parser.h"
#import "A3GridTableView.h"
#import "GridDataSource.h"
#import "LoginViewController.h"
@interface GridViewController : UIViewController <A3GridTableViewDelegate>


@property ( strong ,nonatomic) NSDictionary * timetable;
@property (strong , nonatomic)  A3GridTableView *gridTableView;
@property (strong, nonatomic) GridDataSource * myDataSource;
-(void)logout;

@end
