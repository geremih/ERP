//
//  ERPViewController.h
//  Play With Grids
//
//  Created by Mihir Rege on 12/21/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A3GridTableView.h"
#import <QuartzCore/QuartzCore.h>

@interface GridDataSource : NSObject <A3GridTableViewDataSource,A3GridTableViewDelegate>
@property (strong ,nonatomic) NSMutableArray * colorDict;

@property (strong, nonatomic)  NSDictionary * timetable;
@property (strong, nonatomic) NSMutableDictionary  *subjects;
@property (strong, nonatomic) NSArray * days;
-(void) displayGridUsingDictionary:(NSDictionary *) timetable;
-(UIColor *) randomColor;
@end
