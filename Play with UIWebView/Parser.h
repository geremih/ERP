//
//  Parser.h
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/18/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

@interface Parser : NSObject

@property(nonatomic, strong) NSString * html;
@property (strong, nonatomic) NSMutableDictionary * timetable;
-(NSDictionary *) getTimeTableDictionaryfromHTML:(NSString *) html;
-(int) valueOfElement: (CXMLNode *) node forAttrib:(NSString *) attrib;
-(NSString *) normalizeHTML:(NSString *) html;
-(NSString *) repairHTML:(NSString *) html;
@end
