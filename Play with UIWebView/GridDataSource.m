//
//  ERPViewController.m
//  Play With Grids
//
//  Created by Mihir Rege on 12/21/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//
#import "GridDataSource.h"
#import "A3GridTableView.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface NSString (trimLeadingWhitespace)
-(NSString*)stringByTrimmingLeadingWhitespace;
@end

@implementation NSString (trimLeadingWhitespace)
-(NSString*)stringByTrimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}
@end


@interface GridDataSource ()

@end

@implementation GridDataSource

@synthesize timetable = _timetable, days = _days, colorDict = _colorDict;


-(id) init {
    
    if(self=[super init])
    {
        
        self.days = [[NSArray alloc] initWithObjects:@"\nDay Name",@"\nMon",@"\nTue",@"\nWed", @"\nThur", @"\nFri", nil];
    }
    return self;
}


-(void) displayGridUsingDictionary:(NSDictionary *) timetable{
    
    srandom(time(NULL));
    self.timetable =timetable;
    self.subjects = [[NSMutableDictionary alloc] initWithCapacity:0 ];
    self.colorDict = [[NSMutableArray alloc] initWithCapacity:0 ];
    
    //old
    
    
    //new
    [self.colorDict addObject:UIColorFromRGB(0xEEE9E9)];
    [self.colorDict addObject:UIColorFromRGB(0xFFE4C4)];
    [self.colorDict addObject:UIColorFromRGB(0xAFEEEE)];
    [self.colorDict addObject:UIColorFromRGB(0x00BFFF)];
    [self.colorDict addObject:UIColorFromRGB(0x7FFFD4)];
    [self.colorDict addObject:UIColorFromRGB(0xFFC0CB)];  //new
    
    
    [self.colorDict addObject:UIColorFromRGB(0xFFFACD)];
      
    [self.colorDict addObject:UIColorFromRGB(0x00FF7F)];
    [self.colorDict addObject:UIColorFromRGB(0xDB7093)];
    [self.colorDict addObject:UIColorFromRGB(0x48D1CC)];
    [self.colorDict addObject:UIColorFromRGB(0xEEDD82)];

    
    [self.colorDict addObject:UIColorFromRGB(0xBC8F8F)];
    [self.colorDict addObject:UIColorFromRGB(0xFFA07A)];
    [self.colorDict addObject:UIColorFromRGB(0xCDC8B1)];
    
    [self.colorDict addObject:UIColorFromRGB(0x00BFFF)];
    
    
    
    

    
    
    for(NSArray * key in self.timetable)
    {
        if(![[self.timetable objectForKey:key] containsObject:@"\n7:30:AM-8:25:AM"]){
        for(NSString * fullsubject in [self.timetable objectForKey:key])
        {
            NSString * subject;
            subject= [[[fullsubject stringByTrimmingLeadingWhitespace] componentsSeparatedByString:@" "] objectAtIndex:0];
            if(![[self.subjects allKeys] containsObject:subject] ){
                if([subject isEqualToString:@"Empty"])
                    [self.subjects setObject:[UIColor whiteColor] forKey:subject];
                else
                {
                    [self.subjects setObject:[self randomColor] forKey:subject];
                    NSLog(subject);
                }
            }
        }
            
           
            
        }
        
        
    }
}

- (NSInteger)numberOfSectionsInA3GridTableView:(A3GridTableView *) gridTableView
{
    return [self.timetable count];
}

- (NSInteger)A3GridTableView:(A3GridTableView *) tableView numberOfRowsInSection:(NSInteger) section{
    
    return [ [self.timetable objectForKey:[self.days objectAtIndex:section]] count];
}

- (CGFloat)A3GridTableView:(A3GridTableView *)aGridTableView widthForSection:(NSInteger)section{
    CGFloat width = aGridTableView.bounds.size.width;
    return width/6;}

- (CGFloat)A3GridTableView:(A3GridTableView *) gridTableView heightForRowAtIndexPath:(NSIndexPath *) indexPath{
    
    CGFloat height = gridTableView.frame.size.height;
    return height/10;
    
}



- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)gridTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    A3GridTableViewCell *cell;
    
    NSString * subject = [ [self.timetable objectForKey:[self.days objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0)
    {
        
        NSError *error = NULL;
        NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"\n" options:NSRegularExpressionCaseInsensitive error:&error];
        
        subject= [regex stringByReplacingMatchesInString:subject options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, subject.length) withTemplate:@""];
        
    }
    cell = [gridTableView dequeueReusableCellWithIdentifier:@"cellID"] ;
    
    if (!cell) {
        cell = [[A3GridTableViewCell alloc] initWithReuseIdentifier:@"cellID"];
        [cell setFrame:CGRectMake(0, 0, 25, 25)];
        [cell.layer setBorderWidth:1];
        cell.layer.cornerRadius = 5;
        cell.layer.masksToBounds = YES;
        [cell.layer setBorderColor:[UIColor whiteColor].CGColor  ];
        cell.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.titleLabel.numberOfLines =2;
        cell.titleLabel.font = [cell.titleLabel.font fontWithSize:10];
        
        
    }
    
    if(indexPath.section == 0)
    {
        cell.backgroundColor = UIColorFromRGB(0x4169E1);
        
    }
    else{
        
        
        cell.backgroundColor = [self.subjects objectForKey:[[[subject stringByTrimmingLeadingWhitespace] componentsSeparatedByString:@" "] objectAtIndex:0]];
        
    }
    
    //remove stupid semicolons
    if([subject  isEqualToString:@"Empty"])
    {
        subject = @"";
    }
    
    cell.titleLabel.text = subject;
    
    return cell;
}

// header handling
- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)aGridTableView headerForSection:(NSInteger)section{
    A3GridTableViewCell *headerCell;
    
    headerCell = [aGridTableView dequeueReusableHeaderWithIdentifier:@"headerID"];
    
    if (!headerCell) {
        headerCell = [[A3GridTableViewCell alloc] initWithReuseIdentifier:@"headerID"];
        
        
        
        
        
        headerCell.titleLabel.textAlignment = NSTextAlignmentCenter;
        headerCell.backgroundView.backgroundColor = UIColorFromRGB(0X87CEFA);
        [headerCell.layer setBorderWidth:1];
        headerCell.layer.cornerRadius = 5;
        [headerCell.layer setBorderColor:[UIColor whiteColor].CGColor  ];
        headerCell.titleLabel.font = [headerCell.titleLabel.font fontWithSize:15];
    }
    
    if(section ==0)
    {
        headerCell.backgroundView.backgroundColor = [UIColor whiteColor];
    }
    else
        headerCell.titleLabel.text = [self.days objectAtIndex:section] ;
    
    
    return headerCell;
}

- (CGFloat)heightForHeadersInA3GridTableView:(A3GridTableView *)aGridTableView{
    CGFloat height = aGridTableView.frame.size.height;
    return height/10;;
}

- (UIColor *)randomColor {
    
    if(self.colorDict.count >0)
    {
        UIColor * color = [self.colorDict lastObject];
        
        [self.colorDict removeLastObject];
        
        return color;
    }
    
    else{
        
        CGFloat red =  (CGFloat)random()/(CGFloat)RAND_MAX;
        CGFloat blue = (CGFloat)random()/(CGFloat)RAND_MAX;
        CGFloat green = (CGFloat)random()/(CGFloat)RAND_MAX;
        return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
        
    }
}



@end
