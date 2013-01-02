//
//  PlayViewController.m
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/17/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import "GridViewController.h"

@interface GridViewController ()

@end




@implementation GridViewController

@synthesize viewWeb = _viewWeb ,webHandler = _webHandler , myParser = _myParser, gridTableView =_gridTableView , myDataSource = _myDataSource;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webHandler = [[WebHandler alloc] init];
    self.webHandler.viewWeb = self.viewWeb;
    self.viewWeb.delegate = self.webHandler;
   NSString * html = [self.webHandler getTimeTableHTMLForUser:@"11CS30026" password:@"thedoctor" andSecretAnswer:@"green" forQuestion:@"U2"] ;
    
    
    
    self.myParser = [[Parser alloc]init   ];
    
 NSString *XMLPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"erp1.xml"];

    //NSString *XMLPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"test.xml"];

  NSDictionary * timetable = [self.myParser getTimeTableDictionaryfromHTML:XMLPath ];
    
    
    //Grid View
    
  [self.viewWeb removeFromSuperview];
    self.gridTableView = [[A3GridTableView alloc] initWithFrame:self.view.bounds];
    self.gridTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    self.myDataSource = [[GridDataSource alloc] init];
[self.myDataSource displayGridUsingDictionary:timetable];

    // set datasource and delegate
    self.gridTableView.dataSource = self.myDataSource;
    self.gridTableView.delegate = self.myDataSource;
    
    // set paging
    self.gridTableView.pagingPosition = A3GridTableViewCellAlignmentCenter;
    self.gridTableView.gridTableViewPagingEnabled = YES;
    self.gridTableView.backgroundColor = [UIColor whiteColor];
    
    // scrolling
    self.gridTableView.directionalLockEnabled = YES;

    // add as subview
  [self.view addSubview:self.gridTableView];
    //[self.view sendSubviewToBack:self.gridTableView];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

