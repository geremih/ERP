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

@interface GridViewController : UIViewController <UIWebViewDelegate,NSURLConnectionDelegate>
@property (strong,nonatomic) Parser * myParser;
@property (strong, nonatomic) NSString * html;
@property ( strong ,nonatomic) NSDictionary * timetable;
@property (strong , nonatomic)  A3GridTableView *gridTableView;
@property (strong, nonatomic) GridDataSource * myDataSource;
@end
