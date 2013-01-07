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

@synthesize  gridTableView =_gridTableView , myDataSource = _myDataSource , timetable = _timetable;
- (void)viewDidLoad
{
    //Checks if already logged in, if yes shows the timetable
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:self.timetable forKey:@"TimeTable"];
    [prefs setInteger:1 forKey:@"LoggedIn"];
    [prefs synchronize];
    
    if([self.timetable isEqualToDictionary:[[NSDictionary alloc] init]])
        {
            [self logout];
        }
    //Grid View
    self.gridTableView = [[A3GridTableView alloc] initWithFrame:self.view.bounds];
    self.gridTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.myDataSource = [[GridDataSource alloc] init];
    // set datasource and delegate
    self.gridTableView.delegate = self;
    [self.myDataSource displayGridUsingDictionary:self.timetable];
    self.gridTableView.dataSource = self.myDataSource;
    // set paging
    self.gridTableView.pagingPosition = A3GridTableViewCellAlignmentCenter;
    self.gridTableView.gridTableViewPagingEnabled = YES;
    self.gridTableView.backgroundColor = [UIColor whiteColor];
    // scrolling
    self.gridTableView.directionalLockEnabled = YES;
    // add as subview
    [self.view addSubview:self.gridTableView];
    
}



-(void) logout{
    //Function is called when logout button is pressed
    NSLog(@"logout") ;
    [self.navigationController popViewControllerAnimated:YES];
    //Update NSUserDefaults
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:0 forKey:@"LoggedIn"];
    [prefs synchronize];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

