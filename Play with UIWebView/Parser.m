//
//  Parser.m
//  Play with UIWebView
//
//  Created by Mihir Rege on 12/18/12.
//  Copyright (c) 2012 Mihir Rege. All rights reserved.
//

#import "Parser.h"
#define TOUCHXMLUSETIDY TRUE
#import "CTidy.h"

@implementation Parser


@synthesize timetable = _timetable , html = _html  ;

-(NSDictionary *) getTimeTableDictionaryfromHTML:(NSString *)html  {
    
    //self.html = html;
     self.html = [self normalizeHTML:html];
    
    CTidy * t = [CTidy tidy]; 
    
    

    //NSLog(self.html);
    NSString *XHTML = [t tidyString:self.html inputFormat:TidyFormat_HTML outputFormat:TidyFormat_XHTML encoding:"UTF8" diagnostics:nil error:nil];
   
    NSLog(XHTML);
    NSData * XMLData =  [NSData dataWithContentsOfFile:XHTML];

    //NSData *XMLData = [self.html dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    CXMLDocument *doc = [[CXMLDocument alloc] initWithData:XMLData options:0 error:nil];
    
    NSArray *nodes = NULL;
    nodes = [doc nodesForXPath:@"/html/body/table/tr/td/form/table/tr/td/table/tr/" error:nil];
   
    /*
     Algorithm
     1. Get the node
     2. Check the rowspan [ the next node will be  at an addition of this]
     
     Have a integer which keeps the track of which is the next node to go to [ tracker]
     3. Go collected nodes with same row span
     If a node with a different row span comes [ check the next tracker + 1 to tracker +rowspan -1 nodes] and
     add it to this.
     change value of tracker.
     After finishing jump to next node and repeat
     [Check if rowspan and jump data matches.
     */
    
    
    int i;
    self.timetable = [[NSMutableDictionary alloc] init];
    
    for (i=0 ;i< [nodes count];) {
        NSMutableArray *res = [[NSMutableArray alloc] init];
        CXMLElement * node = [nodes objectAtIndex:i];
        int counter;
        NSString * currentDay;
        int nextnode=1;
        int tracker=1;

        currentDay= [[node childAtIndex:1] stringValue];
        
        if([self valueOfElement:[node childAtIndex:1] forAttrib:@"rowspan" ])
            nextnode= [self valueOfElement:[node childAtIndex:1] forAttrib:@"rowspan" ];
        
        for(counter = 3; counter < [node childCount]; counter+=2) {
            
            NSString * subject;
            subject = [[node childAtIndex:counter] stringValue];
            
            if([self valueOfElement:[node childAtIndex:counter] forAttrib:@"rowspan"])
            {
                if( [self valueOfElement:[node childAtIndex:counter] forAttrib:@"rowspan"] != nextnode)
                {
                    
                    //this one is assuming the extra row has only one element
                    subject = [subject stringByAppendingString:@" AND "];
                    subject = [subject stringByAppendingString: [[[nodes objectAtIndex:i +tracker] childAtIndex:1] stringValue]];
                    
                    tracker++;
                }
            }
           
            int total_periods =1;
            if([self valueOfElement:[node childAtIndex:counter] forAttrib:@"colspan"])
                total_periods = [self valueOfElement:[node childAtIndex:counter] forAttrib:@"colspan"];
            for(int j =0 ; j< total_periods; j++)
                [res addObject:subject];
            
        }
        
        if(tracker != nextnode) NSLog(@"error!!");
        
        i = i+nextnode;
        
        [self.timetable setObject:res forKey:currentDay ];
    }
    
    NSLog(@"Finished parsing , %@",self.timetable);
    return self.timetable;
}

-(NSString *) normalizeHTML:(NSString *)html
{
    
    NSError *error = NULL;
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@"<br>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString * result = [regex stringByReplacingMatchesInString:html options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, html.length) withTemplate:@" "];
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"&nbsp;" options:NSRegularExpressionCaseInsensitive error:&error];
    
    result = [regex stringByReplacingMatchesInString:result options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, result.length) withTemplate:@"Empty"];
    
    
    regex = [NSRegularExpression regularExpressionWithPattern:@"<input.*?>" options:NSRegularExpressionCaseInsensitive error:&error];
    
    result = [regex stringByReplacingMatchesInString:result options:NSRegularExpressionCaseInsensitive range:NSMakeRange(0, result.length) withTemplate:@" "];
    

 
    
    return result;

    
}

-(int) valueOfElement: (CXMLNode *) node forAttrib: (NSString *) attrib{
    
    if( [node isKindOfClass:[CXMLElement class]])
    {
        return [[[ (CXMLElement *)node attributeForName:attrib] stringValue] integerValue];
    }
    return 0;
}

@end
